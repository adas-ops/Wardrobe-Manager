import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/widgets/image_viewer.dart';

class EditClothingScreen extends StatefulWidget {
  final ClothingItem item;

  const EditClothingScreen({super.key, required this.item});

  @override
  State<EditClothingScreen> createState() => _EditClothingScreenState();
}

class _EditClothingScreenState extends State<EditClothingScreen> {
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  XFile? _selectedImage;
  Color _selectedColor = Colors.black;
  final ImagePicker _picker = ImagePicker();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _categoryController = TextEditingController(text: widget.item.category);
    _selectedColor = Color(int.parse(widget.item.color.substring(1), radix: 16));
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _updateItem() async {
    if (_nameController.text.isEmpty || _categoryController.text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
      }
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Updating item...'),
          ],
        ),
      ),
    );

    try {
      final updatedItem = ClothingItem(
        id: widget.item.id,
        name: _nameController.text,
        category: _categoryController.text,
        imagePath: _selectedImage?.path ?? widget.item.imagePath,
        color: '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0')}',
        dateAdded: widget.item.dateAdded,
        isFavorite: widget.item.isFavorite,
        wearCount: widget.item.wearCount,
        lastWorn: widget.item.lastWorn,
      );

      await _dbHelper.updateClothingItem(updatedItem);
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      Navigator.pop(context, updatedItem); // Return to previous screen
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating item: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: colorScheme.primary),
            onPressed: _updateItem,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(File(_selectedImage!.path), fit: BoxFit.cover),
                      )
                    : widget.item.imagePath.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: ImageViewer(imagePath: widget.item.imagePath),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: colorScheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text('Tap to change image', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Name',
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
            Row(
              children: [
                Text('Item Color: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _selectedColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () async {
                    final Color? pickedColor = await showDialog<Color>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Pick a color'),
                        content: SingleChildScrollView(
                          child: ColorPicker(
                            pickerColor: _selectedColor,
                            onColorChanged: (color) {
                              _selectedColor = color;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, _selectedColor),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                    if (pickedColor != null) {
                      setState(() => _selectedColor = pickedColor);
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text('Change', style: TextStyle(color: colorScheme.primary)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _updateItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class ColorPicker extends StatefulWidget {
  final Color pickerColor;
  final ValueChanged<Color> onColorChanged;

  const ColorPicker({
    super.key,
    required this.pickerColor,
    required this.onColorChanged,
  });

  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.pickerColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: GridView.count(
            crossAxisCount: 6,
            children: [
              Colors.red,
              Colors.pink,
              Colors.purple,
              Colors.deepPurple,
              Colors.indigo,
              Colors.blue,
              Colors.lightBlue,
              Colors.cyan,
              Colors.teal,
              Colors.green,
              Colors.lightGreen,
              Colors.lime,
              Colors.yellow,
              Colors.amber,
              Colors.orange,
              Colors.deepOrange,
              Colors.brown,
              Colors.grey,
              Colors.blueGrey,
              Colors.black,
              Colors.white,
              Colors.transparent,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  setState(() => _currentColor = color);
                  widget.onColorChanged(color);
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: color == Colors.white || color == Colors.transparent
                        ? Border.all(color: Colors.grey)
                        : null,
                  ),
                  child: _currentColor == color
                      ? const Icon(Icons.check, color: Colors.white)
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Slider(
          value: (_currentColor.a * 255).toDouble(),
          min: 0,
          max: 255,
          onChanged: (value) {
            setState(() {
              _currentColor = _currentColor.withAlpha(value.toInt());
              widget.onColorChanged(_currentColor);
            });
          },
        ),
        Text('Opacity: ${(_currentColor.a * 100).round()}%'),
      ],
    );
  }
}