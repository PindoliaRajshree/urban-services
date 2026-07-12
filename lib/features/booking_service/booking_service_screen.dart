// File: lib/features/booking_service/booking_service_screen.dart
// Purpose: Lets the user pick a date, time, address and notes before booking
// a service (opened from the "Book Now" button on the Service Details screen).

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/routes/route_names.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class _DateOption {
  final String day;
  final String date;
  final String month;

  const _DateOption(this.day, this.date, this.month);
}

class BookingServiceScreen extends StatefulWidget {
  /// Starting price amount, e.g. "699"
  final String price;

  const BookingServiceScreen({super.key, this.price = '699'});

  @override
  State<BookingServiceScreen> createState() => _BookingServiceScreenState();
}

class _BookingServiceScreenState extends State<BookingServiceScreen> {
  static const int _maxNotesLength = 200;
  static const String _address =
      '123, Green Park, Main Road, New Delhi-110016';

  int _selectedDateIndex = 0;
  int _selectedTimeIndex = 1; // Defaults to "11:00 AM"
  int _notesLength = 0;

  final TextEditingController _notesController = TextEditingController();

  final List<_DateOption> _dates = const [
    _DateOption('Mon', '11', 'May'),
    _DateOption('Tue', '12', 'May'),
    _DateOption('Wed', '13', 'May'),
    _DateOption('Thu', '14', 'May'),
    _DateOption('Fri', '15', 'May'),
  ];

  final List<String> _times = const [
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '1:00 PM',
    '2:00 PM',
    '3:00 PM',
    '4:00 PM',
    '5:00 PM',
    '6:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    _notesController.addListener(() {
      setState(() {
        _notesLength = _notesController.text.length;
      });
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Widget _sectionHeading(String title) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.padding10w,
        vertical: AppDimensions.padding6h,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radius6r),
      ),
      child: ShaderMask(
        shaderCallback: (bounds) =>
            AppColors.gradient.createShader(Offset.zero & bounds.size),
        child: Text(
          title,
          style: customTextStyle(12, AppColors.white, FontWeight.w500),
        ),
      ),
    );
  }

  Widget _sectionDivider() {
    return Container(
      height: 0.5,
      width: double.infinity,
      color: const Color.fromRGBO(160, 162, 166, 1),
    );
  }

  Widget _priceColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '₹ ${widget.price}',
          style: customTextStyle(21, AppColors.primaryDark, FontWeight.w700),
        ),
        Text(
          'Starting from',
          style: customTextStyle(10, AppColors.darkGrey, FontWeight.w500),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(244, 249, 253, 1),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: CommonAppBar(
                title: 'Booking Services',
                showMoreIcon: true,
              ),
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
                    // Select Date
                    _sectionHeading('Select Date'),
                    SizedBox(height: AppDimensions.padding12h),
                    SizedBox(
                      height: AppDimensions.containerHeight85h,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dates.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(width: AppDimensions.padding10w),
                        itemBuilder: (context, index) {
                          final date = _dates[index];
                          final isSelected = index == _selectedDateIndex;
                          final Color textColor = isSelected
                              ? AppColors.white
                              : AppColors.text;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedDateIndex = index),
                            child: Container(
                              width: AppDimensions.containerWidth70w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryDark
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radius10r,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    date.day,
                                    style: customTextStyle(
                                      14,
                                      textColor,
                                      FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.padding4h),
                                  Text(
                                    date.date,
                                    style: customTextStyle(
                                      16,
                                      textColor,
                                      FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: AppDimensions.padding4h),
                                  Text(
                                    date.month,
                                    style: customTextStyle(
                                      14,
                                      textColor,
                                      FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Select Time
                    _sectionHeading('Select Time'),
                    SizedBox(height: AppDimensions.padding12h),
                    ...List.generate(3, (rowIndex) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: AppDimensions.padding10h,
                        ),
                        child: Row(
                          children: List.generate(3, (colIndex) {
                            final index = rowIndex * 3 + colIndex;
                            final time = _times[index];
                            final isSelected = index == _selectedTimeIndex;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppDimensions.padding5w,
                                ),
                                child: GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedTimeIndex = index,
                                  ),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppDimensions.padding12h,
                                    ),
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.white,
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radius10r,
                                      ),
                                    ),
                                    child: Text(
                                      time,
                                      style: customTextStyle(
                                        12,
                                        isSelected
                                            ? AppColors.white
                                            : AppColors.text,
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      );
                    }),
                    SizedBox(height: AppDimensions.padding10h),

                    // Address
                    _sectionHeading('Address'),
                    SizedBox(height: AppDimensions.padding12h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(AppDimensions.padding15w),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.darkGrey, width: 1),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius20r,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                AppImages.home,
                                width: AppDimensions.containerWidth20w,
                                height: AppDimensions.containerHeight20h,
                              ),
                              SizedBox(width: AppDimensions.padding8w),
                              Text(
                                'Home',
                                style: customTextStyle(
                                  14,
                                  AppColors.black,
                                  FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppDimensions.padding10w,
                                    vertical: AppDimensions.padding4h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.grey,
                                    borderRadius: BorderRadius.circular(
                                      AppDimensions.radius5r,
                                    ),
                                  ),
                                  child: Text(
                                    'Change',
                                    style: customTextStyle(
                                      12,
                                      AppColors.primaryDark,
                                      FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: AppDimensions.padding8h),
                          Text(
                            _address,
                            style: customTextStyle(
                              14,
                              AppColors.darkGrey,
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),

                    // Add Notes
                    _sectionHeading('Add Notes (Optional)'),
                    SizedBox(height: AppDimensions.padding12h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding15w,
                        vertical: AppDimensions.padding10h,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color.fromRGBO(160, 162, 166, 1),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius20r,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextField(
                            controller: _notesController,
                            maxLength: _maxNotesLength,
                            maxLines: 3,
                            style: customTextStyle(
                              14,
                              AppColors.black,
                              FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Any special instructions?',
                              hintStyle: customTextStyle(
                                14,
                                AppColors.darkGrey,
                                FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                          Text(
                            '$_notesLength/$_maxNotesLength',
                            style: customTextStyle(
                              10,
                              AppColors.darkGrey,
                              FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppDimensions.padding20h),
                  ],
                ),
              ),
            ),

            // Sticky Footer: divider + Price + Book Now
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: AppDimensions.padding20w,
              ),
              child: _sectionDivider(),
            ),
            Padding(
              padding: EdgeInsets.all(AppDimensions.padding20w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _priceColumn(),
                  GestureDetector(
                    onTap: () {
                      final date = _dates[_selectedDateIndex];
                      final time = _times[_selectedTimeIndex];
                      Get.toNamed(
                        RouteNames.paymentScreen,
                        arguments: {
                          'price': widget.price,
                          'dateTime': '${date.date} ${date.month} 2024, $time',
                          'address': _address,
                        },
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding30w,
                        vertical: AppDimensions.padding12h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radius10r,
                        ),
                      ),
                      child: Text(
                        'Book Now',
                        style: customTextStyle(
                          20,
                          AppColors.white,
                          FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
