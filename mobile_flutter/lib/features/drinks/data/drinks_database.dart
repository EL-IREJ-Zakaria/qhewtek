import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DrinksDatabase {
  DrinksDatabase({
    DatabaseFactory? databaseFactoryOverride,
    String databaseName = 'caffeine_tracker.db',
    String? databasePathOverride,
  }) : _databaseFactoryOverride = databaseFactoryOverride,
       _databaseName = databaseName,
       _databasePathOverride = databasePathOverride;

  static const tableName = 'Drinks';

  final DatabaseFactory? _databaseFactoryOverride;
  final String _databaseName;
  final String? _databasePathOverride;

  Database? _database;

  Future<Database> open() async {
    if (_database != null) {
      return _database!;
    }

    final databaseFactoryInstance =
        _databaseFactoryOverride ?? _resolveDatabaseFactory();
    final databasePath =
        _databasePathOverride ??
        p.join(await databaseFactoryInstance.getDatabasesPath(), _databaseName);

    _database = await databaseFactoryInstance.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $tableName(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              caffeine_per_100ml REAL NOT NULL,
              category TEXT NOT NULL
            )
          ''');
          await db.execute(
            'CREATE UNIQUE INDEX idx_drinks_name_category '
            'ON $tableName(name, category)',
          );
        },
      ),
    );

    return _database!;
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  DatabaseFactory _resolveDatabaseFactory() {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.linux)) {
      sqfliteFfiInit();
      return databaseFactoryFfi;
    }

    return databaseFactory;
  }
}
