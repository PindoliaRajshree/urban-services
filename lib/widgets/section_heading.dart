// File: lib/widgets/section_heading.dart
// Purpose: A reusable widget for section headers throughout the app.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class SectionHeading extends StatelessWidget {
  final String title;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;

  const SectionHeading({
    super.key,
    required this.title,
    this.fontSize,
    this.fontWeight,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: customTextStyle(
        fontSize ?? AppTextSizes.largeTextSize, // Default to 16
        color ?? AppColors.headingGrey,
        fontWeight ?? FontWeight.w500,
      ),
    );
  }
}
