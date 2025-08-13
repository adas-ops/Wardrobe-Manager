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
        title: const Text('Wardrobe', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter items',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            ).then((_) => _loadItems(_searchQuery)),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by name',
                hintText: 'Enter item name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                _searchQuery = value;
                _loadItems(_searchQuery);
              },
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ClothingCard(
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
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checkroom_outlined, 
              size: 64, 
              color: Theme.of(context).disabledColor),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty && _selectedCategory == 'All'
                ? 'Your wardrobe is empty'
                : 'No matching items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty && _selectedCategory == 'All'
                ? 'Add your first item to get started'
                : 'Try adjusting your search or filters',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isEmpty && _selectedCategory == 'All')
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement navigation to add item screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Add First Item'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Options', 
                          style: Theme.of(context).textTheme.titleLarge),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Category', 
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  CategoryFilter(
                    selectedCategory: _selectedCategory,
                    categories: _getCategories(),
                    onCategorySelected: (category) {
                      setModalState(() => _selectedCategory = category);
                    },
                  ),
                  const SizedBox(height: 24),
                  Text('Sort By', 
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _buildSortOptions(setModalState),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _loadItems(_searchQuery);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                  const SizedBox(height: 8),
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
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
    );
  }
}