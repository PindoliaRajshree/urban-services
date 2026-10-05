// File: lib/widgets/add_mobile_number_dialog.dart
// Purpose: Asks for a mobile number to add to an account that has none.
// Pops the entered number once [AddMobileNumberDialog.onSubmit] has sent
// it an OTP (the caller then opens VerifyNumberDialog), or null when
// cancelled.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/core/utils/input_formatters.dart';
import 'package:urban_services/features/profile_common/basic_info.dart';
import 'package:urban_services/widgets/address_form_field.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class AddMobileNumberDialog extends StatefulWidget {
  const AddMobileNumberDialog({super.key, required this.onSubmit});

  /// Sends an OTP to the entered (valid) number; returns whether it was
  /// sent. The dialog closes with the number only when this returns true.
  final Future<bool> Function(String mobile) onSubmit;

  @override
  State<AddMobileNumberDialog> createState() => _AddMobileNumberDialogState();
}

class _AddMobileNumberDialogState extends State<AddMobileNumberDialog> {
  final _mobileController = TextEditingController();
  String? _error;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    // Clear the error when typing
    _mobileController.addListener(() {
      if (_error != null) setState(() => _error = null);
    });
  }

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSending) return;
    final mobile = _mobileController.text.trim();
    final error = mobileNumberError(mobile);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _isSending = true);
    final sent = await widget.onSubmit(mobile);
    if (!mounted) return;
    setState(() => _isSending = false);
    if (sent) Navigator.of(context).pop(mobile);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(AppDimensions.padding20h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius16r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Mobile Number',
              style: customTextStyle(
                AppTextSizes.largeTextSize,
                AppColors.darkBlueText,
                FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.padding10h),
            Text(
              "We'll send an OTP to verify it",
              style: customTextStyle(
                AppTextSizes.smallTextSize,
                AppColors.greyText,
                FontWeight.w400,
              ),
            ),
            SizedBox(height: AppDimensions.padding20h),
            AddressFormField(
              label: "Mobile Number",
              hintText: "Enter your Number",
              controller: _mobileController,
              keyboardType: TextInputType.phone,
              inputFormatters: mobileNumberFormatters,
              errorText: _error,
              prefix: Container(
                padding: EdgeInsets.all(AppDimensions.padding4w),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radius3r),
                ),
                child: Text(
                  "+91",
                  style: customTextStyle(
                    AppTextSizes.stableTextSize,
                    AppColors.black,
                    FontWeight.w400,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppDimensions.padding25h),
            PrimaryButton(
              text: 'Send OTP',
              width: AppDimensions.containerWidth150w,
              height: AppDimensions.containerHeight40h,
              isLoading: _isSending,
              onPressed: _submit,
            ),
            SizedBox(height: AppDimensions.padding10h),
            TextButton(
              onPressed: _isSending ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: customTextStyle(
                  AppTextSizes.largeMediumTextSize,
                  AppColors.greyText,
                  FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
