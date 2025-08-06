// Add these methods to your ClothingItem class

class ClothingItem {
  // Your existing properties here...
  final int? id;
  final String name;
  final String category;
  final String imagePath;
  final String color; // hex color string like "#FF0000"
  final DateTime dateAdded;
  final bool isFavorite;
  final int wearCount;
  final DateTime? lastWorn;

  // Constructor
  ClothingItem({
    this.id,
    required this.name,
    required this.category,
    required this.imagePath,
    required this.color,
    required this.dateAdded,
    this.isFavorite = false,
    required this.wearCount,
    this.lastWorn,
  });

  // Add this getter for backward compatibility
  String get colorHex => color;

  // Convert ClothingItem to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'imagePath': imagePath,
      'color': color, // Now matches database column name
      'dateAdded': dateAdded.toIso8601String(),
      'isFavorite': isFavorite ? 1 : 0, // SQLite stores bools as integers
      'wearCount': wearCount,
      'lastWorn': lastWorn?.toIso8601String(),
    };
  }

  // Create ClothingItem from Map (database result)
  static ClothingItem fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      imagePath: map['imagePath'],
      color: map['color'], // Now matches database column name
      dateAdded: DateTime.parse(map['dateAdded']),
      isFavorite: map['isFavorite'] == 1, // Convert integer back to bool
      wearCount: map['wearCount'],
      lastWorn: map['lastWorn'] != null ? DateTime.parse(map['lastWorn']) : null,
    );
  }

  // Create a copy with modified fields (useful for updates)
  ClothingItem copyWith({
    int? id,
    String? name,
    String? category,
    String? imagePath,
    String? color,
    DateTime? dateAdded,
    bool? isFavorite,
    int? wearCount,
    DateTime? lastWorn,
  }) {
    return ClothingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imagePath: imagePath ?? this.imagePath,
      color: color ?? this.color,
      dateAdded: dateAdded ?? this.dateAdded,
      isFavorite: isFavorite ?? this.isFavorite,
      wearCount: wearCount ?? this.wearCount,
      lastWorn: lastWorn ?? this.lastWorn,
    );
  }
}