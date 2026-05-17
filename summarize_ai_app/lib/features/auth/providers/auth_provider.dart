import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/user_model.dart';

// ── Local Database Models ────────────────────────────────────────────────

class LocalAccount {
  final String id;
  final String name;
  final String email;
  final String password;
  final String? avatarUrl;

  LocalAccount({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'avatarUrl': avatarUrl,
  };

  factory LocalAccount.fromJson(Map<String, dynamic> json) => LocalAccount(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    password: json['password'] as String,
    avatarUrl: json['avatarUrl'] as String?,
  );
}

class LoginRecord {
  final String email;
  final DateTime timestamp;
  final String action; // "Đăng nhập" hoặc "Đăng ký"

  LoginRecord({
    required this.email,
    required this.timestamp,
    required this.action,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'timestamp': timestamp.toIso8601String(),
    'action': action,
  };

  factory LoginRecord.fromJson(Map<String, dynamic> json) => LoginRecord(
    email: json['email'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    action: json['action'] as String,
  );
}

// ── Auth State ─────────────────────────────────────────────────────────

enum AuthStatus { idle, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final List<LoginRecord> accessHistory;

  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.user,
    this.errorMessage,
    this.accessHistory = const [],
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    List<LoginRecord>? accessHistory,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      accessHistory: accessHistory ?? this.accessHistory,
    );
  }
}

// ── Auth Notifier ──────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier()
      : super(const AuthState(status: AuthStatus.unauthenticated)) {
    _initAuth();
  }

  static const String _accountsKey = 'local_accounts_db';
  static const String _activeUserEmailKey = 'active_user_email';
  static const String _loginHistoryKey = 'access_history';

  /// Initial checking of stored active login session
  Future<void> _initAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load access history
      final historyStr = prefs.getString(_loginHistoryKey) ?? '[]';
      final List<dynamic> historyList = json.decode(historyStr) as List<dynamic>;
      final List<LoginRecord> records = historyList
          .map((item) => LoginRecord.fromJson(item as Map<String, dynamic>))
          .toList();

