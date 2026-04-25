import 'package:flutter/foundation.dart';

@immutable
class OneIdStartResult {
  const OneIdStartResult({
    required this.sessionId,
    required this.phone,
    required this.expiresAt,
    this.message,
  });

  final String sessionId;
  final String phone;
  final DateTime expiresAt;
  final String? message;

  factory OneIdStartResult.fromJson(Map<String, dynamic> json) {
    return OneIdStartResult(
      sessionId: json['session_id'] as String,
      phone: json['phone'] as String? ?? '',
      expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? '') ??
          DateTime.now().add(const Duration(minutes: 5)),
      message: json['message'] as String?,
    );
  }
}

@immutable
class AuthSession {
  const AuthSession({
    required this.token,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  final String token;
  final String tokenType;
  final int expiresIn;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) {
    return AuthSession(
      token: json['token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: (json['expires_in'] as num?)?.toInt() ?? 0,
      user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    this.fullName,
  });

  final String id;
  final String phone;
  final String? fullName;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        phone: json['phone'] as String? ?? '',
        fullName: json['full_name'] as String?,
      );
}
