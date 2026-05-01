// lib/providers/app_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/app_data.dart';

// ════════════════════════════════════════════════════════════
// AUTH PROVIDER — manages login state across the whole app
// ════════════════════════════════════════════════════════════
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

// ════════════════════════════════════════════════════════════
// MOOD PROVIDER — selected mood drives AI suggestions
// ════════════════════════════════════════════════════════════
class MoodState {
  final String mood;
  final int moodIndex;
  final Map<String, dynamic>? intent; // AI intent returned from backend
  MoodState({this.mood = 'Calm', this.moodIndex = 0, this.intent});
  MoodState copyWith({String? mood, int? moodIndex, Map<String, dynamic>? intent}) =>
      MoodState(mood: mood ?? this.mood, moodIndex: moodIndex ?? this.moodIndex, intent: intent ?? this.intent);
}

class MoodNotifier extends StateNotifier<MoodState> {
  MoodNotifier() : super(MoodState());

  Future<void> selectMood(String mood, int index) async {
    state = state.copyWith(mood: mood, moodIndex: index);
    try {
      // Log mood to backend — also returns AI intent
      final result = await ApiService.logMood(mood, context: 'cook');
      if (result['intent'] != null) {
        state = state.copyWith(intent: result['intent'] as Map<String, dynamic>);
      }
    } catch (_) {
      // Backend not connected — still works with mock data
    }
  }
}

final moodProvider = StateNotifierProvider<MoodNotifier, MoodState>((ref) => MoodNotifier());

// ════════════════════════════════════════════════════════════
// FEED PROVIDER — community feed with pagination
// ════════════════════════════════════════════════════════════
class FeedState {
  final List<CommunityPost> posts;
  final bool isLoading, hasMore, usedMock;
  final String? cursor, error, filter;
  FeedState({this.posts = const [], this.isLoading = false, this.hasMore = true, this.cursor, this.error, this.filter = 'all', this.usedMock = false});
  FeedState copyWith({List<CommunityPost>? posts, bool? isLoading, bool? hasMore, String? cursor, String? error, String? filter, bool? usedMock}) =>
      FeedState(posts: posts ?? this.posts, isLoading: isLoading ?? this.isLoading, hasMore: hasMore ?? this.hasMore, cursor: cursor ?? this.cursor, error: error, filter: filter ?? this.filter, usedMock: usedMock ?? this.usedMock);
}

class FeedNotifier extends StateNotifier<FeedState> {
  FeedNotifier() : super(FeedState()) { loadFeed(); }

  Future<void> loadFeed({bool refresh = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final cursor = refresh ? null : state.cursor;
      final data = await ApiService.getFeed(type: state.filter ?? 'all', cursor: cursor);
      final posts = (data['posts'] as List).map((p) => CommunityPost.fromJson(p)).toList();
      state = state.copyWith(
        posts: refresh ? posts : [...state.posts, ...posts],
        isLoading: false, hasMore: posts.length >= 20,
        cursor: posts.isNotEmpty ? posts.last.time : null,
        usedMock: false,
      );
    } catch (_) {
      // Fall back to mock data if backend not connected
      if (refresh || state.posts.isEmpty) {
        state = state.copyWith(posts: List.from(AppData.posts), isLoading: false, hasMore: false, usedMock: true);
      } else {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> setFilter(String filter) async {
    state = FeedState(filter: filter);
    await loadFeed();
  }

  void toggleLike(String postId) {
    final posts = state.posts.map((p) {
      if (p.id != postId) return p;
      p.liked = !p.liked;
      p.likes += p.liked ? 1 : -1;
      return p;
    }).toList();
    state = state.copyWith(posts: posts);
    try {
      final post = state.posts.firstWhere((p) => p.id == postId);
      if (post.liked) ApiService.likePost(postId); else ApiService.unlikePost(postId);
    } catch (_) {}
  }

  void addPost(CommunityPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) => FeedNotifier());
