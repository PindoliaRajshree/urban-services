// File: lib/features/authentication/register/models/register_response.dart
// Purpose: Parses the /register success payload.
//
// Confirmed shape (live response, 2026-08-09):
// {
//   "status": true,
//   "message": "Registration successful",
//   "data": {
//     "token": "...",
//     "user": {
//       "name": "...", "mobile": "...", "email": "...", "role": "user",
//       "login_type": "manual", "status": 1,
//       "updated_at": "...", "created_at": "...", "id": 3
//     }
//   }
// }
//
// Key lookups still fall back to top-level in case other flows (e.g. Google
// sign-up) ever return a flatter shape.

class RegisterResponse {
  RegisterResponse({
    this.message,
    this.token,
    this.userId,
    this.name,
    this.email,
    this.mobile,
    this.role,
    this.loginType,
    this.status,
  });

  final String? message;
  final String? token;
  final String? userId;
  final String? name;
  final String? email;
  final String? mobile;
  final String? role;
  final String? loginType;
  final int? status;

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    // Some responses nest the payload under `data`, and/or a `user` object
    // within that. Fall back gracefully through each level.
    final Map<String, dynamic> data = (json['data'] is Map<String, dynamic>)
        ? json['data'] as Map<String, dynamic>
        : json;
    final Map<String, dynamic>? user = (data['user'] is Map<String, dynamic>)
        ? data['user'] as Map<String, dynamic>
        : (data.containsKey('name') ? data : null);

    return RegisterResponse(
      message: json['message']?.toString(),
      token: (data['token'] ?? data['access_token'])?.toString(),
      userId: (user?['id'] ?? data['id'])?.toString(),
      name: (user?['name'] ?? data['name'])?.toString(),
      email: (user?['email'] ?? data['email'])?.toString(),
      mobile: (user?['mobile'] ?? data['mobile'])?.toString(),
      role: (user?['role'] ?? data['role'])?.toString(),
      loginType: (user?['login_type'] ?? data['login_type'])?.toString(),
      status: int.tryParse((user?['status'] ?? data['status'])?.toString() ?? ''),
    );
  }
}
