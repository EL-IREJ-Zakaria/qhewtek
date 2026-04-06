import 'package:sqflite/sqflite.dart';

import '../domain/drink_repository.dart';
import '../models/drink.dart';
import 'default_drinks.dart';
import 'drinks_database.dart';

class SqfliteDrinkRepository implements DrinkRepository {
  SqfliteDrinkRepository(this._database);

  final DrinksDatabase _database;

  @override
  Future<bool> isEmpty() async {
    final db = await _database.open();
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${DrinksDatabase.tableName}'),
    );

    return (count ?? 0) == 0;
  }

  @override
  Future<List<Drink>> getAllDrinks() async {
    final db = await _database.open();
    final rows = await db.query(
      DrinksDatabase.tableName,
      orderBy: 'category ASC, name ASC',
    );

    return rows.map(Drink.fromMap).toList();
  }

  @override
  Future<void> insertDefaultDrinks() async {
    final db = await _database.open();

    if (!await isEmpty()) {
      return;
    }

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final drink in defaultDrinks) {
        batch.insert(DrinksDatabase.tableName, {
          'name': drink.name,
          'caffeine_per_100ml': drink.caffeinePer100ml,
          'category': drink.category,
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }

      await batch.commit(noResult: true);
    });
  }
}
