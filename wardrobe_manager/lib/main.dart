// lib/main.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wardrobe Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    WardrobeScreen(),
    AddClothingScreen(),
    Center(child: Text('Settings Tab')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wardrobe Manager')),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.checkroom), label: 'Wardrobe'),
          BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({Key? key}) : super(key: key);

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
      });
    }
  }

  void _saveItem() async {
  final name = _nameController.text.trim();
  final category = _categoryController.text.trim();
  final imagePath = _selectedImage?.path ?? '';

  if (name.isEmpty || category.isEmpty || imagePath.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please fill all fields and pick an image')),
    );
    return;
  }

  final item = ClothingItem(name: name, category: category, imagePath: imagePath);
  await DatabaseHelper.instance.insertClothingItem(item);

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Clothing item saved!')),
  );

  _nameController.clear();
  _categoryController.clear();
  setState(() => _selectedImage = null);
}


  @override
  Widget build(BuildContext context) {
    return Padding(
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
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Pick Image'),
          ),
          if (_selectedImage != null) ...[
            const SizedBox(height: 16),
            Image.file(_selectedImage!, height: 200),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveItem,
            child: const Text('Save Item'),
          ),
        ],
      ),
    );
  }
}
class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({Key? key}) : super(key: key);

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  List<ClothingItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final data = await DatabaseHelper.instance.getAllItems();
    setState(() {
      _items = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
      return ListTile(
      leading: Image.file(File(item.imagePath), width: 50, height: 50, fit: BoxFit.cover),
      title: Text(item.name),
      subtitle: Text(item.category),
      onLongPress: () => _confirmDelete(item.id!),
);


      },
    );
  }
  void _confirmDelete(int id) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Item'),
      content: const Text('Are you sure you want to delete this item?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await DatabaseHelper.instance.deleteItem(id);
            Navigator.pop(context);
            _loadItems(); // refresh the list
          },
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}

}

