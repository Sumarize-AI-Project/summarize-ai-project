import '../../core/constants/app_constants.dart';

/// Mock authentication service for UI development.
/// Will be replaced with real API service in backend integration phase.
class MockAuthService {
  /// Simulates a login request. Accepts any email/password combination.
  Future<MockUser> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(AppConstants.mockApiDelay);
    return MockUser(
      id: 'usr_001',
      name: 'Nguyễn Văn A',
      email: email,
      avatarUrl: null,
    );
  }

  /// Simulates a registration request.
  Future<MockUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(AppConstants.mockApiDelay);
    return MockUser(
      id: 'usr_002',
      name: name,
      email: email,
      avatarUrl: null,
    );
  }

  /// Simulates a logout request.
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

/// Simple user model for mock data.
class MockUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const MockUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });
}
