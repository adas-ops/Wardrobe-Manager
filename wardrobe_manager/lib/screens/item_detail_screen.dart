import 'package:flutter/material.dart';
import 'package:wardrobe_manager/helpers/database_helper.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';
import 'package:wardrobe_manager/screens/edit_clothing_screen.dart';
import 'package:wardrobe_manager/widgets/image_viewer.dart';

class ItemDetailScreen extends StatefulWidget {
  final ClothingItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  late ClothingItem _currentItem;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  // Helper method to format dates
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void initState() {
    super.initState();
    _currentItem = widget.item;
  }

  void _toggleFavorite() async {
    final newFavoriteStatus = !_currentItem.isFavorite;
    
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Updating...'),
          ],
        ),
      ),
    );

    try {
      await _dbHelper.toggleFavorite(_currentItem.id!, newFavoriteStatus);
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      setState(() {
        // Create a new instance with updated favorite status
        _currentItem = ClothingItem(
          id: _currentItem.id,
          name: _currentItem.name,
          category: _currentItem.category,
          imagePath: _currentItem.imagePath,
          color: _currentItem.color,
          dateAdded: _currentItem.dateAdded,
          wearCount: _currentItem.wearCount,
          lastWorn: _currentItem.lastWorn,
          isFavorite: newFavoriteStatus,
        );
      });
      
      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item ${newFavoriteStatus ? 'added to' : 'removed from'} favorites')),
        );
      }
    } catch (e) {
      // Close loading dialog on error
      if (mounted) Navigator.pop(context);
      
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  void _confirmDelete() {
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
              Navigator.pop(context); // Close dialog immediately
              try {
                await _dbHelper.deleteItem(_currentItem.id!);
                // Navigate back to wardrobe screen with refresh flag
                if (mounted) Navigator.pop(context, true);
              } catch (e) {
                // Show error message
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete item: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentItem.name),
        actions: [
          IconButton(
            icon: Icon(
              _currentItem.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentItem.isFavorite ? Colors.red : null,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final updatedItem = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditClothingScreen(item: _currentItem),
                ),
              );
              if (updatedItem != null && mounted) {
                setState(() => _currentItem = updatedItem);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ImageViewer(imagePath: _currentItem.imagePath),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Name', _currentItem.name),
            _buildDetailRow('Category', _currentItem.category),
            _buildDetailRow('Color', _currentItem.color),
            _buildDetailRow('Date Added', _formatDate(_currentItem.dateAdded)),
            _buildDetailRow('Wear Count', _currentItem.wearCount.toString()),
            if (_currentItem.lastWorn != null)
              _buildDetailRow('Last Worn', _formatDate(_currentItem.lastWorn!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}