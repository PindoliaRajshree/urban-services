// File: lib/widgets/profile_avatar.dart
// Purpose: Circular profile photo used on the Home header and Profile tab.
// Shows the saved photo when there is one, otherwise (or if it fails to
// load) the placeholder image.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_images.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.width,
    required this.height,
    this.imageUrl,
    this.border,
    this.boxShadow,
  });

  final double width;
  final double height;

  /// The saved photo's URL; the placeholder is shown when null.
  final String? imageUrl;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final placeholder = Image.asset(AppImages.image, fit: BoxFit.cover);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: url == null
            ? placeholder
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => placeholder,
              ),
      ),
    );
  }
}
