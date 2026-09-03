// File: lib/features/address/models/service_address_request.dart
// Purpose: Request payload for POST /user/service-address. User-only — the
// provider flow never reaches the address screens, so there is no
// equivalent request for providers.

class ServiceAddressRequest {
  ServiceAddressRequest({
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
    required this.userId,
    this.flatApartment,
    this.floorBuilding,
    this.buildingSocietyLandmark,
    this.landmark,
  });

  final String fullAddress;
  final String city;
  final String state;
  final String pincode;
  final int userId;

  /// Flat/apartment number — collected on the Add Address form. Not part
  /// of the quick "use current location" flow, so it's omitted there.
  final String? flatApartment;

  /// Floor/building — same as above.
  final String? floorBuilding;

  /// Building/society/landmark — same as above.
  final String? buildingSocietyLandmark;

  /// Optional standalone landmark, distinct from
  /// [buildingSocietyLandmark].
  final String? landmark;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'full_address': fullAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'user_id': userId,
    };

    if (flatApartment != null && flatApartment!.trim().isNotEmpty) {
      map['flat_apartment'] = flatApartment!.trim();
    }
    if (floorBuilding != null && floorBuilding!.trim().isNotEmpty) {
      map['floor_building'] = floorBuilding!.trim();
    }
    if (buildingSocietyLandmark != null &&
        buildingSocietyLandmark!.trim().isNotEmpty) {
      map['building_society_landmark'] = buildingSocietyLandmark!.trim();
    }
    if (landmark != null && landmark!.trim().isNotEmpty) {
      map['landmark'] = landmark!.trim();
    }

    return map;
  }
}
