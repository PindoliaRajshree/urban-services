// File: lib/core/colors/colors.dart
// Purpose: Defines the application's color palette and gradients.

import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color.fromRGBO(37, 99, 235, 1);
  static const Color primaryLight = Color.fromRGBO(96, 165, 250, 1);
  static const Color accent = Color.fromRGBO(6, 182, 212, 1);
  static const LinearGradient gradient = LinearGradient(
    colors: [Color.fromRGBO(17, 54, 137, 1), Color.fromRGBO(20, 103, 206, 1)],
  );

  // Neutral Colors
  static const Color black = Color.fromRGBO(0, 0, 0, 1);
  static const Color white = Color.fromRGBO(255, 255, 255, 1);
  static const Color text = Color.fromRGBO(64, 64, 64, 1);
  static const Color darkGrey = Color.fromRGBO(109, 109, 109, 1);
  static const Color grey = Color.fromRGBO(160, 162, 166, 1);
  static const Color lightGrey = Color.fromRGBO(226, 232, 240, 1);

  // Semantic Colors (Status)
  static const Color success = Color.fromRGBO(0, 146, 82, 1);
  static const Color warning = Color.fromRGBO(255, 168, 0, 1);
  static const Color info = Color.fromRGBO(0, 201, 243, 1);
  static const Color danger = Color.fromRGBO(232, 0, 63, 1);
  static const Color primaryOrange = Color.fromRGBO(245, 158, 11, 1);

  // UI Colors
  static const Color background = Color.fromRGBO(222, 241, 255, 1);
}
