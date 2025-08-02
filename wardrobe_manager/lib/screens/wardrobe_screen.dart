import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/screens/edit_clothing_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<ClothingItem> _items = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  List<String> _categories = ['All'];
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems([String query = '']) async {
    final data = await _dbHelper.getAllItems();
    
    // Extract unique categories
    final uniqueCategories = data.map((e) => e.category).toSet().toList();
    uniqueCategories.sort();
    
    setState(() {
      _categories = ['All', ...uniqueCategories];
      _items = data.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() => _selectedCategory = cat);
                      _loadItems(_searchQuery);
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search by name',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _loadItems(_searchQuery);
              },
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.checkroom, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No clothing items found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
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
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Color(int.parse(item.colorHex, radix: 16)),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.star,
                                  color: item.isFavorite ? Colors.amber : Colors.grey,
                                ),
                                onPressed: () async {
                                  await _dbHelper.toggleFavorite(item.id!, !item.isFavorite);
                                  _loadItems(_searchQuery);
                                },
                              ),
                            ],
                          ),
                          onTap: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditClothingScreen(item: item),
                              ),
                            );
                            if (changed == true) {
                              _loadItems(_searchQuery);
                            }
                          },
                          onLongPress: () => _confirmDelete(item.id!),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbHelper.deleteItem(id);
              Navigator.pop(context);
              _loadItems(_searchQuery);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted successfully')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}