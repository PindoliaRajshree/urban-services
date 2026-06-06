import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';

/// Define the app theme using Inter font and a color scheme based on the primary color.
final theme = ThemeData(
  fontFamily: "Inter",
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
  useMaterial3: true,
);
