// File: lib/widgets/confirm_dialog.dart
// Purpose: A generic yes/no confirmation dialog, styled like LogoutDialog.
// Use [ConfirmDialog.show], which resolves to true only when the user
// confirms.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.isDestructive = false,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final String cancelLabel;

  /// Colours the confirm button as a danger action.
  final bool isDestructive;

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius20r),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.17),
              blurRadius: 4,
              spreadRadius: 1,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.all(AppDimensions.padding20h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: customTextStyle(
                AppTextSizes.extraLargeTextSize,
                AppColors.darkBlack,
                FontWeight.w600,
              ),
            ),
            SizedBox(height: AppDimensions.padding15h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: customTextStyle(
                AppTextSizes.largeMediumTextSize,
                AppColors.text,
                FontWeight.w500,
              ),
            ),
            SizedBox(height: AppDimensions.padding30h),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding12h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                        side: const BorderSide(color: AppColors.grey),
                      ),
                    ),
                    child: Text(
                      cancelLabel,
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.text,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppDimensions.padding15w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDestructive
                          ? AppColors.danger
                          : AppColors.primaryDark,
                      padding: EdgeInsets.symmetric(
                        vertical: AppDimensions.padding12h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      confirmLabel,
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.white,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
