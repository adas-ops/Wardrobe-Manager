import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AdvancedColorPicker extends StatelessWidget {
  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  const AdvancedColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Item Color:', style: TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        ListTile(
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: selectedColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
            ),
          ),
          title: const Text('Tap to change color'),
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Pick a color'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: selectedColor,
                      onColorChanged: onColorSelected,
                      showLabel: true,
                      pickerAreaHeightPercent: 0.8,
                      enableAlpha: false,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}