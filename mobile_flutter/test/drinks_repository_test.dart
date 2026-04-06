import 'package:flutter_test/flutter_test.dart';
import 'package:qhewtek/features/drinks/data/default_drinks.dart';
import 'package:qhewtek/features/drinks/data/drinks_database.dart';
import 'package:qhewtek/features/drinks/data/sqflite_drink_repository.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late DrinksDatabase database;
  late SqfliteDrinkRepository repository;

  setUp(() {
    sqfliteFfiInit();
    database = DrinksDatabase(
      databaseFactoryOverride: databaseFactoryFfi,
      databasePathOverride: inMemoryDatabasePath,
    );
    repository = SqfliteDrinkRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('insertDefaultDrinks seeds the menu only once', () async {
    await repository.insertDefaultDrinks();
    await repository.insertDefaultDrinks();

    final drinks = await repository.getAllDrinks();

    expect(drinks.length, defaultDrinks.length);
    expect(
      drinks.where(
        (drink) => drink.name == 'Espresso' && drink.category == 'Coffee',
      ),
      hasLength(1),
    );
    expect(
      drinks.where(
        (drink) => drink.name == 'Orange Juice' && drink.caffeinePer100ml == 0,
      ),
      hasLength(1),
    );
  });
}
