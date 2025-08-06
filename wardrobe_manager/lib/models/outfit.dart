class Outfit {
  final int? id;
  final String name;
  final int topId;
  final int bottomId;
  final int? shoesId;
  final int? accessoryId;
  final String date;

  Outfit({
    this.id,
    required this.name,
    required this.topId,
    required this.bottomId,
    this.shoesId,
    this.accessoryId,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'topId': topId,
      'bottomId': bottomId,
      'shoesId': shoesId,
      'accessoryId': accessoryId,
      'date': date,
    };
  }

  factory Outfit.fromMap(Map<String, dynamic> map) {
    return Outfit(
      id: map['id'],
      name: map['name'],
      topId: map['topId'],
      bottomId: map['bottomId'],
      shoesId: map['shoesId'],
      accessoryId: map['accessoryId'],
      date: map['date'],
    );
  }
}