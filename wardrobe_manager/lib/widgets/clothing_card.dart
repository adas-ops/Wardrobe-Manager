import 'package:flutter/material.dart';
import '../models/clothing_item.dart';
import 'dart:io';

class ClothingCard extends StatelessWidget {
  final ClothingItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ClothingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onLongPress,
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

    return Card(
      child: ListTile(
        leading: item.imagePath.isNotEmpty
            ? Image.file(
                File(item.imagePath),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  Container(width: 50, height: 50, color: Colors.grey),
              )
            : Container(width: 50, height: 50, color: Colors.grey),
        title: Text(item.name),
        subtitle: Text(item.category),
        trailing: CircleAvatar(backgroundColor: displayColor, radius: 10),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }
}