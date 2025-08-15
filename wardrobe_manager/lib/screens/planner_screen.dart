import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/models/outfit.dart';
import 'package:wardrobe_manager/widgets/clothing_card.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> with SingleTickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late TabController _tabController;
  
  // Outfit planning state
  List<ClothingItem> _topItems = [];
  List<ClothingItem> _bottomItems = [];
  List<ClothingItem> _shoesItems = [];
  List<ClothingItem> _accessoryItems = [];
  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  ClothingItem? _selectedShoes;
  ClothingItem? _selectedAccessory;
  DateTime _selectedDate = DateTime.now();
  
  // Wardrobe library state
  Map<String, List<ClothingItem>> _wardrobeCategories = {};
  List<String> _categoryNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadItems();
  }

  Future<void> _loadItems() async {
    final allItems = await _dbHelper.getAllItems();
    
    if (!mounted) return;
    
    setState(() {
      // For outfit planning
      _topItems = allItems.where((item) => item.category == 'Tops').toList();
      _bottomItems = allItems.where((item) => item.category == 'Bottoms').toList();
      _shoesItems = allItems.where((item) => item.category == 'Shoes').toList();
      _accessoryItems = allItems.where((item) => item.category == 'Accessories').toList();
      
      // For wardrobe library
      _wardrobeCategories = {};
      for (var item in allItems) {
        if (!_wardrobeCategories.containsKey(item.category)) {
          _wardrobeCategories[item.category] = [];
        }
        _wardrobeCategories[item.category]!.add(item);
      }
      _categoryNames = _wardrobeCategories.keys.toList()..sort();
      
      _isLoading = false;
    });
  }

  Future<void> _saveOutfit() async {
    if (_selectedTop == null || _selectedBottom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least top and bottom')),
      );
      return;
    }

    final outfit = Outfit(
      name: '${_selectedDate.day}-${_selectedDate.month} Outfit',
      topId: _selectedTop!.id!,
      bottomId: _selectedBottom!.id!,
      shoesId: _selectedShoes?.id,
      accessoryId: _selectedAccessory?.id,
      date: _selectedDate.toIso8601String(),
    );

    try {
      await _dbHelper.insertOutfit(outfit);
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved successfully!')),
      );
      
      // Reset selections
      setState(() {
        _selectedTop = null;
        _selectedBottom = null;
        _selectedShoes = null;
        _selectedAccessory = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving outfit: $e')),
      );
    }
  }

  Widget _buildCategorySection(String title, List<ClothingItem> items, ClothingItem? selectedItem, ValueChanged<ClothingItem?> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        items.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No $title available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
              )
            : SizedBox(
                height: 140,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = selectedItem?.id == item.id;
                    
                    return GestureDetector(
                      onTap: () => onSelect(item),
                      child: Container(
                        width: 120,
                        height: 140,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: isSelected ? 2.0 : 0,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Image container
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(10),
                                    ),
                                    child: Container(
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                      constraints: const BoxConstraints.expand(),
                                      child: item.imagePath.isNotEmpty
                                          ? Image.asset(
                                              item.imagePath,
                                              fit: BoxFit.contain,
                                            )
                                          : Icon(
                                              Icons.photo,
                                              size: 48,
                                              color: Theme.of(context).colorScheme.onSurface.withAlpha(77),
                                            ),
                                    ),
                                  ),
                                ),
                                // Text container
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                  constraints: const BoxConstraints(
                                    minHeight: 40,
                                    maxHeight: 40,
                                  ),
                                  child: Text(
                                    item.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            // Selection badge
                            if (isSelected)
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildOutfitPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          if (_selectedTop != null) _buildPreviewItem(_selectedTop!, 'Top'),
          if (_selectedBottom != null) _buildPreviewItem(_selectedBottom!, 'Bottom'),
          if (_selectedShoes != null) _buildPreviewItem(_selectedShoes!, 'Shoes'),
          if (_selectedAccessory != null) _buildPreviewItem(_selectedAccessory!, 'Accessory'),
          if (_selectedTop == null && _selectedBottom == null && 
             _selectedShoes == null && _selectedAccessory == null)
            Column(
              children: [
                Icon(
                  Icons.checkroom, 
                  size: 36,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select items to see outfit preview',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(ClothingItem item, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWardrobeLibrary() {
    if (_wardrobeCategories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom, 
              size: 48,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(102),
            ),
            const SizedBox(height: 12),
            Text(
              'No clothing items found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12),
      itemCount: _categoryNames.length,
      itemBuilder: (context, index) {
        final category = _categoryNames[index];
        final items = _wardrobeCategories[category]!;
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemCount: items.length,
                itemBuilder: (context, itemIndex) {
                  final item = items[itemIndex];
                  return ClothingCard(item: item);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Planner', style: TextStyle(fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorColor: Theme.of(context).colorScheme.primary,
          labelStyle: const TextStyle(fontWeight: FontWeight.w500),
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withAlpha(153),
          tabs: const [
            Tab(icon: Icon(Icons.calendar_month), text: 'Plan'), 
            Tab(icon: Icon(Icons.checkroom), text: 'Wardrobe'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            const Text(
                              'Date:',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null && mounted) {
                                  setState(() => _selectedDate = date);
                                }
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.edit_calendar, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Build Your Outfit',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.save, size: 16),
                              label: const Text('Save Outfit', style: TextStyle(fontSize: 12)),
                              onPressed: _saveOutfit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                _buildCategorySection(
                  'Tops',
                  _topItems,
                  _selectedTop,
                  (item) => setState(() => _selectedTop = item),
                ),
                
                _buildCategorySection(
                  'Bottoms',
                  _bottomItems,
                  _selectedBottom,
                  (item) => setState(() => _selectedBottom = item),
                ),
                
                _buildCategorySection(
                  'Shoes',
                  _shoesItems,
                  _selectedShoes,
                  (item) => setState(() => _selectedShoes = item),
                ),
                
                _buildCategorySection(
                  'Accessories',
                  _accessoryItems,
                  _selectedAccessory,
                  (item) => setState(() => _selectedAccessory = item),
                ),
                
                const SizedBox(height: 16),
                const Text(
                  'Outfit Preview',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildOutfitPreview(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          
          _buildWardrobeLibrary(),
        ],
      ),
    );
  }
}