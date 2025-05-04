class Category {
  final String id;
  final String name;
  final String icon;
  final int colorValue;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
      colorValue: map['colorValue'],
    );
  }
}