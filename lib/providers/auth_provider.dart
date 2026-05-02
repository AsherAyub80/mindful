import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/auth_models.dart';
import '../core/exceptions.dart';

class AuthState {
  final UserProfile? user;
  final bool isLoading;
  final String? error;
  bool get isLoggedIn => user != null;
  AuthState({this.user, this.isLoading = false, this.error});
  AuthState copyWith({UserProfile? user, bool? isLoading, String? error, bool clearUser = false}) =>
      AuthState(user: clearUser ? null : user ?? this.user, isLoading: isLoading ?? this.isLoading, error: error);
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState(isLoading: true)) { _init(); }

  Future<void> _init() async {
    final hasToken = await ApiService.hasToken();
    if (!hasToken) { state = AuthState(); return; }
    try {
      final user = await ApiService.getMe();
      state = AuthState(user: user);
    } catch (_) {
      final refreshed = await ApiService.refreshToken();
      if (refreshed) {
        try { state = AuthState(user: await ApiService.getMe()); return; } catch (_) {}
      }
      state = AuthState();
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final r = await ApiService.login(email: email, password: password);
      state = AuthState(user: UserProfile.fromJson(r.user));
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Connection failed. Is the backend running?');
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String handle) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final r = await ApiService.register(email: email, password: password, name: name, handle: handle);
      state = AuthState(user: UserProfile.fromJson(r.user));
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (_) {
      state = state.copyWith(isLoading: false, error: 'Connection failed. Is the backend running?');
      return false;
    }
  }

  Future<void> logout() async {
    await ApiService.logout();
    state = AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier());
