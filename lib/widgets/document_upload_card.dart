// File: lib/widgets/document_upload_card.dart
// Purpose: A reusable card for secure document uploading with support for different formats and file removal.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/document_image_viewer.dart';

class DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final File? selectedFile;

  /// URL of a document already saved on the server. Shown as "uploaded"
  /// when no new [selectedFile] has been picked.
  final String? existingUrl;

  /// True while the picked image is being read (e.g. OCR of a card
  /// number). Shows a spinner and ignores taps.
  final bool isProcessing;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const DocumentUploadCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.selectedFile,
    this.existingUrl,
    this.isProcessing = false,
    required this.onUpload,
    required this.onRemove,
  });

  /// Opens the picked file, or else the saved one, full screen.
  void _view(BuildContext context) => DocumentImageViewer.show(
    context,
    title: "$title – $subTitle",
    file: selectedFile,
    url: existingUrl,
  );

  @override
  Widget build(BuildContext context) {
    final hasFile =
        !isProcessing && (selectedFile != null || existingUrl != null);
    final fileLabel = isProcessing
        ? "Reading number..."
        : selectedFile != null
        ? selectedFile!.path.split(RegExp(r'[/\\]')).last
        : existingUrl != null
        ? "Uploaded — tap to replace"
        : "Click to upload";

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            offset: const Offset(0, 9.66),
            blurRadius: 9.66,
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(AppDimensions.padding15w),
            child: Row(
              children: [
                Image.asset(
                  AppImages.file,
                  height: AppDimensions.containerHeight24h,
                  width: AppDimensions.containerWidth24w,
                ),
                SizedBox(width: AppDimensions.padding10w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: customTextStyle(
                          AppTextSizes.mediumTextSize, // 13
                          AppColors.headingGrey,
                          FontWeight.w600,
                        ),
                      ),
                      Text(
                        subTitle,
                        style: customTextStyle(
                          AppTextSizes.smallTextSize, // 12
                          AppColors.darkGrey,
                          FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Thumbnail of the saved document (tap to view).
                if (!isProcessing &&
                    selectedFile == null &&
                    existingUrl != null)
                  GestureDetector(
                    onTap: () => _view(context),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radius4r,
                      ),
                      child: Image.network(
                        existingUrl!,
                        height: AppDimensions.containerHeight40h,
                        width: AppDimensions.containerHeight40h,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                if (hasFile)
                  TextButton.icon(
                    onPressed: () => _view(context),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primaryDark,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding8w,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      Icons.visibility_outlined,
                      size: AppDimensions.containerHeight18h,
                    ),
                    label: Text(
                      "View",
                      style: customTextStyle(
                        AppTextSizes.smallTextSize,
                        AppColors.primaryDark,
                        FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(color: Color.fromRGBO(190, 190, 190, 1), height: 1),
          GestureDetector(
            onTap: isProcessing ? null : onUpload,
            child: Container(
              margin: EdgeInsets.all(AppDimensions.padding12w),
              padding: EdgeInsets.symmetric(vertical: AppDimensions.padding15h),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(AppDimensions.radius4r),
                border: Border.all(
                  color: AppColors.primaryLight.withValues(alpha: 0.5),
                  style: BorderStyle.solid, // Simple dash simulation
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isProcessing)
                      SizedBox(
                        height: AppDimensions.containerHeight16h,
                        width: AppDimensions.containerWidth16w,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      Image.asset(
                        hasFile ? AppImages.forward : AppImages.upload,
                        height: hasFile
                            ? AppDimensions.containerHeight10h
                            : AppDimensions.containerHeight20h,
                        width: hasFile
                            ? AppDimensions.containerWidth10w
                            : AppDimensions.containerWidth20w,
                        color: AppColors.primaryDark,
                      ),
                    SizedBox(width: AppDimensions.padding8w),
                    Flexible(
                      child: Text(
                        fileLabel,
                        overflow: TextOverflow.ellipsis,
                        style: customTextStyle(
                          AppTextSizes.smallTextSize, // 12
                          AppColors.primaryDark,
                          FontWeight.w600,
                        ),
                      ),
                    ),
                    if (hasFile)
                      GestureDetector(
                        onTap: () {
                          // Prevent triggering the parent GestureDetector
                          onRemove();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppDimensions.padding8w,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.red,
                            size: AppDimensions.containerHeight18h,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: AppDimensions.padding10h),
            child: Text(
              "jpg, jpeg, or png (max 4MB)",
              textAlign: TextAlign.center,
              style: customTextStyle(
                AppTextSizes.stableTextSize - 1, // 11
                AppColors.headingGrey,
                FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
