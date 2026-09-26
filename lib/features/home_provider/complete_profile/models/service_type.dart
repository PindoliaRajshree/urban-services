// File: lib/features/home_provider/complete_profile/models/service_type.dart
// Purpose: Parses GET provider/provider/service-types.
//
// Confirmed shape:
// {
//   "status": true,
//   "message": "Service types fetched successfully",
//   "data": [
//     { "id": 1, "name": "Cleaning", "status": true },
//     ...
//   ]
// }

class ServiceType {
  ServiceType({required this.id, required this.name, this.status});

  final int id;
  final String name;
  final bool? status;

  factory ServiceType.fromJson(Map<String, dynamic> json) {
    return ServiceType(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status'] is bool ? json['status'] as bool : null,
    );
  }
}

class ServiceTypeListResponse {
  ServiceTypeListResponse({this.message, required this.data});

  final String? message;
  final List<ServiceType> data;

  factory ServiceTypeListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data'] is List ? json['data'] as List : [];
    return ServiceTypeListResponse(
      message: json['message']?.toString(),
      data: list
          .map((e) => ServiceType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
