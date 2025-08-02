class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String imagePath;
  final String colorHex;
  final String dateAdded;
  final bool isFavorite;

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.colorHex,
    required this.dateAdded,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'colorHex': colorHex,
      'dateAdded': dateAdded,
      'isFavorite': isFavorite ? 1 : 0,
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      imagePath: map['imagePath'],
      colorHex: map['colorHex'],
      dateAdded: map['dateAdded'],
      isFavorite: map['isFavorite'] == 1,
    );
  }
}