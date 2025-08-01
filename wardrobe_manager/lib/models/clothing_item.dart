class ClothingItem {
  final int? id;
  final String name;
  final String category;
  final String imagePath;
  final String colorHex; // ✅ This is the new field

  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.colorHex, // ✅ Mark it required
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'colorHex': colorHex, // ✅ Store in database
    };
  }

  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      imagePath: map['imagePath'],
      colorHex: map['colorHex'], // ✅ Load from database
    );
  }
}
