// File: lib/features/address/models/service_address_response.dart
// Purpose: Parses the POST /user/service-address success payload.
//
// Confirmed shape (live response, 2026-09-01):
// {
//   "status": true,
//   "message": "Service address saved successfully.",
//   "data": {
//     "user_id": 12,
//     "flat_apartment": null,
//     "floor_building": null,
//     "building_society_landmark": null,
//     "full_address": "vsdnsdnjds",
//     "landmark": null,
//     "city": "Mumbai",
//     "state": "Maharashtra",
//     "country": "India",
//     "pincode": "4700020",
//     "latitude": null,
//     "longitude": null,
//     "is_default": false,
//     "updated_at": "2026-09-01T15:29:20.000000Z",
//     "created_at": "2026-09-01T15:29:20.000000Z",
//     "id": 4
//   }
// }

class ServiceAddressResponse {
  ServiceAddressResponse({
    this.message,
    this.id,
    this.userId,
    this.flatApartment,
    this.floorBuilding,
    this.buildingSocietyLandmark,
    this.fullAddress,
    this.landmark,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.latitude,
    this.longitude,
    this.isDefault,
    this.createdAt,
    this.updatedAt,
  });

  final String? message;
  final int? id;
  final int? userId;
  final String? flatApartment;
  final String? floorBuilding;
  final String? buildingSocietyLandmark;
  final String? fullAddress;
  final String? landmark;
  final String? city;
  final String? state;
  final String? country;
  final String? pincode;
  final double? latitude;
  final double? longitude;
  final bool? isDefault;
  final String? createdAt;
  final String? updatedAt;

  factory ServiceAddressResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return ServiceAddressResponse(
      message: json['message']?.toString(),
      id: data['id'] is int ? data['id'] as int : int.tryParse('${data['id']}'),
      userId: data['user_id'] is int
          ? data['user_id'] as int
          : int.tryParse('${data['user_id']}'),
      flatApartment: data['flat_apartment']?.toString(),
      floorBuilding: data['floor_building']?.toString(),
      buildingSocietyLandmark: data['building_society_landmark']?.toString(),
      fullAddress: data['full_address']?.toString(),
      landmark: data['landmark']?.toString(),
      city: data['city']?.toString(),
      state: data['state']?.toString(),
      country: data['country']?.toString(),
      pincode: data['pincode']?.toString(),
      latitude: data['latitude'] is num
          ? (data['latitude'] as num).toDouble()
          : double.tryParse('${data['latitude']}'),
      longitude: data['longitude'] is num
          ? (data['longitude'] as num).toDouble()
          : double.tryParse('${data['longitude']}'),
      isDefault: data['is_default'] is bool ? data['is_default'] as bool : null,
      createdAt: data['created_at']?.toString(),
      updatedAt: data['updated_at']?.toString(),
    );
  }
}
