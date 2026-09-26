// File: lib/routes/route_args.dart
// Purpose: Typed arguments passed as go_router `extra`, replacing the
// untyped `Get.arguments` maps. Defaults mirror the fallbacks the GetX
// routes used, so behaviour is unchanged when a caller passes nothing
// (see docs/UI_FLOW_AUDIT.md — those fake defaults hide missing data).

import 'package:urban_services/core/constants/app_images.dart';

const _defaultDateTime = '20 May 2024, 11:00 AM';
const _defaultAddress = '123, Green Park, Main Road, New Delhi-110016';
const _defaultBookingId = 'US123456789';
const _defaultServiceName = 'Deep Cleaning';

class AddressArgs {
  const AddressArgs({this.manage = false});

  /// True when opened to change the address (from Profile or Home) rather
  /// than during onboarding: the screen pops back instead of going Home.
  final bool manage;
}

class ChatArgs {
  const ChatArgs({
    this.name = 'Devon Lane',
    this.avatar = AppImages.serviceProvider,
    this.status = 'Online',
  });

  final String name;
  final String avatar;
  final String status;
}

class ServiceCategoryArgs {
  const ServiceCategoryArgs({
    this.categoryTitle = 'Cleaning Service',
    this.serviceCount = '30+ Services',
  });

  final String categoryTitle;
  final String serviceCount;
}

class ServiceDetailsArgs {
  const ServiceDetailsArgs({
    this.imagePath = AppImages.serviceDeep,
    this.reviewCount = '256',
    this.price = '699',
    this.duration = '2-3 Hours',
    this.includes = const [
      'Full home deep cleaning',
      'Dusting all areas',
      'Floor cleaning & mopping',
      'Kitchen platform cleaning',
      'Bathroom sanitization',
    ],
  });

  final String imagePath;
  final String reviewCount;
  final String price;
  final String duration;
  final List<String> includes;
}

class BookingArgs {
  const BookingArgs({this.price = '699'});

  final String price;
}

class PaymentArgs {
  const PaymentArgs({
    this.price = '699',
    this.dateTime = _defaultDateTime,
    this.address = _defaultAddress,
  });

  final String price;
  final String dateTime;
  final String address;
}

class PaymentSuccessArgs {
  const PaymentSuccessArgs({
    this.bookingId = _defaultBookingId,
    this.serviceName = _defaultServiceName,
    this.dateTime = _defaultDateTime,
    this.address = _defaultAddress,
  });

  final String bookingId;
  final String serviceName;
  final String dateTime;
  final String address;
}

class LiveTrackingArgs {
  const LiveTrackingArgs({
    this.bookingId = _defaultBookingId,
    this.serviceName = _defaultServiceName,
    this.dateTime = _defaultDateTime,
  });

  final String bookingId;
  final String serviceName;
  final String dateTime;
}
