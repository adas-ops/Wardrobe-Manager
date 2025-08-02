import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/clothing_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wardrobe.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE clothing_items ADD COLUMN isFavorite INTEGER DEFAULT 0');
        }
      },
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clothing_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        colorHex TEXT NOT NULL,
        dateAdded TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertClothingItem(ClothingItem item) async {
    final db = await instance.database;
    return await db.insert('clothing_items', item.toMap());
  }

  Future<List<ClothingItem>> getAllItems() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('clothing_items');
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  Future<List<ClothingItem>> getFavorites() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'isFavorite = ?',
      whereArgs: [1],
    );
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  Future<int> deleteItem(int id) async {
    final db = await instance.database;
    return await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateClothingItem(ClothingItem item) async {
    final db = await instance.database;
    return await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await instance.database;
    return await db.update(
      'clothing_items',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}