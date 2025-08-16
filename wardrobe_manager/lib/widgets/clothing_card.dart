import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import 'dart:io';

class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isGridView;

  const ClothingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.isGridView = false,
  });

  @override
  Widget build(BuildContext context) {
    Color displayColor = Colors.grey;

    try {
      String hex = item.colorHex.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').trim();
      
      if (hex.isEmpty) {
        displayColor = Colors.grey;
      } else {
        if (hex.length == 6) {
          hex = 'FF$hex';
        } else if (hex.length == 3) {
          hex = 'FF${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}';
        } else if (hex.length == 4) {
          hex = '${hex[0]}${hex[0]}${hex[1]}${hex[1]}${hex[2]}${hex[2]}${hex[3]}${hex[3]}';
        } else if (hex.length == 1) {
          hex = 'FF${hex * 6}';
        } else if (hex.length == 2) {
          hex = 'FF$hex$hex$hex';
        }
        
        if (hex.length == 8) {
          displayColor = Color(int.parse(hex, radix: 16));
        }
      }
    } catch (e) {
      displayColor = Colors.grey;
    }

    // Grid view layout
    if (isGridView) {
      return GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image container
              Expanded(
                flex: 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: item.imagePath.isNotEmpty
                        ? Image.file(
                            File(item.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(
                                  Icons.photo,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                ),
                          )
                        : Icon(
                            Icons.photo,
                            size: 32,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                          ),
                  ),
                ),
              ),
              // Text and details container
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Item name
                      Expanded(
                        child: Center(
                          child: Text(
                            item.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface,
                              height: 1.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Category and color indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              item.category,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          CircleAvatar(
                            backgroundColor: displayColor,
                            radius: 6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // List view layout (original design for wardrobe screen)
    return Card(
      child: ListTile(
        leading: item.imagePath.isNotEmpty
            ? Image.file(
                File(item.imagePath),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(
                    width: 50, 
                    height: 50, 
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.photo,
                      color: Colors.grey.shade600,
                    ),
                  ),
              )
            : Container(
                width: 50, 
                height: 50, 
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.photo,
                  color: Colors.grey.shade600,
                ),
              ),
        title: Text(item.name),
        subtitle: Text(item.category),
        trailing: CircleAvatar(backgroundColor: displayColor, radius: 10),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}