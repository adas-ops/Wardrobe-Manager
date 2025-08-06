// lib/helpers/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/outfit.dart';
import '../models/clothing_item.dart'; // Add this import

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
      version: 5, // Incremented version to fix schema
      onCreate: _createDatabase,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          db.execute('ALTER TABLE clothing_items ADD COLUMN isFavorite INTEGER DEFAULT 0');
        }
        if (oldVersion < 3) {
          db.execute('ALTER TABLE clothing_items ADD COLUMN wearCount INTEGER DEFAULT 0');
          db.execute('ALTER TABLE clothing_items ADD COLUMN lastWorn TEXT');
        }
        if (oldVersion < 4) {
          // Create outfits table
          db.execute('''
            CREATE TABLE outfits (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              topId INTEGER NOT NULL,
              bottomId INTEGER NOT NULL,
              shoesId INTEGER,
              accessoryId INTEGER,
              date TEXT NOT NULL,
              FOREIGN KEY(topId) REFERENCES clothing_items(id),
              FOREIGN KEY(bottomId) REFERENCES clothing_items(id),
              FOREIGN KEY(shoesId) REFERENCES clothing_items(id),
              FOREIGN KEY(accessoryId) REFERENCES clothing_items(id)
            )
          ''');
        }
        if (oldVersion < 5) {
          // Fix column name from colorHex to color for consistency
          db.execute('ALTER TABLE clothing_items RENAME COLUMN colorHex TO color');
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
        color TEXT NOT NULL,
        dateAdded TEXT NOT NULL,
        isFavorite INTEGER DEFAULT 0,
        wearCount INTEGER DEFAULT 0,
        lastWorn TEXT
      )
    ''');

    // Create outfits table in initial version
    await db.execute('''
      CREATE TABLE outfits (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        topId INTEGER NOT NULL,
        bottomId INTEGER NOT NULL,
        shoesId INTEGER,
        accessoryId INTEGER,
        date TEXT NOT NULL,
        FOREIGN KEY(topId) REFERENCES clothing_items(id),
        FOREIGN KEY(bottomId) REFERENCES clothing_items(id),
        FOREIGN KEY(shoesId) REFERENCES clothing_items(id),
        FOREIGN KEY(accessoryId) REFERENCES clothing_items(id)
      )
    ''');
  }

  // Add missing methods here
  Future<int> insertClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.insert(
      'clothing_items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ClothingItem>> getAllItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('clothing_items');
    return List.generate(maps.length, (i) => ClothingItem.fromMap(maps[i]));
  }

  Future<int> toggleFavorite(int id, bool isFavorite) async {
    final db = await database;
    return await db.update(
      'clothing_items',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteItem(int id) async {
    final db = await database;
    return await db.delete(
      'clothing_items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateClothingItem(ClothingItem item) async {
    final db = await database;
    return await db.update(
      'clothing_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // Existing outfit methods
  Future<int> insertOutfit(Outfit outfit) async {
    final db = await database;
    return await db.insert('outfits', outfit.toMap());
  }

  Future<List<Outfit>> getAllOutfits() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('outfits');
    return List.generate(maps.length, (i) => Outfit.fromMap(maps[i]));
  }

  // Atomic update for wear count
  Future<int> incrementWearCount(int id) async {
    final db = await database;
    return await db.rawUpdate(
      '''
      UPDATE clothing_items 
      SET wearCount = wearCount + 1, 
          lastWorn = ?
      WHERE id = ?
      ''',
      [DateTime.now().toIso8601String(), id]
    );
  }
}