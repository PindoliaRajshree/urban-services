// File: lib/features/home_provider/complete_profile/models/sub_service_type.dart
// Purpose: Parses GET provider/provider/sub-service-types?service_type_id=<id>.
//
// Confirmed shape:
// {
//   "status": true,
//   "message": "Sub service types fetched successfully",
//   "data": [
//     { "id": 1, "service_types": 1, "name": "Home Cleaning", "status": true },
//     ...
//   ]
// }

class SubServiceType {
  SubServiceType({
    required this.id,
    required this.serviceTypeId,
    required this.name,
    this.status,
  });

  final int id;
  final int serviceTypeId;
  final String name;
  final bool? status;

  factory SubServiceType.fromJson(Map<String, dynamic> json) {
    return SubServiceType(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      serviceTypeId: json['service_types'] is int
          ? json['service_types'] as int
          : int.tryParse('${json['service_types']}') ?? 0,
      name: json['name']?.toString() ?? '',
      status: json['status'] is bool ? json['status'] as bool : null,
    );
  }
}

class SubServiceTypeListResponse {
  SubServiceTypeListResponse({this.message, required this.data});

  final String? message;
  final List<SubServiceType> data;

  factory SubServiceTypeListResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['data'] is List ? json['data'] as List : [];
    return SubServiceTypeListResponse(
      message: json['message']?.toString(),
      data: list
          .map((e) => SubServiceType.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
