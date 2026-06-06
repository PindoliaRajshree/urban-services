import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_text_sizes.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class CustomTextField extends StatefulWidget {
  final String hintText;
  final String? prefixIconPath;
  final bool isPassword;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;

  final String? errorText;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIconPath,
    this.isPassword = false,
    this.controller,
    this.focusNode,
    this.textInputAction,
    this.keyboardType,
    this.onSubmitted,
    this.inputFormatters,
    this.errorText,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radius10r),
            border: Border.all(
              color: widget.errorText != null
                  ? AppColors.danger
                  : AppColors.grey,
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            obscureText: _obscureText,
            textInputAction: widget.textInputAction,
            keyboardType: widget.keyboardType,
            onSubmitted: widget.onSubmitted,
            inputFormatters: widget.inputFormatters,
            style: customTextStyle(
              AppTextSizes.largeMediumTextSize,
              AppColors.black,
              FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: customTextStyle(
                AppTextSizes.largeMediumTextSize,
                AppColors.darkGrey,
                FontWeight.w400,
              ),
              prefixIcon: widget.prefixIconPath != null
                  ? Padding(
                      padding: EdgeInsets.all(AppDimensions.padding12w),
                      child: Image.asset(
                        widget.prefixIconPath!,
                        height: AppDimensions.containerHeight20h,
                        width: AppDimensions.containerWidth20w,
                      ),
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding15w,
                vertical: AppDimensions.padding15h,
              ),
            ),
          ),
        ),
        if (widget.errorText != null) ...[
          SizedBox(height: AppDimensions.padding4h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding4w),
            child: Text(
              widget.errorText!,
              style: customTextStyle(
                AppTextSizes.smallTextSize,
                AppColors.danger,
                FontWeight.w400,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
