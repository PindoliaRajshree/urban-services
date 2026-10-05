// File: lib/widgets/document_image_viewer.dart
// Purpose: Full-screen, zoomable view of a document image — a newly picked
// file or one already saved on the server (see DocumentUploadCard).

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class DocumentImageViewer extends StatelessWidget {
  const DocumentImageViewer({
    super.key,
    required this.title,
    this.file,
    this.url,
  }) : assert(file != null || url != null);

  final String title;

  /// Shown when set; otherwise [url] is loaded.
  final File? file;
  final String? url;

  static Future<void> show(
    BuildContext context, {
    required String title,
    File? file,
    String? url,
  }) => showDialog<void>(
    context: context,
    builder: (_) => DocumentImageViewer(title: title, file: file, url: url),
  );

  @override
  Widget build(BuildContext context) {
    final message = customTextStyle(
      AppTextSizes.smallTextSize,
      AppColors.white,
      FontWeight.w400,
    );

    final image = file != null
        ? Image.file(file!, fit: BoxFit.contain)
        : Image.network(
            url!,
            fit: BoxFit.contain,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(color: AppColors.white),
                  ),
            errorBuilder: (_, _, _) =>
                Center(child: Text("Couldn't load the image", style: message)),
          );

    return Dialog.fullscreen(
      backgroundColor: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding15w,
                vertical: AppDimensions.padding8h,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: customTextStyle(
                        AppTextSizes.largeTextSize,
                        AppColors.white,
                        FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                maxScale: 5,
                child: SizedBox.expand(child: image),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
