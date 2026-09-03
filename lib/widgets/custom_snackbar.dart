// File: lib/widgets/custom_snackbar.dart
// Purpose: App-wide snackbar/toast utility, styled to the Urban Services
// theme (see lib/core/colors/colors.dart). Built on GetX's rawSnackbar so it
// can be called straight from controllers — no BuildContext required, which
// matches how Get.snackbar(...) was already being used across the app.
//
// Design note: matches the reference toast exactly — a solid colored pill
// (AppColors.toastSuccess/toastDanger/toastWarning/toastInfo), a white
// circular icon badge with the accent color as the glyph, white text, a
// white close (X") button, no border and no progress bar, floating near the
// top and pinned to the right of the screen (not centered/full-width).

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
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: AppTextSizes.largeMediumTextSize,
          letterSpacing: 0.1,
        ),
      ),
      messageText: Padding(
        padding: EdgeInsets.only(top: 2.h),
        child: Text(
          message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w500,
            fontSize: AppTextSizes.mediumTextSize,
            height: 1.2,
          ),
        ),
      ),
      // White circular badge with the accent color as the glyph — matches
      // the reference's white check-in-a-circle exactly, rather than a
      // solid colored badge with a white glyph.
      icon: Container(
        width: 30.w,
        height: 30.h,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
        child: Icon(style.icon, color: style.background, size: 16.r),
      ),
      shouldIconPulse: false,
      // Explicit white close button — the reference toast has a visible
      // "X" rather than relying only on swipe-to-dismiss.
      mainButton: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
        },
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.padding4h),
          child: Icon(Icons.close_rounded, color: AppColors.white, size: 18.r),
        ),
      ),
      backgroundColor: style.background,
      borderRadius: AppDimensions.radius16r,
      boxShadows: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.15),
          blurRadius: 16,
          spreadRadius: 0,
          offset: const Offset(0, 6),
        ),
      ],
      // Pinned to the right rather than centered/full-width — a small
      // margin from the right edge and a large one on the left, matching
      // the reference exactly instead of spanning the screen.
      margin: EdgeInsets.only(
        left: 0.40.sw,
        right: AppDimensions.padding15w,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding15w,
        vertical: AppDimensions.padding10h,
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
    );
  }

  static _SnackBarStyle _styleFor(ContentType contentType) {
    switch (contentType) {
      case ContentType.success:
        return const _SnackBarStyle(
          background: AppColors.toastSuccess,
          icon: Icons.check_rounded,
        );
      case ContentType.failure:
        return const _SnackBarStyle(
          background: AppColors.toastDanger,
          icon: Icons.priority_high_rounded,
        );
      case ContentType.warning:
        return const _SnackBarStyle(
          background: AppColors.toastWarning,
          icon: Icons.warning_rounded,
        );
      case ContentType.help:
      default:
        return const _SnackBarStyle(
          background: AppColors.toastInfo,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackBarStyle {
  /// Solid pill background — also reused as the icon glyph color on the
  /// white circular badge.
  final Color background;

  final IconData icon;

  const _SnackBarStyle({required this.background, required this.icon});
}
