// File: lib/widgets/custom_snackbar.dart
// Purpose: App-wide snackbar/toast utility, styled to the Urban Services
// theme (see lib/core/colors/colors.dart). Built on GetX's rawSnackbar so it
// can be called straight from controllers — no BuildContext required, which
// matches how Get.snackbar(...) was already being used across the app.
//
// Design note: the Admin app's CustomSnackBar (lib/widgets/custom_snackbar.dart
// there) uses a frosted glass card with a blurred radial icon halo. This one
// keeps the same call-site shape (showSuccess/showError/showWarning/showInfo
// + ContentType, so the two codebases read the same way) but takes a
// different visual direction: a crisp floating pill with a colored left
// accent bar, a solid icon badge, and a slim countdown bar along the bottom
// that visibly drains as the toast's duration elapses.

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';

class CustomSnackBar {
  /// Show success toast.
  static void showSuccess({
    required String message,
    String title = 'Success!',
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      contentType: ContentType.success,
      duration: duration,
      position: position,
    );
  }

  /// Show error toast.
  static void showError({
    required String message,
    String title = 'Error!',
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      contentType: ContentType.failure,
      duration: duration,
      position: position,
    );
  }

  /// Show warning toast.
  static void showWarning({
    required String message,
    String title = 'Warning!',
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      contentType: ContentType.warning,
      duration: duration,
      position: position,
    );
  }

  /// Show info toast.
  static void showInfo({
    required String message,
    String title = 'Info',
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      contentType: ContentType.help,
      duration: duration,
      position: position,
    );
  }

  /// Show a toast with an explicit [ContentType], for callers that need
  /// something other than the four convenience methods above.
  static void show({
    required String title,
    required String message,
    required ContentType contentType,
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.TOP,
  }) {
    _show(
      title: title,
      message: message,
      contentType: contentType,
      duration: duration,
      position: position,
    );
  }

  static void _show({
    required String title,
    required String message,
    required ContentType contentType,
    required Duration duration,
    required SnackPosition position,
  }) {
    // Dismiss any toast already on screen so they don't stack up.
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    final style = _styleFor(contentType);

    Get.rawSnackbar(
      titleText: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: style.foreground,
          fontWeight: FontWeight.w700,
          fontSize: AppTextSizes.largeMediumTextSize,
          letterSpacing: 0.1,
        ),
      ),
      messageText: Padding(
        padding: EdgeInsets.only(top: 3.h),
        child: Text(
          message,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: style.foreground.withValues(alpha: 0.85),
            fontWeight: FontWeight.w500,
            fontSize: AppTextSizes.mediumTextSize,
            height: 1.25,
          ),
        ),
      ),
      icon: Container(
        width: 34.w,
        height: 34.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: style.foreground.withValues(alpha: 0.14),
          border: Border.all(
            color: style.foreground.withValues(alpha: 0.32),
            width: AppDimensions.containerWidth1w,
          ),
        ),
        child: Icon(style.icon, color: style.foreground, size: 18.r),
      ),
      shouldIconPulse: false,
      backgroundGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.white,
          Color.alphaBlend(
            style.foreground.withValues(alpha: 0.1),
            AppColors.white,
          ),
        ],
      ),
      leftBarIndicatorColor: style.foreground,
      borderRadius: AppDimensions.radius16r,
      borderColor: style.foreground.withValues(alpha: 0.24),
      borderWidth: 1,
      boxShadows: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          spreadRadius: 1,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: style.foreground.withValues(alpha: 0.16),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
      margin: EdgeInsets.symmetric(horizontal: AppDimensions.padding15w),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding15w,
        vertical: AppDimensions.padding12h,
      ),
      snackPosition: position,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
      dismissDirection: position == SnackPosition.TOP
          ? DismissDirection.up
          : DismissDirection.down,
      duration: duration,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      // Slim countdown bar that drains over the toast's lifetime — this is
      // the bit that departs from the Admin app's look.
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: style.foreground.withValues(
        alpha: 0.12,
      ),
      progressIndicatorValueColor: AlwaysStoppedAnimation<Color>(
        style.foreground,
      ),
    );
  }

  static _SnackBarStyle _styleFor(ContentType contentType) {
    switch (contentType) {
      case ContentType.success:
        return const _SnackBarStyle(
          foreground: AppColors.success,
          icon: Icons.check_circle_rounded,
        );
      case ContentType.failure:
        return const _SnackBarStyle(
          foreground: AppColors.danger,
          icon: Icons.cancel_rounded,
        );
      case ContentType.warning:
        return const _SnackBarStyle(
          foreground: AppColors.warning,
          icon: Icons.warning_amber_rounded,
        );
      case ContentType.help:
      default:
        return const _SnackBarStyle(
          foreground: AppColors.info,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackBarStyle {
  final Color foreground;
  final IconData icon;

  const _SnackBarStyle({required this.foreground, required this.icon});
}
