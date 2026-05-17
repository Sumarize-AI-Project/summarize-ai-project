import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_model.dart';
import '../../../shared/mock_services/mock_auth_service.dart';

// ── Auth State ─────────────────────────────────────────────────────────

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// ── Auth Notifier ──────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService)
      : super(const AuthState(status: AuthStatus.unauthenticated));

  final MockAuthService _authService;

  /// Login with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final mockUser = await _authService.login(
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: mockUser.id,
          name: mockUser.name,
          email: mockUser.email,
          avatarUrl: mockUser.avatarUrl,
        ),
      );
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Register a new account.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final mockUser = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: mockUser.id,
          name: mockUser.name,
          email: mockUser.email,
          avatarUrl: mockUser.avatarUrl,
        ),
      );
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Logout the current user.
  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.loading);
    await _authService.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Clear any error state.
  void clearError() {
    state = state.copyWith(
      status: AuthStatus.unauthenticated,
      errorMessage: null,
    );
  }
}

// ── Provider ───────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(MockAuthService());
});
