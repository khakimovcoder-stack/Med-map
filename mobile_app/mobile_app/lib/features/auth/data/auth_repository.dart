import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/storage/secure_storage.dart';
import 'models/auth_session.dart';

abstract interface class AuthRepository {
  Future<OneIdStartResult> start(String phoneE164);
  Future<AuthSession> verify({
    required String sessionId,
    required String otp,
  });
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<String?> currentUserName();
}

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._client, this._storage);
  final ApiClient _client;
  final SecureStorage _storage;

  @override
  Future<OneIdStartResult> start(String phoneE164) async {
    final res = await _client.postJson(
      ApiEndpoints.oneIdStart,
      body: {'phone': phoneE164},
    );
    return OneIdStartResult.fromJson(res['data'] as Map<String, dynamic>);
  }

  @override
  Future<AuthSession> verify({
    required String sessionId,
    required String otp,
  }) async {
    final res = await _client.postJson(
      ApiEndpoints.oneIdVerify,
      body: {'session_id': sessionId, 'otp_code': otp},
    );
    final session = AuthSession.fromJson(res['data'] as Map<String, dynamic>);
    await _storage.setAuthToken(session.token);
    await _storage.setUser(
      id: session.user.id,
      phone: session.user.phone,
      fullName: session.user.fullName,
    );
    return session;
  }

  @override
  Future<void> logout() => _storage.clearAuth();

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> currentUserName() => _storage.getUserName();
}

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._storage);
  final SecureStorage _storage;

  static const String _kMockOtp = '123456';

  @override
  Future<OneIdStartResult> start(String phoneE164) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!RegExp(r'^\+998\d{9}$').hasMatch(phoneE164)) {
      throw const ApiException(
        code: 'VALIDATION_ERROR',
        message: 'Telefon raqam noto\'g\'ri',
      );
    }
    return OneIdStartResult(
      sessionId: 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
      phone: phoneE164,
      expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      message: 'Tasdiqlash kodi yuborildi (mock: 123456)',
    );
  }

  @override
  Future<AuthSession> verify({
    required String sessionId,
    required String otp,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (otp != _kMockOtp) {
      throw const ApiException(
        code: 'OTP_INVALID',
        message: 'Tasdiqlash kodi noto\'g\'ri',
      );
    }
    final session = AuthSession.fromJson({
      'token': 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
      'token_type': 'Bearer',
      'expires_in': 86400,
      'user': {
        'id': 'mock-user-001',
        'phone': '+998901111111',
        'full_name': 'Ali Valiyev',
      },
    });
    await _storage.setAuthToken(session.token);
    await _storage.setUser(
      id: session.user.id,
      phone: session.user.phone,
      fullName: session.user.fullName,
    );
    return session;
  }

  @override
  Future<void> logout() => _storage.clearAuth();

  @override
  Future<bool> isAuthenticated() async {
    final token = await _storage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<String?> currentUserName() => _storage.getUserName();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  if (ApiEndpoints.kUseMock) return MockAuthRepository(storage);
  final client = ref.watch(apiClientProvider);
  return AuthRepositoryImpl(client, storage);
});
