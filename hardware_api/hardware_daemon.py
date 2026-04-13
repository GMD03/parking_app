import ctypes
import time
import threading
import json
import requests
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from datetime import datetime

DLL_PATH = r"c:\parking_app\hardware_api\NP3300.dll"
ALPR_CONF_THRESHOLD = 0.85   # 0.85 = 85%
ALPR_DEDUPE_SEC = 2.0        # ignore same plate+lane+gate within this time
_last_alpr = {}              # key -> last_time

HOST = "0.0.0.0"
API_PORT = 8088


HTTP_SESSION = requests.Session()


# Masks (adjust if your IO differs)
DEFAULT_BUTTON_MASK = 0x01
DEFAULT_LOOP_MASK   = 0x08

# Require loop active for ticket printing
REQUIRE_LOOP_FOR_TICKET = True

# Optional auto-close after vehicle passes loop (set False to disable)
AUTO_CLOSE_ENABLED = True
AUTO_CLOSE_DELAY_SEC = 2.0

# PHP endpoint that prints ticket/QR
TICKET_URL = "http://127.0.0.1/ticket.php"

# Relay pulse length
DEFAULT_PULSE_MS = 800
PULSE_LOCK = threading.Lock()

# ================= CONTROLLERS (add more here) =================
# gates: gate_number -> {"open": relay_no, "close": relay_no}
CONTROLLERS = {
    "ENTRY": {
        "ip": b"192.168.8.230",
        "port": 8008,
        "site": "LA SALLE",
        "gates": {
            1: {"open": 1, "close": 3},
            2: {"open": 2, "close": 4},
        },
        "ticket_gate": 1,
        "ticket_button_mask": DEFAULT_BUTTON_MASK,
        "loop_mask": DEFAULT_LOOP_MASK,
        "pulse_ms": DEFAULT_PULSE_MS,
    },
    "EXIT": {
        "ip": b"192.168.8.231",
        "port": 8009,
        "site": "LA SALLE",
        "gates": {
            1: {"open": 1, "close": 3},
            2: {"open": 2, "close": 4},
        },
        "ticket_gate": 1,
        "ticket_button_mask": DEFAULT_BUTTON_MASK,
        "loop_mask": DEFAULT_LOOP_MASK,
        "pulse_ms": DEFAULT_PULSE_MS,
    }
}


# ================= STATE =================
READY_FOR_TICKET = {name: True for name in CONTROLLERS.keys()}   # unlock after loop goes OFF
ARMED = {name: False for name in CONTROLLERS.keys()}            # counting armed
SAW_LOOP = {name: False for name in CONTROLLERS.keys()}         # loop seen while armed
IN_COUNT = {name: 0 for name in CONTROLLERS.keys()}             # counts
CLOSE_TIMER_ACTIVE = {name: False for name in CONTROLLERS.keys()}  # prevent timer stacking

# ================= DLL + STRUCTS =================
np = ctypes.CDLL(DLL_PATH)

class RelayCtrl(ctypes.Structure):
    _fields_ = [
        ("relay_no", ctypes.c_uint8),
        ("action", ctypes.c_uint8),
        ("delay", ctypes.c_uint16),
    ]

class IOState(ctypes.Structure):
    _fields_ = [
        ("io_state_1", ctypes.c_uint8),
        ("io_state_2", ctypes.c_uint8),
        ("io_state_3", ctypes.c_uint8),
        ("io_state_4", ctypes.c_uint8),
    ]

# init SDK once
try:
    np.np3300_sdk_init()
except Exception:
    pass

# ================= HELPERS =================
def pulse(ip, port, relay_no, pulse_ms):
    with PULSE_LOCK:
        print(f"[MOCK] Pulsing relay {relay_no} on {ip}:{port} for {pulse_ms}ms")
        time.sleep(pulse_ms / 1000.0)

def do_open(lane: str, gate: int = 1, source="API"):
    lane = lane.upper()
    cfg = CONTROLLERS[lane]
    g = cfg["gates"].get(int(gate))
    if not g:
        raise Exception(f"Gate {gate} not configured for {lane}")
    print(f"[OPEN] [{lane}] gate={gate} relay={g['open']} source={source}")
    pulse(cfg["ip"], cfg["port"], g["open"], cfg.get("pulse_ms", DEFAULT_PULSE_MS))

