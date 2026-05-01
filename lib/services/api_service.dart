// lib/services/api_service.dart
// ─────────────────────────────────────────────────────────────
//  This is the ONLY file that talks to the Node.js backend.
//  Flutter → api_service.dart → Node.js API (port 3000)
//  Flutter NEVER talks to FastAPI directly.
// ─────────────────────────────────────────────────────────────
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_data.dart';

class ApiService {
  // ── CHANGE THIS to your computer's IP when testing on a real phone ──
  // Android emulator → use 10.0.2.2  (maps to your localhost)
  // iOS simulator    → use localhost
  // Real device      → use your computer's IP e.g. 192.168.1.10
  // Production       → use your Render.com URL
  static const String baseUrl = 'http://10.0.2.2:3000/v1';

  static const Duration timeout = Duration(seconds: 30);

  // ── Token helpers ────────────────────────────────────────────
  static Future<String?> _getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('access_token');
  }

  static Future<void> saveTokens(String access, String refresh) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('access_token', access);
    await p.setString('refresh_token', refresh);
  }

  static Future<void> clearTokens() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('access_token');
    await p.remove('refresh_token');
  }

  static Future<bool> hasToken() async {
    final t = await _getToken();
    return t != null && t.isNotEmpty;
  }

  // ── HTTP helpers ─────────────────────────────────────────────
  static Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final t = await _getToken();
      if (t != null) h['Authorization'] = 'Bearer $t';
    }
    return h;
  }

  static Map<String, dynamic> _parse(http.Response r) {
    final body = jsonDecode(r.body) as Map<String, dynamic>;
    if (r.statusCode >= 200 && r.statusCode < 300) return body;
    throw ApiException(
        message: body['error'] ?? 'Request failed',
        statusCode: r.statusCode,
        code: body['code']);
  }

  static Future<Map<String, dynamic>> get(String path,
      {bool auth = true, Map<String, String>? q}) async {
    var uri = Uri.parse('$baseUrl$path');
    if (q != null) uri = uri.replace(queryParameters: q);
    final r = await http
        .get(uri, headers: await _headers(auth: auth))
        .timeout(timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> post(String path,
      {dynamic body, bool auth = true}) async {
    final r = await http
        .post(Uri.parse('$baseUrl$path'),
            headers: await _headers(auth: auth), body: jsonEncode(body))
        .timeout(timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> patch(String path, {dynamic body}) async {
    final r = await http
        .patch(Uri.parse('$baseUrl$path'),
            headers: await _headers(), body: jsonEncode(body))
        .timeout(timeout);
    return _parse(r);
  }

  static Future<Map<String, dynamic>> delete(String path) async {
    final r = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(timeout);
    return _parse(r);
  }

  // ── Auth ─────────────────────────────────────────────────────
  static Future<AuthResult> register(
      {required String email,
      required String password,
      required String name,
      required String handle}) async {
    final d = await post('/auth/register',
        body: {
          'email': email,
          'password': password,
          'name': name,
          'handle': handle
        },
        auth: false);
    await saveTokens(d['accessToken'], d['refreshToken']);
    print(d);
    return AuthResult.fromJson(d);
  }

  static Future<AuthResult> login(
      {required String email, required String password}) async {
    final d = await post('/auth/login',
        body: {'email': email, 'password': password}, auth: false);
    await saveTokens(d['accessToken'], d['refreshToken']);
    return AuthResult.fromJson(d);
  }

  static Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    try {
      await post('/auth/logout',
          body: {'refreshToken': p.getString('refresh_token')});
    } catch (_) {}
    await clearTokens();
  }

  static Future<bool> refreshToken() async {
    try {
      final p = await SharedPreferences.getInstance();
      final rt = p.getString('refresh_token');
      if (rt == null) return false;
      final d =
          await post('/auth/refresh', body: {'refreshToken': rt}, auth: false);
      await saveTokens(d['accessToken'], d['refreshToken']);
      return true;
    } catch (_) {
      await clearTokens();
      return false;
    }
  }

  // ── User ─────────────────────────────────────────────────────
  static Future<UserProfile> getMe() async {
    final d = await get('/users/me');
    return UserProfile.fromJson(d['user']);
  }

  static Future<Map<String, dynamic>> getPreferences() async =>
      get('/users/me/preferences');

  static Future<void> updatePreferences(Map<String, dynamic> prefs) async =>
      post('/users/me/preferences', body: prefs);

  // ── Mood ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> logMood(String mood,
          {String? context}) async =>
      post('/moods',
          body: {'mood': mood, if (context != null) 'context': context});

  static Future<Map<String, dynamic>> getMoodInsights() async =>
      get('/moods/insights');

  // ── Meals ────────────────────────────────────────────────────
  static Future<List<Meal>> getMeals({String? mood}) async {
    final d =
        await get('/meals', q: {if (mood != null) 'mood': mood, 'limit': '20'});
    return (d['meals'] as List).map((m) => Meal.fromJson(m)).toList();
  }

  static Future<Map<String, dynamic>> getAiMeals(String mood) async =>
      post('/meals/ai-suggest', body: {'mood': mood, 'limit': 5});

  static Future<Map<String, dynamic>> getMealDetail(String id) async =>
      get('/meals/$id');

  // ── Restaurants ──────────────────────────────────────────────
  static Future<Map<String, dynamic>> getNearbyRestaurants({
    required double lat,
    required double lng,
    required String mood,
    double radius = 2.0,
  }) async =>
      get('/restaurants/nearby', q: {
        'lat': '$lat',
        'lng': '$lng',
        'mood': mood,
        'radius': '$radius',
      });

  static Future<Map<String, dynamic>> getRestaurantDetail(String id) async =>
      get('/restaurants/$id');

  // ── Posts ────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getFeed(
          {String type = 'all', String? cursor}) async =>
      get('/posts/feed',
          q: {'type': type, if (cursor != null) 'cursor': cursor});

  static Future<Map<String, dynamic>> createPost({
    required String postType,
    String? mealId,
    String? restaurantId,
    String? note,
    String? imageUrl,
    String? moodBefore,
    String? moodAfter,
    String? orderedItems,
  }) async =>
      post('/posts', body: {
        'post_type': postType,
        if (mealId != null) 'meal_id': mealId,
        if (restaurantId != null) 'restaurant_id': restaurantId,
        if (note != null) 'note': note,
        if (imageUrl != null) 'image_url': imageUrl,
        if (moodBefore != null) 'mood_before': moodBefore,
        if (moodAfter != null) 'mood_after': moodAfter,
        if (orderedItems != null) 'ordered_items': orderedItems,
      });

  static Future<void> likePost(String id) async =>
      post('/posts/$id/like', body: {});
  static Future<void> unlikePost(String id) async => delete('/posts/$id/like');

  // ── Upload ───────────────────────────────────────────────────
  static Future<String?> uploadImage(File file, {String type = 'post'}) async {
    final token = await _getToken();
    final req = http.MultipartRequest(
        'POST', Uri.parse('$baseUrl/uploads/image?type=$type'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';

    // Detect content type from extension, default to jpeg
    final ext = file.path.split('.').last.toLowerCase();
    final mimeMap = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
    };
    final contentType = mimeMap[ext] ?? 'image/jpeg';

    req.files.add(await http.MultipartFile.fromPath(
      'image',
      file.path,
      contentType: http.MediaType.parse(contentType),
    ));
    final streamed = await req.send().timeout(timeout);
    final res = await http.Response.fromStream(streamed);
    final body = jsonDecode(res.body);
    if (res.statusCode == 200) return body['url'] as String;
    return null;
  }
}

// ── Exception ─────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final String? code;
  ApiException({required this.message, required this.statusCode, this.code});
  bool get isUnauthorized => statusCode == 401;
}

// ── Response Models ───────────────────────────────────────────
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
