// lib/helpers/color_helper.dart
import 'package:flutter/material.dart';

String colorToHex(Color color) {
  // Use the recommended toARGB32() method instead of value
  return color.toARGB32().toRadixString(16);
}