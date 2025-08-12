import 'dart:io';
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

class _PlannerScreenState extends State<PlannerScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<ClothingItem> _topItems = [];
  List<ClothingItem> _bottomItems = [];
  List<ClothingItem> _shoesItems = [];
  List<ClothingItem> _accessoryItems = [];
  
  ClothingItem? _selectedTop;
  ClothingItem? _selectedBottom;
  ClothingItem? _selectedShoes;
  ClothingItem? _selectedAccessory;
  
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final allItems = await _dbHelper.getAllItems();
    
    setState(() {
      _topItems = allItems.where((item) => item.category == 'Tops').toList();
      _bottomItems = allItems.where((item) => item.category == 'Bottoms').toList();
      _shoesItems = allItems.where((item) => item.category == 'Shoes').toList();
      _accessoryItems = allItems.where((item) => item.category == 'Accessories').toList();
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit saved successfully!')),
      );
      
      setState(() {
        _selectedTop = null;
        _selectedBottom = null;
        _selectedShoes = null;
        _selectedAccessory = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving outfit: $e')),
      );
    }
  }

  Widget _buildCategorySection(String title, List<ClothingItem> items, ClothingItem? selectedItem, ValueChanged<ClothingItem?> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        items.isEmpty
            ? const Text('No items in this category', style: TextStyle(color: Colors.grey))
            : SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => onSelect(item),
                      child: Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selectedItem?.id == item.id 
                                ? Colors.blue 
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClothingCard(
                          item: item,
                          onTap: () => onSelect(item),
                        ),
                      ),
                    );
                  },
                ),
              ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outfit Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveOutfit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Date:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() => _selectedDate = date);
                    }
                  },
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
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
            
            const Text('Preview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            if (_selectedTop != null || _selectedBottom != null || _selectedShoes != null || _selectedAccessory != null)
              Container(
                height: 300,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_selectedTop != null)
                      Image.file(
                        File(_selectedTop!.imagePath),
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    if (_selectedBottom != null)
                      Image.file(
                        File(_selectedBottom!.imagePath),
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    if (_selectedShoes != null)
                      Image.file(
                        File(_selectedShoes!.imagePath),
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    if (_selectedAccessory != null)
                      Image.file(
                        File(_selectedAccessory!.imagePath),
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                  ],
                ),
              )
            else
              const Text('Select items to see preview', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}