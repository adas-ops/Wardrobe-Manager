// widgets/image_viewer.dart
import 'package:flutter/material.dart';
import 'dart:io';

class ImageViewer extends StatelessWidget {
  final String imagePath;
  
  const ImageViewer({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return imagePath.startsWith('http')
        ? Image.network(imagePath)
        : Image.file(File(imagePath));
  }
}