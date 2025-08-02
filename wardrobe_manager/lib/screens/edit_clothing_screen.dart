import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/widgets/advanced_color_picker.dart';

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
    _selectedColor = Color(int.parse(widget.item.colorHex, radix: 16));
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
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
        colorHex: _selectedColor.value.toRadixString(16),
        dateAdded: widget.item.dateAdded,
        isFavorite: widget.item.isFavorite,
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
                  GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _selectedImage != null
                          ? Image.file(_selectedImage!, fit: BoxFit.cover)
                          : const Center(child: Text('No image selected')),
                    ),
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