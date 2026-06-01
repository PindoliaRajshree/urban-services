// File: lib/widgets/custom_text_style.dart
// Purpose: Helper functions for generating consistent TextStyles.

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// custom TextStyle
TextStyle customTextStyle(double size, Color color, FontWeight weight) {
  return TextStyle(color: color, fontSize: size.spMax, fontWeight: weight);
}

// custom Underline TextStyle
TextStyle customUnderlineTextStyle(
  double size,
  Color color,
  FontWeight weight,
) {
  return TextStyle(
    color: color,
    fontSize: size.spMax,
    fontWeight: weight,
    decorationColor: color,
    decoration: TextDecoration.underline,
  );
}
