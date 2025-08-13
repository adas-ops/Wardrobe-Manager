import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/widgets/advanced_color_picker.dart';
import 'package:wardrobe_manager/widgets/photo_picker.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _selectedImage;
  Color _selectedColor = Colors.blue;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isSaving = false;

  // Helper method to convert Color to hex string
  String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0')}';
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty || 
        _categoryController.text.isEmpty || 
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and pick an image')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final item = ClothingItem(
        name: _nameController.text,
        category: _categoryController.text,
        imagePath: _selectedImage!.path,
        color: colorToHex(_selectedColor),
        dateAdded: DateTime.now(),
        wearCount: 0,
      );
      
      await _dbHelper.insertClothingItem(item);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clothing item saved!')),
      );
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving item: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Item', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: Theme.of(context).colorScheme.primary),
            onPressed: _isSaving ? null : _saveItem,
          )
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                children: [
                  const SizedBox(height: 16),
                  PhotoPicker(
                    selectedImage: _selectedImage,
                    onImageSelected: (image) => setState(() => _selectedImage = image),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      hintText: 'e.g., Blue Denim Jacket',
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      hintText: 'e.g., Jackets, Pants, Shoes',
                      filled: true,
                      fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Item Color:',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 12),
                  AdvancedColorPicker(
                    selectedColor: _selectedColor,
                    onColorSelected: (color) => setState(() => _selectedColor = color),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Save Item', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    super.dispose();
  }
}