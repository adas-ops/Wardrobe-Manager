// lib/widgets/color_picker.dart
import 'package:flutter/material.dart';

class ColorPickerWidget extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.grey,
      Colors.black,
      Colors.white,
      Colors.indigo,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Color:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((color) {
            final isSelected = selectedColor == color;
            return GestureDetector(
              onTap: () => onColorSelected(color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  border: Border.all(
                    color: isSelected ? Colors.deepPurple : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isSelected 
                  ? const Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}