class Drink {
  const Drink({
    this.id,
    required this.name,
    required this.caffeinePer100ml,
    required this.category,
  });

  final int? id;
  final String name;
  final double caffeinePer100ml;
  final String category;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'caffeine_per_100ml': caffeinePer100ml,
      'category': category,
    };
  }

  factory Drink.fromMap(Map<String, Object?> map) {
    return Drink(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      caffeinePer100ml: (map['caffeine_per_100ml'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String? ?? '',
    );
  }
}
