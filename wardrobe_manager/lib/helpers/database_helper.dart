import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/clothing_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wardrobe.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clothing_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        imagePath TEXT
      )
    ''');
  }

  Future<int> insertClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.insert('clothing_items', item.toMap());
  }

  Future<List<ClothingItem>> getAllItems() async {
    final db = await database;
    final maps = await db.query('clothing_items');
    return maps.map((map) => ClothingItem.fromMap(map)).toList();
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete('clothing_items', where: 'id = ?', whereArgs: [id]);
  }
}
