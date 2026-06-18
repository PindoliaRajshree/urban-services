// File: lib/widgets/document_upload_card.dart
// Purpose: A reusable card for secure document uploading with support for different formats and file removal.

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class DocumentUploadCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final File? selectedFile;
  final VoidCallback onUpload;
  final VoidCallback onRemove;

  const DocumentUploadCard({
    super.key,
    required this.title,
    required this.subTitle,
    this.selectedFile,
    required this.onUpload,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
                Column(
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
              ],
            ),
          ),
          const Divider(color: Color.fromRGBO(190, 190, 190, 1), height: 1),
          GestureDetector(
            onTap: onUpload,
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
                    Image.asset(
                      selectedFile != null
                          ? AppImages.forward
                          : AppImages.upload,
                      height: selectedFile != null
                          ? AppDimensions.containerHeight10h
                          : AppDimensions.containerHeight20h,
                      width: selectedFile != null
                          ? AppDimensions.containerWidth10w
                          : AppDimensions.containerWidth20w,
                      color: AppColors.primaryDark,
                    ),
                    SizedBox(width: AppDimensions.padding8w),
                    Text(
                      selectedFile != null
                          ? selectedFile!.path.split('/').last
                          : "Click to upload",
                      overflow: TextOverflow.ellipsis,
                      style: customTextStyle(
                        AppTextSizes.smallTextSize, // 12
                        AppColors.primaryDark,
                        FontWeight.w600,
                      ),
                    ),
                    if (selectedFile != null)
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
              "jpg, jpeg, png, pdf, doc, or docx files (max 4MB)",
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
