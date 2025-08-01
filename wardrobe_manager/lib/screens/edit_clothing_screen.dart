import 'dart:io';
import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import '../helpers/database_helper.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _selectedImage = File(widget.item.imagePath);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _saveChanges() async {
    final name = _nameController.text.trim();
    final category = _categoryController.text.trim();
    if (name.isEmpty || category.isEmpty || _selectedImage == null) return;

    final updated = ClothingItem(
      id: widget.item.id,
      name: name,
      category: category,
      imagePath: _selectedImage!.path,
    );

    await DatabaseHelper.instance.updateClothingItem(updated); // uses same method for insert/update
    if (context.mounted) Navigator.pop(context, true); // return to previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Clothing Item')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Clothing Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _pickImage, child: const Text('Change Image')),
            if (_selectedImage != null) ...[
              const SizedBox(height: 16),
              Image.file(_selectedImage!, height: 200),
            ],
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _saveChanges, child: const Text('Save Changes')),
          ],
        ),
      ),
    );
  }
}
