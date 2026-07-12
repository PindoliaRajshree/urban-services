// File: lib/features/payment/payment_screen.dart
// Purpose: Shows the bill summary and lets the user pick a payment method
// (opened from the "Book Now" button on the Booking Service screen).

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';
import 'package:urban_services/widgets/primary_button.dart';
import 'package:urban_services/widgets/section_heading.dart';

class _PaymentMethod {
  final String name;
  final String subtitle;
  final String imagePath;

  const _PaymentMethod({
    required this.name,
    required this.subtitle,
    required this.imagePath,
  });
}

class PaymentScreen extends StatefulWidget {
  /// Amount to be paid, e.g. "699"
  final String price;

  /// Booking date & time text, e.g. "20 May 2024, 11:00 AM"
  final String dateTime;

  /// Booking address text
  final String address;

  const PaymentScreen({
    super.key,
    this.price = '699',
    this.dateTime = '20 May 2024, 11:00 AM',
    this.address = '123, Green Park, Main Road, New Delhi-110016',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  int _selectedMethodIndex = 0;

  final List<_PaymentMethod> _paymentMethods = const [
    _PaymentMethod(
      name: 'UPI',
      subtitle: 'Pay using any UPI app',
      imagePath: AppImages.upi,
    ),
    _PaymentMethod(
      name: 'Credit/Debit Card',
      subtitle: 'Visa, Mastercard, Rupay',
      imagePath: AppImages.creditDebitCard,
    ),
    _PaymentMethod(
      name: 'Net Banking',
      subtitle: 'All major banks',
      imagePath: AppImages.merchant,
    ),
    _PaymentMethod(
      name: 'Cash on Delivery',
      subtitle: 'on Delivery Pay after service',
      imagePath: AppImages.merchant,
    ),
  ];

  List<BoxShadow> get _cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      offset: const Offset(0, 1),
      blurRadius: 4,
      spreadRadius: 0,
    ),
  ];

  Widget _billDivider() {
    return Container(
      height: 0.5,
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: AppDimensions.padding10h),
      color: const Color.fromRGBO(160, 162, 166, 1),
    );
  }

  Widget _billRow(String key, String value) {
    final style = customTextStyle(14, AppColors.text, FontWeight.w500);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(key, style: style),
        SizedBox(width: AppDimensions.padding10w),
        Expanded(
          child: Text(value, style: style, textAlign: TextAlign.right),
        ),
      ],
    );
  }

  Widget _paymentMethodCard(int index) {
    final method = _paymentMethods[index];
    final bool isSelected = index == _selectedMethodIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedMethodIndex = index),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: AppDimensions.padding12h),
        padding: EdgeInsets.all(AppDimensions.padding15w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radius12r),
          boxShadow: _cardShadow,
        ),
        child: Row(
          children: [
            // Radio Indicator
            Container(
              width: AppDimensions.containerWidth20w,
              height: AppDimensions.containerHeight20h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryDark : AppColors.grey,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: isSelected
                  ? Container(
                      width: AppDimensions.containerWidth10w,
                      height: AppDimensions.containerHeight10h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryDark,
                      ),
                    )
                  : null,
            ),
            SizedBox(width: AppDimensions.padding12w),

            // Name + Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.name,
                    style: customTextStyle(
                      14,
                      AppColors.text,
                      FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppDimensions.padding2h),
                  Text(
                    method.subtitle,
                    style: customTextStyle(
                      10,
                      AppColors.darkGrey,
                      FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppDimensions.padding12w),

            // Method Image
            Image.asset(
              method.imagePath,
              width: AppDimensions.containerWidth40w,
              height: AppDimensions.containerHeight40h,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: CommonAppBar(title: 'Payment', showMoreIcon: true),
            ),
            SizedBox(height: AppDimensions.padding15h),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.padding20w,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bill Details
                    const SectionHeading(
                      title: 'Bill Details',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                    SizedBox(height: AppDimensions.padding12h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.padding15w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius12r,
                        ),
                        boxShadow: _cardShadow,
                      ),
                      child: Column(
                        children: [
                          _billRow('Details', '₹${widget.price}'),
                          _billDivider(),
                          _billRow('Date & Time', widget.dateTime),
                          _billDivider(),
                          _billRow('Address', widget.address),
                          _billDivider(),
                          _billRow('Total Amount', '₹${widget.price}'),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Select Payment Method
                    const SectionHeading(
                      title: 'Select Payment Method',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                    SizedBox(height: AppDimensions.padding12h),
                    ...List.generate(
                      _paymentMethods.length,
                      (index) => _paymentMethodCard(index),
                    ),
                    SizedBox(height: AppDimensions.padding10h),
                  ],
                ),
              ),
            ),

            // Pay Button
            Padding(
              padding: EdgeInsets.all(AppDimensions.padding20w),
              child: PrimaryButton(
                text: 'Pay ₹${widget.price}',
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
