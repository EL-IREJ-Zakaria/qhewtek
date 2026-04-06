import '../models/drink.dart';

abstract class DrinkRepository {
  Future<void> insertDefaultDrinks();
  Future<List<Drink>> getAllDrinks();
  Future<bool> isEmpty();
}