def do_close(lane: str, gate: int = 1, source="API"):
    lane = lane.upper()
    cfg = CONTROLLERS[lane]
    g = cfg["gates"].get(int(gate))
    if not g:
        raise Exception(f"Gate {gate} not configured for {lane}")
    print(f"[CLOSE] [{lane}] gate={gate} relay={g['close']} source={source}")
    pulse(cfg["ip"], cfg["port"], g["close"], cfg.get("pulse_ms", DEFAULT_PULSE_MS))

def close_and_reset(lane: str, gate: int, source="AUTO"):
    do_close(lane, gate=gate, source=source)

    READY_FOR_TICKET[lane] = True
    ARMED[lane] = False
    SAW_LOOP[lane] = False
    CLOSE_TIMER_ACTIVE[lane] = False

    print(f"[i] [{lane}] state reset after close")

def reset_http_sessions():
    """Reset outbound HTTP connection pools (ticket.php, etc.)."""
    global HTTP_SESSION
    try:
        HTTP_SESSION.close()
    except Exception:
        pass
    HTTP_SESSION = requests.Session()
    print("🔁 HTTP sessions reset")


def reset_controller_connections():
    """Reset NP3300 SDK connections (forces new TCP connections on next call)."""
    print("🔁 Resetting controller SDK connections...")
    try:
        np.np3300_sdk_exit()
    except Exception:
        pass
    time.sleep(0.3)
    try:
        np.np3300_sdk_init()
    except Exception:
        pass
    print("✅ Controller connections reset")


def reset_all_connections():
    """Convenience: reset everything connection-related."""
    reset_http_sessions()
    reset_controller_connections()


def read_io(lane: str):
    # Mocking read_io to return an active loop randomly or just inactive
    st = IOState()
    st.io_state_1 = 0
    st.io_state_2 = 0 # loop/buttons inactive
    st.io_state_3 = 0
    st.io_state_4 = 0
    return st

def generate_ticket_no(prefix="P"):
    return f"{prefix}-{datetime.now().strftime('%y%m%d%H%M%S')}"

def print_ticket(lane: str, trigger: str):
    cfg = CONTROLLERS[lane]
    ticket_no = generate_ticket_no("P")
    plate = "NO_PLATE"

    params = {
        "ticket": ticket_no,
        "plate": plate,
        "type": "Cars",
        "site": cfg.get("site", "SITE"),
        "base": 50,
        "trigger": trigger,
    }

    try:
        r = HTTP_SESSION.get(TICKET_URL, params=params, timeout=1.5)
        print(f"[PRINT] TICKET [{lane}] printed: {r.text.strip()}")
    except requests.exceptions.Timeout:
        print(f"[!] TICKET [{lane}] print timeout - continuing")
    except Exception as e:
        print(f"[X] TICKET [{lane}] print error: {e}")

def delayed_close_if_clear(lane: str, gate: int, delay_sec: float):
    if not AUTO_CLOSE_ENABLED:
        return
    if CLOSE_TIMER_ACTIVE[lane]:
        return

    CLOSE_TIMER_ACTIVE[lane] = True

    def worker():
        try:
            time.sleep(delay_sec)

            st = read_io(lane)
            if st is None:
                print(f"[!] [{lane}] delayed close: IO read failed, skipping")
                return

            loop_mask = int(CONTROLLERS[lane].get("loop_mask", DEFAULT_LOOP_MASK))
            loop_active = bool(st.io_state_2 & loop_mask)

            if loop_active:
                print(f"[LOOP] [{lane}] delayed close: loop still ACTIVE -> keep open")
                return

            print(f"[TIME] [{lane}] delayed close: loop clear -> closing gate {gate}")
            close_and_reset(lane, gate=gate, source="AUTO_DELAY")

        finally:
            CLOSE_TIMER_ACTIVE[lane] = False

    threading.Thread(target=worker, daemon=True).start()

