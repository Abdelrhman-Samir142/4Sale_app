import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';
import '../services/auth_service.dart';

/// Auth state exposed to the entire app.
final authProvider =
    NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthState {
  final Map<String, dynamic>? user;
  final bool isLoading;
  final String? error;

  const AuthState({this.user, this.isLoading = false, this.error});

  bool get isLoggedIn => user != null;
  int? get userId => user?['user']?['id'] as int?;
  String? get username => user?['user']?['username'] as String?;
  bool get isAdmin =>
      user?['user']?['is_staff'] == true ||
      user?['user']?['is_superuser'] == true;

  AuthState copyWith({
    Map<String, dynamic>? user,
    bool? isLoading,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _init();
    return const AuthState(isLoading: true);
  }

  Future<void> _init() async {
    try {
      final hasToken = await SecureStorageService.hasToken();
      if (hasToken) {
        await refreshUser();
      } else {
        state = const AuthState();
      }
    } catch (_) {
      state = const AuthState();
    }
  }

  /// Fetch `GET /auth/me/` and update state.
  Future<void> refreshUser() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final userData = await AuthService.getCurrentUser();
      state = AuthState(user: userData);
    } catch (e) {
      await SecureStorageService.clearTokens();
      state = const AuthState();
    }
  }

  /// Login with username/email + password.
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await AuthService.login(username, password);
      await refreshUser();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Register new user, then auto-login.
  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String password2,
    required String city,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await AuthService.register(
        username: username,
        email: email,
        password: password,
        password2: password2,
        city: city,
        firstName: firstName,
        lastName: lastName,
        phone: phone,
      );
      // Auto-login after successful registration
      try {
        await refreshUser();
      } catch (_) {
        // If refreshUser fails (e.g. tokens not returned from register),
        // fall back to explicit login with the same credentials.
        await AuthService.login(username, password);
        await refreshUser();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
      rethrow;
    }
  }

  /// Logout — clear tokens and state.
  Future<void> logout() async {
    await SecureStorageService.clearTokens();
    state = const AuthState();
  }
}
