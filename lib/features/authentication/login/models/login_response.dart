// File: lib/features/authentication/login/models/login_response.dart
// Purpose: Parses the /login success payload.
//
// Confirmed shape (live response):
// {
//   "status": true,
//   "message": "Login successful",
//   "data": {
//     "token": "...",
//     "user": {
//       "id": 2, "name": "...", "email": "...", "mobile": "...",
//       "google_id": null, "login_type": "manual", "profile_image": null,
//       "role": "user", "is_mobile_verified": false,
//       "mobile_verified_at": null, "email_verified_at": null,
//       "status": "active",
//       "created_at": "...", "updated_at": "..."
//     }
//   }
// }

class LoginResponse {
  LoginResponse({this.message, this.token, this.user});

  final String? message;
  final String? token;
  final LoginUser? user;

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;

    return LoginResponse(
      message: json['message']?.toString(),
      token: (data['token'] ?? data['access_token'])?.toString(),
      user: (data['user'] is Map<String, dynamic>)
          ? LoginUser.fromJson(data['user'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoginUser {
  LoginUser({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.googleId,
    this.loginType,
    this.profileImage,
    this.role,
    this.isMobileVerified,
    this.mobileVerifiedAt,
    this.emailVerifiedAt,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  final int? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? googleId;
  final String? loginType;
  final String? profileImage;
  final String? role;
  final bool? isMobileVerified;
  final String? mobileVerifiedAt;
  final String? emailVerifiedAt;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  factory LoginUser.fromJson(Map<String, dynamic> json) {
    return LoginUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}'),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      googleId: json['google_id']?.toString(),
      loginType: json['login_type']?.toString(),
      profileImage: json['profile_image']?.toString(),
      role: json['role']?.toString(),
      isMobileVerified: json['is_mobile_verified'] is bool
          ? json['is_mobile_verified'] as bool
          : null,
      mobileVerifiedAt: json['mobile_verified_at']?.toString(),
      emailVerifiedAt: json['email_verified_at']?.toString(),
      status: json['status']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }
}
