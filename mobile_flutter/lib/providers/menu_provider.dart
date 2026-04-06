import 'package:flutter/foundation.dart';

import '../models/menu_item.dart';
import '../services/menu_service.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider(this._menuService);

  final MenuService _menuService;
  final Set<int> _busyItemIds = <int>{};

  List<MenuItem> _items = const [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  List<MenuItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  Set<int> get busyItemIds => _busyItemIds;

  Future<void> loadMenuItems({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      _items = await _menuService.fetchMenu();
      _items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addMenuItem({
    required String name,
    required String description,
    required double price,
    required String category,
    required bool available,
    String? imagePath,
    String? imageValue,
  }) async {
    _isSaving = true;
    notifyListeners();

    try {
      final item = await _menuService.addMenuItem(
        name: name,
        description: description,
        price: price,
        category: category,
        available: available,
        imagePath: imagePath,
        imageValue: imageValue,
      );

      _items = [..._items, item]
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> updateMenuItem({
    required int id,
    required String name,
    required String description,
    required double price,
    required String category,
    required bool available,
    String? imagePath,
    String? imageValue,
  }) async {
    _busyItemIds.add(id);
    notifyListeners();

    try {
      final item = await _menuService.updateMenuItem(
        id: id,
        name: name,
        description: description,
        price: price,
        category: category,
        available: available,
        imagePath: imagePath,
        imageValue: imageValue,
      );

      _items =
          _items.map((existing) => existing.id == id ? item : existing).toList()
            ..sort(
              (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
            );
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _busyItemIds.remove(id);
      notifyListeners();
    }
  }

  Future<void> toggleAvailability(MenuItem item) async {
    await updateMenuItem(
      id: item.id,
      name: item.name,
      description: item.description,
      price: item.price,
      category: item.category,
      available: !item.available,
      imageValue: item.image,
    );
  }

  Future<void> deleteMenuItem(int id) async {
    _busyItemIds.add(id);
    notifyListeners();

    try {
      await _menuService.deleteMenuItem(id);
      _items = _items.where((item) => item.id != id).toList();
      _errorMessage = null;
    } catch (error) {
      _errorMessage = error.toString();
      rethrow;
    } finally {
      _busyItemIds.remove(id);
      notifyListeners();
    }
  }
}
