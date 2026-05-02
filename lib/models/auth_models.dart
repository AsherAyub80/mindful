class AuthResult {
  final Map<String, dynamic> user;
  final String accessToken, refreshToken;
  AuthResult(
      {required this.user,
      required this.accessToken,
      required this.refreshToken});
  factory AuthResult.fromJson(Map<String, dynamic> j) => AuthResult(
      user: j['user'],
      accessToken: j['accessToken'],
      refreshToken: j['refreshToken']);
}

class UserProfile {
  final String id, email, name, handle;
  final String? avatarUrl, bio;
  final int streakCount;
  UserProfile(
      {required this.id,
      required this.email,
      required this.name,
      required this.handle,
      this.avatarUrl,
      this.bio,
      this.streakCount = 0});
  factory UserProfile.fromJson(Map<String, dynamic> j) => UserProfile(
      id: j['id'],
      email: j['email'],
      name: j['name'],
      handle: j['handle'],
      avatarUrl: j['avatar_url'],
      bio: j['bio'],
      streakCount: j['streak_count'] ?? 0);
}
