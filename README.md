# LuvPark (parking_app)

LuvPark is a Flutter-based parking management system and System Access Portal designed to integrate with automated hardware (ALPR cameras, barrier arms) via a local Python hardware daemon. 

## Overview

The application serves as the central UI for parking operators, handling vehicle entry, ticket inspection, device registration, and zone configuration. It features a modern desktop-first architecture built with Flutter, using GetX for state management and SQLite for local data persistence.

## Key Features

- **Hardware Daemon Integration:** Automatically launches and monitors a local Python process (`hardware_daemon.exe`) for interacting with ALPR (Automatic License Plate Recognition) models and edge hardware.
- **Ticket Entry & Inspector:** Manages vehicle logging (Class A/B/C) and calculates rates based on duration (base rate, succeeding hours, overnight stays).
- **Zone Setup:** Configuration for different parking zones (e.g., LEVEL_A, LEVEL_B).
- **Review ARM (Automated Recognition Module):** Interface for operators to review flagged or ambiguous license plate scans from the ALPR pipeline.
- **Local Persistence:** Uses `sqflite_common_ffi` to maintain an offline-first SQLite database (`luvpark.db`) for storing active tickets and application state.
- **Device Registration:** Binds the current terminal instance to the broader system network.

## Technology Stack

- **Framework:** Flutter (Desktop/Windows Native)
- **State Management & Routing:** GetX
- **Database:** `sqflite` (with FFI for desktop support)
- **Styling:** Google Fonts (Inter), custom theming

## Architecture

The project follows a modular, feature-first structure under `lib/modules`:

- `config_setup` - System configuration settings.
- `dashboard` - Main system overview and active statistics.
- `device_registration` - Terminal onboarding.
- `login` - Operator authentication portal.
- `review_arm` - ALPR manual review interface.
- `splash` - System initialization and daemon bootstrap.
- `ticket_entry` - Manual or semi-automated ticket generation.
- `ticket_inspector` - Rate calculation and vehicle checkout.
- `zone_setup` - Parking zone management.

## Getting Started

### Prerequisites

- Flutter SDK (^3.11.4)
- Python Hardware Daemon (must be placed in `hardware_api\hardware_daemon.exe` relative to the executable or CWD).

### Running Locally

```bash
flutter pub get
flutter run -d windows
```

### Logging
System events, including hardware daemon stdout/stderr, are logged automatically to `luvpark_system.log` in the root directory.