def button_watcher(lane: str):
    lane = lane.upper()
    last = None

    while True:
        st = read_io(lane)
        if st is None:
            print(f"[X] [{lane}] IO read error (watcher) - retrying...")
            time.sleep(1)
            continue

        if last is None:
            last = st
            time.sleep(0.02)
            continue

        cfg = CONTROLLERS[lane]
        loop_mask = int(cfg.get("loop_mask", DEFAULT_LOOP_MASK))
        btn_mask = int(cfg.get("ticket_button_mask", DEFAULT_BUTTON_MASK))
        ticket_gate = int(cfg.get("ticket_gate", 1))

        loop_active = bool(st.io_state_2 & loop_mask)

        old_btn = bool(last.io_state_2 & btn_mask)
        new_btn = bool(st.io_state_2 & btn_mask)

        # unlock button when loop resets OFF
        if (not loop_active) and (not READY_FOR_TICKET[lane]):
            READY_FOR_TICKET[lane] = True
            print(f"[UNLOCK] [{lane}] LOOP reset -> Ticket button enabled again")

        # Rising edge
        if (not old_btn) and new_btn:
            if REQUIRE_LOOP_FOR_TICKET and not loop_active:
                print(f"[!] [{lane}] Button pressed but LOOP not active -> ignore")
            else:
                if not READY_FOR_TICKET[lane]:
                    print(f"[BLOCK] [{lane}] Ticket already issued. Wait for LOOP reset.")
                else:
                    READY_FOR_TICKET[lane] = False
                    print(f"[TICKET] [{lane}] Ticket button -> print + open gate {ticket_gate}")
                    print_ticket(lane, trigger=f"Button-{lane}")
                    do_open(lane, gate=ticket_gate, source="Button")

                    # arm counting
                    ARMED[lane] = True
                    SAW_LOOP[lane] = False

        # count vehicle passing (loop ON then OFF after armed)
        if ARMED[lane]:
            if loop_active:
                SAW_LOOP[lane] = True
            if SAW_LOOP[lane] and (not loop_active):
                IN_COUNT[lane] += 1
                print(f"[PASS] [{lane}] VEHICLE PASSED | COUNT = {IN_COUNT[lane]}")
                ARMED[lane] = False
                SAW_LOOP[lane] = False
                delayed_close_if_clear(lane, gate=ticket_gate, delay_sec=AUTO_CLOSE_DELAY_SEC)

        last = st
        time.sleep(0.02)

def alpr_should_accept(lane: str, gate: int, plate: str, conf01: float) -> bool:
    if conf01 < ALPR_CONF_THRESHOLD:
        return False

    key = f"{lane}:{gate}:{plate}".upper()
    now = time.time()
    last = _last_alpr.get(key, 0.0)

    if now - last < ALPR_DEDUPE_SEC:
        return False

    _last_alpr[key] = now
    return True

