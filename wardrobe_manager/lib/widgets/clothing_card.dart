import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wardrobe_manager/models/clothing_item.dart';

class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback onDelete;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  const ClothingCard({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onToggleFavorite,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(
            File(item.imagePath),
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 60,
                height: 60,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image),
              );
            },
          ),
        ),
        title: Text(item.name),
        subtitle: Text(item.category),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Color(int.parse(item.colorHex, radix: 16)),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.star,
                color: item.isFavorite ? Colors.amber : Colors.grey,
              ),
              onPressed: onToggleFavorite,
            ),
          ],
        ),
        onTap: onTap,
        onLongPress: onDelete,
      ),
    );
  }
}