// File: lib/features/my_bookings/my_bookings_screen.dart
// Purpose: Displays the user's bookings grouped into Upcoming, Completed and Cancelled tabs.

import 'package:flutter/material.dart';
import 'package:urban_services/core/colors/colors.dart';
import 'package:urban_services/core/constants/app_dimensions.dart';
import 'package:urban_services/core/constants/app_images.dart';
import 'package:urban_services/widgets/booking_card.dart';
import 'package:urban_services/widgets/common_app_bar.dart';
import 'package:urban_services/widgets/custom_text_style.dart';

class _Booking {
  final String imagePath;
  final String serviceName;
  final BookingStatus status;
  final String dateTime;
  final String bookingId;
  final String buttonText;

  const _Booking({
    required this.imagePath,
    required this.serviceName,
    required this.status,
    required this.dateTime,
    required this.bookingId,
    required this.buttonText,
  });
}

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int _selectedTabIndex = 0;

  final List<String> _tabs = const ['Upcoming', 'Completed', 'Cancelled'];

  // Dummy booking data
  final List<_Booking> _bookings = const [
    _Booking(
      imagePath: AppImages.serviceDeep,
      serviceName: 'Deep Cleaning',
      status: BookingStatus.confirmed,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Track',
    ),
    _Booking(
      imagePath: AppImages.serviceBathroom,
      serviceName: 'Bathroom Cleaning',
      status: BookingStatus.completed,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Rebook',
    ),
    _Booking(
      imagePath: AppImages.serviceSofa,
      serviceName: 'Sofa Cleaning',
      status: BookingStatus.cancelled,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Book again',
    ),
    _Booking(
      imagePath: AppImages.serviceDeep,
      serviceName: 'Deep Cleaning',
      status: BookingStatus.confirmed,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Track',
    ),
    _Booking(
      imagePath: AppImages.serviceSofa,
      serviceName: 'Sofa Cleaning',
      status: BookingStatus.cancelled,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Book again',
    ),
    _Booking(
      imagePath: AppImages.serviceBathroom,
      serviceName: 'Bathroom Cleaning',
      status: BookingStatus.completed,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Rebook',
    ),
    _Booking(
      imagePath: AppImages.serviceSofa,
      serviceName: 'Sofa Cleaning',
      status: BookingStatus.cancelled,
      dateTime: '20 May 2024, 11:00 AM',
      bookingId: 'Booking ID: US987654321',
      buttonText: 'Book again',
    ),
  ];

  BookingStatus get _statusForTab {
    switch (_selectedTabIndex) {
      case 1:
        return BookingStatus.completed;
      case 2:
        return BookingStatus.cancelled;
      default:
        return BookingStatus.confirmed;
    }
  }

  void _onMorePressed() {
    // TODO: Hook up menu actions (e.g. filter, help) for the three-dot menu.
  }

  @override
  Widget build(BuildContext context) {
    final filteredBookings = _bookings
        .where((b) => b.status == _statusForTab)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.padding20w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: AppDimensions.padding15h),
              CommonAppBar(
                title: 'My Bookings',
                showMoreIcon: true,
                onMorePressed: _onMorePressed,
              ),
              SizedBox(height: AppDimensions.padding20h),

              // Tabs: Upcoming / Completed / Cancelled
              Row(
                children: List.generate(_tabs.length, (index) {
                  final bool isSelected = index == _selectedTabIndex;
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.padding4w,
                      ),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedTabIndex = index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: AppDimensions.padding10h,
                          ),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primaryDark
                                : AppColors.grey,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radius8r,
                            ),
                          ),
                          child: Text(
                            _tabs[index],
                            style: customTextStyle(
                              12,
                              isSelected ? AppColors.white : AppColors.text,
                              FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: AppDimensions.padding20h),

              // Booking Cards List
              Expanded(
                child: filteredBookings.isEmpty
                    ? Center(
                        child: Text(
                          'No bookings found',
                          style: customTextStyle(
                            12,
                            AppColors.darkGrey,
                            FontWeight.w500,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(
                          bottom: AppDimensions.padding20h,
                        ),
                        itemCount: filteredBookings.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: AppDimensions.padding12h),
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return BookingCard(
                            imagePath: booking.imagePath,
                            serviceName: booking.serviceName,
                            status: booking.status,
                            dateTime: booking.dateTime,
                            bookingId: booking.bookingId,
                            buttonText: booking.buttonText,
                            onButtonTap: () {},
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
