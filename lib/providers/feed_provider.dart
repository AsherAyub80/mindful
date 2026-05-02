import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../models/app_data.dart';

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
      final currentCursor = refresh ? null : state.cursor;
      final data = await ApiService.getFeed(type: state.filter ?? 'all', cursor: currentCursor);
      
      final List postsData = data['posts'] ?? [];
      final posts = postsData.map((p) => CommunityPost.fromJson(p)).toList();
      final String? nextCursor = data['nextCursor'];

      state = state.copyWith(
        posts: refresh ? posts : [...state.posts, ...posts],
        isLoading: false,
        hasMore: nextCursor != null,
        cursor: nextCursor,
        usedMock: false,
      );
    } catch (e) {
      print('Feed load error: $e');
      // Fall back to mock data if backend not connected
      if (refresh || state.posts.isEmpty) {
        state = state.copyWith(
          posts: List.from(AppData.posts),
          isLoading: false,
          hasMore: false,
          usedMock: true,
        );
      } else {
        state = state.copyWith(isLoading: false, error: 'Could not load more posts');
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
