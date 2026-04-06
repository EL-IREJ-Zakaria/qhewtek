import 'package:flutter/foundation.dart';

import '../data/drinks_database.dart';
import '../data/sqflite_drink_repository.dart';
import '../domain/drink_repository.dart';

class DrinksBootstrap {
  static Future<DrinkRepository?> initializeIfSupported() async {
    if (kIsWeb) {
      return null;
    }

    final repository = SqfliteDrinkRepository(DrinksDatabase());
    await repository.insertDefaultDrinks();
    return repository;
  }
}
