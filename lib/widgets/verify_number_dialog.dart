// File: lib/widgets/verify_number_dialog.dart
// Purpose: OTP verification dialog with masked mobile number display and
// inline validation. Shared by the user and provider profile-completion
// screens.
//
// Pass [VerifyNumberDialog.onVerify] / [VerifyNumberDialog.onResend] to
// check the code for real (provider profile). Without them any non-empty
// code closes the dialog (user profile — see docs/UI_FLOW_AUDIT.md).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';

class VerifyNumberDialog extends StatefulWidget {
  final String phoneNumber;

  /// Checks the entered code (possibly on the server — the Verify button
  /// shows a loader meanwhile); returns an error to show, or null when it's
  /// correct (the dialog then closes and pops `true`).
  final FutureOr<String?> Function(String code)? onVerify;

  /// Sends a new OTP; returns whether it was sent. Resend is disabled for
  /// [resendCooldown] after the dialog opens and after each resend.
  final Future<bool> Function()? onResend;

  const VerifyNumberDialog({
    super.key,
    required this.phoneNumber,
    this.onVerify,
    this.onResend,
  });

  static const Duration resendCooldown = Duration(seconds: 30);

  @override
  State<VerifyNumberDialog> createState() => _VerifyNumberDialogState();
}

class _VerifyNumberDialogState extends State<VerifyNumberDialog> {
  final _otpController = TextEditingController();
  String? _otpError;
  int _resendSecondsLeft = 0;
  bool _isResending = false;
  bool _isVerifying = false;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.onResend != null) _startCooldown();
    // Clear the OTP error when typing
    _otpController.addListener(() {
      if (_otpController.text.isNotEmpty && _otpError != null) {
        setState(() => _otpError = null);
      }
    });
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    _resendSecondsLeft = VerifyNumberDialog.resendCooldown.inSeconds;
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return timer.cancel();
      setState(() => _resendSecondsLeft--);
      if (_resendSecondsLeft <= 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    final onResend = widget.onResend;
    if (onResend == null || _isResending || _resendSecondsLeft > 0) return;
    setState(() => _isResending = true);
    final sent = await onResend();
    if (!mounted) return;
    setState(() {
      _isResending = false;
      if (sent) {
        _otpController.clear();
        _otpError = null;
        _startCooldown();
      }
    });
  }

  /// Verifies the OTP entered in the dialog
  Future<void> _verifyOtp() async {
    if (_isVerifying) return;
    final code = _otpController.text.trim();
    if (code.isEmpty) {
      setState(() => _otpError = "Please enter OTP");
      return;
    }
    setState(() => _isVerifying = true);
    final error = await widget.onVerify?.call(code);
    if (!mounted) return;
    setState(() => _isVerifying = false);
    if (error != null) {
      setState(() => _otpError = error);
      return;
    }
    Navigator.of(context).pop(true); // Close dialog on success
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber = widget.phoneNumber;
    final resendDisabled = _isResending || _resendSecondsLeft > 0;

    // Simple masking: show first 5 and last 2, rest *
    final masked = phoneNumber.length > 7
        ? "${phoneNumber.substring(0, 5)}***${phoneNumber.substring(phoneNumber.length - 2)}"
        : phoneNumber;

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
              'Verify Number',
              style: customTextStyle(
                AppTextSizes.largeTextSize, // 16
                AppColors.darkBlueText,
                FontWeight.w700,
              ),
            ),
            SizedBox(height: AppDimensions.padding10h),
            Text(
              'We sent a OTP to $masked',
              style: customTextStyle(
                AppTextSizes.smallTextSize, // 12
                AppColors.greyText,
                FontWeight.w400,
              ),
            ),
            SizedBox(height: AppDimensions.padding20h),
            // Standardized OTP Input Field
            Column(
              children: [
                Container(
                  width: double.infinity,
                  height: AppDimensions.containerHeight50h,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border.all(
                      color: _otpError != null
                          ? AppColors.danger
                          : AppColors.lightGreyBorder,
                      width: 1,
                    ),
                  ),
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    style: customTextStyle(
                      AppTextSizes.headingTextSize, // 24
                      AppColors.darkBlueText,
                      FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "- - - -",
                    ),
                  ),
                ),
                if (_otpError != null)
                  Padding(
                    padding: EdgeInsets.only(top: AppDimensions.padding4h),
                    child: Text(
                      _otpError!,
                      style: customTextStyle(
                        AppTextSizes.stableTextSize,
                        AppColors.danger,
                        FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: AppDimensions.padding15h),
            GestureDetector(
              onTap: _resend,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Didn't receive code? ",
                      style: customTextStyle(
                        AppTextSizes.smallTextSize,
                        AppColors.lightGreyBorder,
                        FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      text: _isResending
                          ? "Sending..."
                          : _resendSecondsLeft > 0
                          ? "Resend in ${_resendSecondsLeft}s"
                          : "Resend",
                      style: customTextStyle(
                        AppTextSizes.largeMediumTextSize, // 14
                        resendDisabled
                            ? AppColors.lightGreyBorder
                            : AppColors.primaryDark,
                        FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppDimensions.padding25h),
            // Adjusted Verify Button
            PrimaryButton(
              text: 'Verify',
              width: AppDimensions.containerWidth150w,
              height: AppDimensions.containerHeight40h,
              isLoading: _isVerifying,
              onPressed: _verifyOtp,
            ),
          ],
        ),
      ),
    );
  }
}
