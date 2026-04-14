import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static late Database _db;
  static final Map<String, dynamic> _memoryCache = {}; 

  static Future<void> init() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = join(appDocDir.path, 'luvpark.db');

    _db = await databaseFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: 2,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE app_state(
              key TEXT PRIMARY KEY,
              value TEXT
            )
          ''');
          
          await db.execute('''
            CREATE TABLE tickets(
              id TEXT PRIMARY KEY,
              plate TEXT,
              timeIn TEXT,
              timeOut TEXT,
              zone TEXT,
              vehicleClass TEXT,
              status TEXT,
              gate TEXT
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
             await db.execute('ALTER TABLE tickets ADD COLUMN gate TEXT;');
          }
        },
      ),
    );

    await _preloadCache();
  }

  // --- MEMORY CACHE WRAPPERS FOR SYNCHRONOUS UI ---

  static Future<void> _preloadCache() async {
    final List<Map<String, dynamic>> rows = await _db.query('app_state');
    for (var row in rows) {
      final key = row['key'] as String;
      final value = row['value'] as String;
      try {
        _memoryCache[key] = jsonDecode(value);
      } catch (e) {
        _memoryCache[key] = value;
      }
    }
  }

  static Future<void> saveState(String key, dynamic value) async {
    _memoryCache[key] = value;
    final valueString = jsonEncode(value);
    await _db.insert(
      'app_state',
      {'key': key, 'value': valueString},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static dynamic getState(String key) {
    return _memoryCache[key];
  }

  static Future<void> deleteState(String key) async {
    _memoryCache.remove(key);
    await _db.delete('app_state', where: 'key = ?', whereArgs: [key]);
  }

  static Future<void> eraseAll() async {
    _memoryCache.clear();
    await _db.delete('app_state');
    await _db.delete('tickets');
  }

  // --- TEST DATA SEEDING ---

  static Future<void> seedTestTickets() async {
    final now = DateTime.now();

    // Generate IDs matching the addTicket() format: #${millis.substring(5)}
    String generateId(int offsetMs) {
      final ms = (now.millisecondsSinceEpoch - offsetMs).toString();
      return '#${ms.substring(5)}';
    }

    // Scenario 1: Short stay (1 hour ago) — should trigger Base Rate
    final shortStay = now.subtract(const Duration(hours: 1));

    // Scenario 2: Extended stay (5 hours ago) — should trigger Succeeding Rates
    final longStay = now.subtract(const Duration(hours: 5));

    // Scenario 3: Overnight stay (28 hours ago) — should trigger Overnight + Succeeding
    final overnightStay = now.subtract(const Duration(hours: 28));

    List<Map<String, dynamic>> testTickets = [
      {
        'id': generateId(0),
        'plate': 'ABC-1234',
        'timeIn': shortStay.toIso8601String(),
        'timeOut': null,
        'zone': 'LEVEL_A',
        'vehicleClass': 'CAR',
        'status': 'active',
      },
      {
        'id': generateId(1),
        'plate': 'XYZ-9876',
        'timeIn': longStay.toIso8601String(),
        'timeOut': null,
        'zone': 'LEVEL_B',
        'vehicleClass': 'SUV',
        'status': 'overstay',
      },
      {
        'id': generateId(2),
        'plate': 'DEF-4567',
        'timeIn': overnightStay.toIso8601String(),
        'timeOut': null,
        'zone': 'LEVEL_A',
        'vehicleClass': 'VAN',
        'status': 'overstay',
      },
    ];

    for (var ticket in testTickets) {
      await _db.insert(
        'tickets',
        ticket,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    debugPrint('✅ Test tickets seeded: Base(1h/LEVEL_A), Succeeding(5h/LEVEL_B), Overnight(28h/LEVEL_A)');
  }

  // --- TICKETS REPOSITORY ---

  static Database get instance => _db;
}
