enum PostType { recipe, dining }

class CommunityPost {
  final String id, user, handle, time, dish, avatar;
  int likes; final int comments;
  bool liked, saved;
  final String mood;
  final PostType postType;
  final String? moodBefore, moodAfter, restaurantName, note, imageUrl;

  CommunityPost({
    required this.id, required this.user, required this.handle,
    required this.time, required this.dish, required this.likes,
    required this.comments, required this.liked, required this.saved,
    required this.mood, required this.avatar,
    this.postType = PostType.recipe,
    this.moodBefore, this.moodAfter, this.restaurantName, this.note, this.imageUrl,
  });

  factory CommunityPost.fromJson(Map<String, dynamic> j) {
    final userMap = j['users'] as Map<String, dynamic>?;
    return CommunityPost(
      id: j['id'] ?? '',
      user: userMap?['name'] ?? 'User',
      handle: '@${userMap?['handle'] ?? 'user'}',
      time: _timeAgo(j['created_at']),
      dish: (j['meals']?['title']) ?? (j['restaurants']?['name']) ?? 'Experience',
      likes: j['like_count'] ?? 0,
      comments: j['comment_count'] ?? 0,
      liked: j['liked'] ?? false,
      saved: j['saved'] ?? false,
      mood: j['mood_after'] ?? '',
      avatar: (userMap?['name'] ?? 'U').split(' ').map((w) => w[0]).take(2).join(),
      postType: j['post_type'] == 'dining' ? PostType.dining : PostType.recipe,
      moodBefore: j['mood_before'],
      moodAfter: j['mood_after'],
      restaurantName: j['restaurants']?['name'],
      note: j['note'],
      imageUrl: j['image_url'],
    );
  }

  static String _timeAgo(String? iso) {
    if (iso == null) return '';
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
