import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/clothing_item.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static DatabaseHelper get instance => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'wardrobe.db');

    return await openDatabase(
      path,
      version: 3, // Increment version to trigger migration
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clothing_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        imagePath TEXT NOT NULL,
        colorHex TEXT NOT NULL DEFAULT 'FF0000FF',
        dateAdded TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE clothing_items ADD COLUMN colorHex TEXT DEFAULT "FF0000FF"');
    }
    if (oldVersion < 3) {
      // Add dateAdded column with default value
      await db.execute('ALTER TABLE clothing_items ADD COLUMN dateAdded TEXT');
      
      // Set default value for existing records
      final now = DateTime.now().toIso8601String();
      await db.update(
        'clothing_items',
        {'dateAdded': now},
        where: 'dateAdded IS NULL',
      );
    }
  }

  Future<int> insertClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.insert('clothing_items', item.toMap());
  }

  Future<List<ClothingItem>> getClothingItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clothing_items');
    
    return List.generate(maps.length, (i) {
      return ClothingItem.fromMap(maps[i]);
    });
  }

  Future<List<ClothingItem>> getAllItems() async {
    return await getClothingItems();
  }

  Future<void> deleteClothingItem(int id) async {
    final db = await database;
    await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteItem(int id) async {
    return await deleteClothingItem(id);
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    final db = await database;
    await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<ClothingItem?> getClothingItemById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ClothingItem.fromMap(maps.first);
    }
    return null;
  }

  Future<void> closeDatabase() async {
    final db = _database;
    if (db != null) {
      await db.close();
    }
  }
}