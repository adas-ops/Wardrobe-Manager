// lib/screens/wardrobe_screen.dart
import 'dart:io'; 
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
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
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey(); // Add this key

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems([String query = '']) async {
    try {
      final data = await DatabaseHelper.instance.getAllItems();
      if (mounted) {
        setState(() {
          _items = data.where((item) {
            final matchesQuery = item.name.toLowerCase().contains(query.toLowerCase());
            final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
            return matchesQuery && matchesCategory;
          }).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        // Use scaffold messenger key instead of context
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text('Error loading items: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['All', 'Shirt', 'Pants', 'Shoes', 'Accessories'];

    return ScaffoldMessenger( // Wrap with ScaffoldMessenger
      key: _scaffoldMessengerKey,
      child: Column(
        children: [
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat == _selectedCategory;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedCategory = cat;
                      });
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
                          trailing: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(int.parse(item.colorHex, radix: 16)),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                          onTap: () async {
                            final changed = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditClothingScreen(item: item),
                              ),
                            );
                            if (changed == true && mounted) {
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
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Item'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await DatabaseHelper.instance.deleteItem(id);
                
                // Close dialog first
                Navigator.pop(dialogContext);
                
                // Check if widget is still mounted
                if (!mounted) return;
                
                // Refresh the list
                _loadItems();
                
                // Show success message using the key
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(content: Text('Item deleted successfully')),
                );
              } catch (e) {
                // Close dialog on error
                Navigator.pop(dialogContext);
                
                // Check if widget is still mounted
                if (!mounted) return;
                
                // Show error message using the key
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(content: Text('Error deleting item: $e')),
                );
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }  
}