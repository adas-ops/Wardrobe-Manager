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
        content: const Text('Are you sure you want to permanently delete this item?'),
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
                if (mounted && context.mounted) {
                  Navigator.pop(context, true);
                }
              } catch (e) {
                // Show error message
                if (mounted && context.mounted) {
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
        title: Text(_currentItem.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: Icon(
              _currentItem.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _currentItem.isFavorite ? Colors.red : Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
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
            icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
            onPressed: _confirmDelete,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ImageViewer(imagePath: _currentItem.imagePath),
                ),
              ),
            ),
            const SizedBox(height: 28),
            _buildDetailCard('Name', _currentItem.name),
            _buildDetailCard('Category', _currentItem.category),
            _buildDetailCard('Color', _currentItem.color),
            _buildDetailCard('Date Added', _formatDate(_currentItem.dateAdded)),
            _buildDetailCard('Wear Count', _currentItem.wearCount.toString()),
            if (_currentItem.lastWorn != null)
              _buildDetailCard('Last Worn', _formatDate(_currentItem.lastWorn!)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String label, String value) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const Spacer(),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}