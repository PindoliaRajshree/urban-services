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
  });

  final String fullAddress;
  final String city;
  final String state;
  final String pincode;
  final int userId;

  Map<String, dynamic> toJson() {
    return {
      'full_address': fullAddress,
      'city': city,
      'state': state,
      'pincode': pincode,
      'user_id': userId,
    };
  }
}
