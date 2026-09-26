// File: lib/widgets/custom_snackbar.dart
// Purpose: App-wide snackbar/toast utility, styled to the Urban Services
// theme (see lib/core/colors/colors.dart). Rendered into the root
// navigator's Overlay (see core/navigation/app_keys.dart) so it can be
// called straight from notifiers — no BuildContext required.
//
// Design note: matches the reference toast exactly — a solid colored pill
// (AppColors.toastSuccess/toastDanger/toastWarning/toastInfo), a white
// circular icon badge with the accent color as the glyph, white text, a
// white close (X") button, no border and no progress bar, floating near the
// top and pinned to the right of the screen (not centered/full-width).

import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/core/navigation/app_keys.dart';

/// Where the toast floats. Replaces GetX's `SnackPosition`.
enum SnackPosition { top, bottom }

class CustomSnackBar {
  static OverlayEntry? _current;

  /// Show success toast.
  static void showSuccess({
    required String message,
    String title = 'Success!',
    Duration duration = const Duration(seconds: 3),
    SnackPosition position = SnackPosition.top,
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
    SnackPosition position = SnackPosition.top,
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
    SnackPosition position = SnackPosition.top,
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
    SnackPosition position = SnackPosition.top,
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
    SnackPosition position = SnackPosition.top,
  }) {
    _show(
      title: title,
      message: message,
      contentType: contentType,
      duration: duration,
      position: position,
    );
  }

  /// Removes the toast currently on screen, if any.
  static void dismiss() {
    _current?.remove();
    _current = null;
  }

  static void _show({
    required String title,
    required String message,
    required ContentType contentType,
    required Duration duration,
    required SnackPosition position,
  }) {
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    // Dismiss any toast already on screen so they don't stack up.
    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _Toast(
        title: title,
        message: message,
        style: _styleFor(contentType),
        duration: duration,
        position: position,
        onDismissed: () {
          if (_current == entry) dismiss();
        },
      ),
    );
    _current = entry;
    overlay.insert(entry);
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

class _Toast extends StatefulWidget {
  const _Toast({
    required this.title,
    required this.message,
    required this.style,
    required this.duration,
    required this.position,
    required this.onDismissed,
  });

  final String title;
  final String message;
  final _SnackBarStyle style;
  final Duration duration;
  final SnackPosition position;
  final VoidCallback onDismissed;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  late final Animation<Offset> _slide =
      Tween<Offset>(
        begin: Offset(0, widget.position == SnackPosition.top ? -1.5 : 1.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
      );
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(widget.duration, _close);
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _timer?.cancel();
    if (mounted) await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTop = widget.position == SnackPosition.top;
    final style = widget.style;

    final toast = Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding15w,
        vertical: AppDimensions.padding10h,
      ),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppDimensions.radius16r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // White circular badge with the accent color as the glyph.
          Container(
            width: 30.w,
            height: 30.h,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: Icon(style.icon, color: style.background, size: 16.r),
          ),
          SizedBox(width: AppDimensions.padding10w),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: AppTextSizes.largeMediumTextSize,
                    letterSpacing: 0.1,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    widget.message,
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
              ],
            ),
          ),
          // Explicit white close button — the reference toast has a
          // visible "X" rather than relying only on swipe-to-dismiss.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _close,
            child: Padding(
              padding: EdgeInsets.all(AppDimensions.padding4h),
              child: Icon(
                Icons.close_rounded,
                color: AppColors.white,
                size: 18.r,
              ),
            ),
          ),
        ],
      ),
    );

    // Pinned to the right rather than centered/full-width — a small margin
    // from the right edge and a large one on the left.
    return Positioned(
      top: isTop ? 0 : null,
      bottom: isTop ? null : 0,
      left: 0.40.sw,
      right: AppDimensions.padding15w,
      child: SafeArea(
        top: isTop,
        bottom: !isTop,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: AppDimensions.padding10h),
          child: SlideTransition(
            position: _slide,
            child: Dismissible(
              key: const ValueKey('toast'),
              direction: isTop ? DismissDirection.up : DismissDirection.down,
              onDismissed: (_) => widget.onDismissed(),
              child: Material(type: MaterialType.transparency, child: toast),
            ),
          ),
        ),
      ),
    );
  }
}

class _SnackBarStyle {
  /// Solid pill background — also reused as the icon glyph color on the
  /// white circular badge.
  final Color background;

  final IconData icon;

  const _SnackBarStyle({required this.background, required this.icon});
}
