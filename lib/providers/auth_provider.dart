import "package:flutter_riverpod/flutter_riverpod.dart";
import "../models/user_model.dart";
import "service_providers.dart";

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({this.status = AuthStatus.unknown, this.user, this.error});

  final AuthStatus status;
  final UserModel? user;
  final String? error;

  AuthState copyWith({AuthStatus? status, UserModel? user, String? error}) {
    return AuthState(status: status ?? this.status, user: user ?? this.user, error: error);
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthState()) {
    _restore();
  }

  final Ref _ref;

  Future<void> _restore() async {
    final user = await _ref.read(authServiceProvider).restoreSession();
    state = user != null
        ? AuthState(status: AuthStatus.authenticated, user: user)
        : const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> login(String email, String password) async {
    try {
      final result = await _ref.read(authServiceProvider).login(email, password);
      state = AuthState(status: AuthStatus.authenticated, user: result.user);
      return true;
    } catch (e) {
      state = AuthState(status: AuthStatus.unauthenticated, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _ref.read(authServiceProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
