// File: lib/widgets/section_heading.dart
// Purpose: A reusable widget for section headers in the Home screen.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class SectionHeading extends StatelessWidget {
  final String title;

  const SectionHeading({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: customTextStyle(
        AppTextSizes.largeTextSize, // 16
        AppColors.headingGrey,
        FontWeight.w500,
      ),
    );
  }
}