      // Load active session
      final activeEmail = prefs.getString(_activeUserEmailKey);
      if (activeEmail != null && activeEmail.isNotEmpty) {
        // Load registered accounts
        final accountsStr = prefs.getString(_accountsKey) ?? '[]';
        final List<dynamic> jsonList = json.decode(accountsStr) as List<dynamic>;
        final accounts = jsonList
            .map((item) => LocalAccount.fromJson(item as Map<String, dynamic>))
            .toList();

        LocalAccount? matchedAccount;
        for (final a in accounts) {
          if (a.email.toLowerCase() == activeEmail.toLowerCase()) {
            matchedAccount = a;
            break;
          }
        }

        if (matchedAccount != null) {
          state = AuthState(
            status: AuthStatus.authenticated,
            user: UserModel(
              id: matchedAccount.id,
              name: matchedAccount.name,
              email: matchedAccount.email,
            ),
            accessHistory: records,
          );
          return;
        }
      }
      state = AuthState(
        status: AuthStatus.unauthenticated,
        accessHistory: records,
      );
    } catch (e) {
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }

  /// Helper to record new logins
  Future<List<LoginRecord>> _addLoginRecord(String email, String action) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString(_loginHistoryKey) ?? '[]';
      final List<dynamic> historyList = json.decode(historyStr) as List<dynamic>;
      final List<LoginRecord> records = historyList
          .map((item) => LoginRecord.fromJson(item as Map<String, dynamic>))
          .toList();

      records.insert(
        0,
        LoginRecord(
          email: email,
          timestamp: DateTime.now(),
          action: action,
        ),
      );

      // Keep only last 10 login history records
      if (records.length > 10) {
        records.removeRange(10, records.length);
      }

      await prefs.setString(_loginHistoryKey, json.encode(records.map((r) => r.toJson()).toList()));
      return records;
    } catch (e) {
      return const [];
    }
  }

  /// Login with email and password.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // Simulate real API latency
      await Future.delayed(const Duration(milliseconds: 600));

      final prefs = await SharedPreferences.getInstance();

      // Load registered accounts
      final accountsStr = prefs.getString(_accountsKey) ?? '[]';
      final List<dynamic> jsonList = json.decode(accountsStr) as List<dynamic>;
      final List<LocalAccount> accounts = jsonList
          .map((item) => LocalAccount.fromJson(item as Map<String, dynamic>))
          .toList();

      // Check matching credentials
      LocalAccount? matchedAccount;
      for (final a in accounts) {
        if (a.email.toLowerCase() == email.toLowerCase() && a.password == password) {
          matchedAccount = a;
          break;
        }
      }



      if (matchedAccount == null) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Email hoặc mật khẩu không chính xác!',
        );
        return false;
      }

      // Save active session
      await prefs.setString(_activeUserEmailKey, email);

      // Log login record
      final records = await _addLoginRecord(email, 'Đăng nhập');

      state = AuthState(
        status: AuthStatus.authenticated,
        user: UserModel(
          id: matchedAccount.id,
          name: matchedAccount.name,
          email: matchedAccount.email,
        ),
        accessHistory: records,
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
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // Simulate real API latency
      await Future.delayed(const Duration(milliseconds: 600));

      final prefs = await SharedPreferences.getInstance();

      // Load registered accounts
      final accountsStr = prefs.getString(_accountsKey) ?? '[]';
      final List<dynamic> jsonList = json.decode(accountsStr) as List<dynamic>;
      final List<LocalAccount> accounts = jsonList
          .map((item) => LocalAccount.fromJson(item as Map<String, dynamic>))
          .toList();

      // Check if email already registered
      final exists = accounts.any((a) => a.email.toLowerCase() == email.toLowerCase());
      if (exists) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Email này đã được đăng ký trước đó!',
        );
        return false;
      }

      // Add new account
      final newAccount = LocalAccount(
        id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
        name: email.split('@')[0],
        email: email,
        password: password,
      );
      accounts.add(newAccount);

      // Save accounts back
      await prefs.setString(_accountsKey, json.encode(accounts.map((a) => a.toJson()).toList()));

      // Log login record
      final records = await _addLoginRecord(email, 'Đăng ký');

      state = AuthState(
        status: AuthStatus.unauthenticated,
        accessHistory: records,
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
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeUserEmailKey);
      state = AuthState(
        status: AuthStatus.unauthenticated,
        accessHistory: state.accessHistory,
      );
    } catch (e) {
      state = AuthState(
        status: AuthStatus.unauthenticated,
        accessHistory: state.accessHistory,
      );
    }
  }

  /// Delete the currently authenticated user account and all associated data.
  Future<bool> deleteAccount() async {
    final currentUser = state.user;
    if (currentUser == null) return false;

    state = state.copyWith(status: AuthStatus.loading);
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Remove the user from the local accounts database
      final accountsStr = prefs.getString(_accountsKey) ?? '[]';
      final List<dynamic> jsonList = json.decode(accountsStr) as List<dynamic>;
      final List<LocalAccount> accounts = jsonList
          .map((item) => LocalAccount.fromJson(item as Map<String, dynamic>))
          .toList();

      accounts.removeWhere((a) => a.email.toLowerCase() == currentUser.email.toLowerCase());
      await prefs.setString(_accountsKey, json.encode(accounts.map((a) => a.toJson()).toList()));

      // 2. Clear user session
      await prefs.remove(_activeUserEmailKey);

      // 3. Remove the user's specific summary/chat history!
      final historyKey = 'history_sessions_v1_${currentUser.email.toLowerCase().replaceAll('.', '_')}';
      await prefs.remove(historyKey);

      // 4. Log out locally
      state = AuthState(
        status: AuthStatus.unauthenticated,
        accessHistory: state.accessHistory,
      );
      return true;
    } catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
        accessHistory: state.accessHistory,
      );
      return false;
    }
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
  return AuthNotifier();
});
