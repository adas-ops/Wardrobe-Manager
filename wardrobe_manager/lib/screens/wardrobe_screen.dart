import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/models/settings.dart';
import 'package:wardrobe_manager/screens/settings_screen.dart';
import 'package:wardrobe_manager/screens/item_detail_screen.dart';
import 'package:wardrobe_manager/widgets/category_filter.dart';
import 'package:wardrobe_manager/widgets/clothing_card.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<ClothingItem> _items = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late AppSettings _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings = Provider.of<AppSettings>(context, listen: false);
    _loadItems();
  }

  Future<void> _loadItems([String query = '']) async {
    final data = await _dbHelper.getAllItems();
    
    // Apply sorting based on settings
    List<ClothingItem> sortedItems = [...data];
    switch (_settings.sortOption) {
      case 'newest':
        sortedItems.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'name':
        sortedItems.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'category':
        sortedItems.sort((a, b) => a.category.compareTo(b.category));
        break;
      case 'most_worn':
        sortedItems.sort((a, b) => b.wearCount.compareTo(a.wearCount));
        break;
    }
    
    if (!mounted) return;
    
    setState(() {
      _items = sortedItems.where((item) {
        final matchesQuery = item.name.toLowerCase().contains(query.toLowerCase());
        final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wardrobe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadItems(_searchQuery)),
          ),
        ],
      ),
      body: Column(
        children: [
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
                      return ClothingCard(
                        item: item,
                        onTap: () async {
                          final shouldRefresh = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ItemDetailScreen(item: item),
                            ),
                          );
                          if (shouldRefresh == true && mounted) {
                            _loadItems(_searchQuery);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Filter Options', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  CategoryFilter(
                    selectedCategory: _selectedCategory,
                    categories: _getCategories(),
                    onCategorySelected: (category) {
                      setModalState(() => _selectedCategory = category);
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildSortOptions(setModalState),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadItems(_searchQuery);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<String> _getCategories() {
    final categories = _items.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  Widget _buildSortOptions(StateSetter setModalState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort By:', style: TextStyle(fontSize: 16)),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Newest'),
              selected: _settings.sortOption == 'newest',
              onSelected: (selected) {
                setModalState(() {
                  _settings.updateSettings(sortOption: 'newest');
                });
              },
            ),
            ChoiceChip(
              label: const Text('Name'),
              selected: _settings.sortOption == 'name',
              onSelected: (selected) {
                setModalState(() {
                  _settings.updateSettings(sortOption: 'name');
                });
              },
            ),
            ChoiceChip(
              label: const Text('Category'),
              selected: _settings.sortOption == 'category',
              onSelected: (selected) {
                setModalState(() {
                  _settings.updateSettings(sortOption: 'category');
                });
              },
            ),
            ChoiceChip(
              label: const Text('Most Worn'),
              selected: _settings.sortOption == 'most_worn',
              onSelected: (selected) {
                setModalState(() {
                  _settings.updateSettings(sortOption: 'most_worn');
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}