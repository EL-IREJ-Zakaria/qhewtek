class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.available,
    this.image,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final bool available;
  final String? image;
  final String? imageUrl;

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: _asInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: _asDouble(json['price']),
      category: (json['category'] ?? '').toString(),
      available: _asBool(json['available']),
      image: json['image']?.toString(),
      imageUrl: json['image_url']?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }

  static double _asDouble(dynamic value) {
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse('$value') ?? 0;
  }

  static bool _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value == 1;
    }
    return '$value'.toLowerCase() == 'true';
  }
}
