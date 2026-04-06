import '../models/menu_item.dart';
import 'api_service.dart';

class MenuService {
  const MenuService(this._apiService);

  final ApiService _apiService;

  Future<List<MenuItem>> fetchMenu({bool includeUnavailable = true}) async {
    final response = await _apiService.get(
      '/menu',
      queryParameters: {'include_unavailable': includeUnavailable ? '1' : '0'},
    );

    final rawItems = response['data']?['items'] as List<dynamic>? ?? [];

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(MenuItem.fromJson)
        .toList();
  }

  Future<MenuItem> addMenuItem({
    required String name,
    required String description,
    required double price,
    required String category,
    required bool available,
    String? imagePath,
    String? imageValue,
  }) async {
    final response = await _apiService.postMultipart(
      '/menu/add',
      fields: {
        'name': name,
        'description': description,
        'price': price.toStringAsFixed(2),
        'category': category,
        'available': available.toString(),
        if ((imageValue ?? '').trim().isNotEmpty) 'image': imageValue!.trim(),
      },
      filePath: imagePath,
    );

    return MenuItem.fromJson(
      response['data']?['item'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<MenuItem> updateMenuItem({
    required int id,
    required String name,
    required String description,
    required double price,
    required String category,
    required bool available,
    String? imagePath,
    String? imageValue,
  }) async {
    final response = await _apiService.postMultipart(
      '/menu/update',
      fields: {
        'id': '$id',
        'name': name,
        'description': description,
        'price': price.toStringAsFixed(2),
        'category': category,
        'available': available.toString(),
        if ((imageValue ?? '').trim().isNotEmpty) 'image': imageValue!.trim(),
      },
      filePath: imagePath,
    );

    return MenuItem.fromJson(
      response['data']?['item'] as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<void> deleteMenuItem(int id) async {
    await _apiService.post('/menu/delete', body: {'id': id});
  }
}
