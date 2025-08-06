import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/widgets/advanced_color_picker.dart';
import 'package:wardrobe_manager/widgets/photo_picker.dart';

class EditClothingScreen extends StatefulWidget {
  final ClothingItem item;

  const EditClothingScreen({super.key, required this.item});

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  File? _selectedImage;
  late Color _selectedColor;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _selectedImage = File(widget.item.imagePath);
    // Convert hex string back to Color
    _selectedColor = Color(int.parse(widget.item.color.replaceFirst('#', ''), radix: 16));
  }

  Future<void> _saveItem() async {
    if (_nameController.text.isEmpty || 
        _categoryController.text.isEmpty || 
        _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _isSaving = true);
    
    try {
      final updatedItem = ClothingItem(
        id: widget.item.id,
        name: _nameController.text,
        category: _categoryController.text,
        imagePath: _selectedImage!.path,
        color: '#${_selectedColor.value.toRadixString(16).padLeft(8, '0')}', // Convert Color to hex string
        dateAdded: widget.item.dateAdded,
        isFavorite: widget.item.isFavorite,
        wearCount: widget.item.wearCount,
        lastWorn: widget.item.lastWorn,
      );
      
      await _dbHelper.updateClothingItem(updatedItem);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clothing item updated!')),
      );
      
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating item: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Clothing Item'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveItem,
          )
        ],
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  PhotoPicker(
                    selectedImage: _selectedImage,
                    onImageSelected: (image) => setState(() => _selectedImage = image),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _categoryController,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AdvancedColorPicker(
                    selectedColor: _selectedColor,
                    onColorSelected: (color) => setState(() => _selectedColor = color),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Save Changes'),
                  ),
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