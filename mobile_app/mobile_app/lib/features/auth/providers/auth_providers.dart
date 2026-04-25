import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/models/auth_session.dart';

class AuthState {
  const AuthState({this.isAuthenticated = false, this.userName, this.userPhone});

  final bool isAuthenticated;
  final String? userName;
  final String? userPhone;

  AuthState copyWith({
    bool? isAuthenticated,
    String? userName,
    String? userPhone,
  }) =>
      AuthState(
        isAuthenticated: isAuthenticated ?? this.isAuthenticated,
        userName: userName ?? this.userName,
        userPhone: userPhone ?? this.userPhone,
      );
}

class AuthController extends StateNotifier<AsyncValue<AuthState>> {
  AuthController(this._repo) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final AuthRepository _repo;

  Future<void> _bootstrap() async {
    try {
      final isAuth = await _repo.isAuthenticated();
      final name = await _repo.currentUserName();
      state = AsyncValue.data(
        AuthState(isAuthenticated: isAuth, userName: name),
      );
    } on Exception catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> applySession(AuthSession session) async {
    state = AsyncValue.data(
      AuthState(
        isAuthenticated: true,
        userName: session.user.fullName,
        userPhone: session.user.phone,
      ),
    );
  }

  Future<void> logout() async {
    await _repo.logout();
    state = const AsyncValue.data(AuthState());
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<AuthState>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