# ================= HTTP API =================
class Handler(BaseHTTPRequestHandler):
    protocol_version = "HTTP/1.0"  # disables keep-alive
    timeout = 5                    # socket timeout

    def _send(self, code: int, msg: bytes, content_type="text/plain"):
        try:
            # ✅ Force close this socket after response
            self.close_connection = True

            self.send_response(code)
            self.send_header("Content-Type", content_type)
            self.send_header("Content-Length", str(len(msg)))
            self.send_header("Connection", "close")   # ✅ important
            self.end_headers()
            self.wfile.write(msg)
            try:
                self.wfile.flush()
            except Exception:
                pass
        except (BrokenPipeError, ConnectionResetError, ConnectionAbortedError):
            pass


    def _path_parts(self):
        # remove query string
        clean = self.path.split("?", 1)[0]
        return clean.strip("/").split("/") if clean.strip("/") else []

    # ✅ NEW: PING + HEALTH
    def do_GET(self):
        parts = self._path_parts()
        if len(parts) == 1 and parts[0].lower() == "ping":
            return self._send(200, b"OK")

        if len(parts) == 1 and parts[0].lower() == "health":
            data = {
                "ok": True,
                "time": datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
                "host": HOST,
                "port": API_PORT,
                "controllers": list(CONTROLLERS.keys()),
            }
            return self._send(200, json.dumps(data).encode("utf-8"), content_type="application/json")

        return self._send(404, b"NOT FOUND")

    def do_POST(self):
        # Routes:
        # POST /open/ENTRY/1
        # POST /close/EXIT/1
        # POST /alpr/ENTRY/1   body: {"plate":"ABC123","confidence":0.93,"action":"open"}

        parts = self._path_parts()

        # ---- ALPR ----
        if len(parts) in (2, 3) and parts[0].lower() == "alpr":
            try:
                lane = parts[1].upper()
                raw_gate = parts[2] if len(parts) == 3 else "1"
                raw_gate = raw_gate.strip().replace("%0A", "").replace("\n", "").replace("\r", "")
                gate = int(raw_gate)

                if lane not in CONTROLLERS:
                    known = ",".join(CONTROLLERS.keys()).encode()
                    return self._send(404, b"UNKNOWN CONTROLLER. Known: " + known)

                length = int(self.headers.get("Content-Length", 0))
                body = self.rfile.read(length) if length else b"{}"

                try:
                    payload = json.loads(body.decode("utf-8") or "{}")
                except Exception:
                    payload = {}

                plate = payload.get("plate", "UNKNOWN")
                conf = payload.get("confidence", payload.get("conf", 0))
                action = (payload.get("action", "open") or "open").lower()

                try:
                    conf = float(conf)
                    if conf > 1.0:
                        conf = conf / 100.0
                except Exception:
                    conf = 0.0

                print(f"[ALPR] [{lane}] gate={gate} plate={plate} conf={conf:.2f} action={action}")

                if action == "open":
                    if not alpr_should_accept(lane, gate, plate, conf):
                        if conf < ALPR_CONF_THRESHOLD:
                            return self._send(403, f"LOW CONFIDENCE (need >= {ALPR_CONF_THRESHOLD:.2f})".encode())
                        return self._send(200, b"DUPLICATE IGNORED")

                    do_open(lane, gate=gate, source=f"ALPR:{plate}")
                    ARMED[lane] = True
                    SAW_LOOP[lane] = False
                    return self._send(200, b"OK")

                if action == "close":
                    close_and_reset(lane, gate=gate, source=f"ALPR:{plate}")
                    return self._send(200, b"OK")

                return self._send(400, b"INVALID ACTION (open/close)")

            except Exception as e:
                import traceback
                print("[X] ALPR HANDLER ERROR:")
                traceback.print_exc()
                return self._send(500, f"ERROR: {e}".encode())

        # ---- SIMPLE OPEN/CLOSE ----
        if len(parts) not in (2, 3):
            return self._send(404, b"NOT FOUND")

        action = parts[0].lower()
        lane = parts[1].upper()
        raw_gate = parts[2] if len(parts) == 3 else "1"
        raw_gate = raw_gate.strip().replace("%0A", "").replace("\n", "").replace("\r", "")
        try:
            gate = int(raw_gate)
        except Exception:
            gate = 1

        if lane not in CONTROLLERS:
            known = (",".join(CONTROLLERS.keys())).encode()
            return self._send(404, b"UNKNOWN CONTROLLER. Known: " + known)

        try:
            if action == "open":
                do_open(lane, gate=gate, source="API")
            elif action == "close":
                do_close(lane, gate=gate, source="API")
            else:
                return self._send(400, b"INVALID ACTION (use open/close)")
        except Exception as e:
            import traceback
            print("[X] SIMPLE API ERROR:")
            traceback.print_exc()
            return self._send(500, f"ERROR: {e}".encode())

        return self._send(200, b"OK")

def main():
    print("Barrier daemon (OPEN/CLOSE + TICKET BUTTON) started")
    print(f"Listening: http://{HOST}:{API_PORT}")
    print("Controllers:", ", ".join(CONTROLLERS.keys()))
    print(f"AUTO_CLOSE_ENABLED={AUTO_CLOSE_ENABLED} (delay={AUTO_CLOSE_DELAY_SEC}s)")

    for lane in CONTROLLERS.keys():
        threading.Thread(target=button_watcher, args=(lane,), daemon=True).start()
        print(f"[OK] Watcher started: {lane}")

    server = ThreadingHTTPServer((HOST, API_PORT), Handler)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[X] Stopped by user (Ctrl+C)")
    finally:
        print("[i] Shutting down...")
        try:
            server.shutdown()
        except Exception:
            pass
        try:
            server.server_close()
        except Exception:
            pass
        try:
            np.np3300_sdk_exit()
        except Exception:
            pass
        print("[OK] Clean shutdown complete")

if __name__ == "__main__":
    main()
