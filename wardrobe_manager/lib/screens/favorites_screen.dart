import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/screens/edit_clothing_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<ClothingItem> _favorites = [];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _dbHelper.getFavorites();
    setState(() => _favorites = favorites);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: _favorites.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorite items yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, index) {
                final item = _favorites[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(item.imagePath),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.category),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.star,
                        color: item.isFavorite ? Colors.amber : Colors.grey,
                      ),
                      onPressed: () async {
                        await _dbHelper.toggleFavorite(item.id!, !item.isFavorite);
                        _loadFavorites();
                      },
                    ),
                    onTap: () async {
                      final changed = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditClothingScreen(item: item),
                        ),
                      );
                      if (changed == true) {
                        _loadFavorites();
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}