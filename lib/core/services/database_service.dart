import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

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
        version: 1,
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
              status TEXT
            )
          ''');
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

  // --- TICKETS REPOSITORY ---

  static Database get instance => _db;
}
