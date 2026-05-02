import 'package:flutter/material.dart';

class Restaurant {
  final String id, name, cuisine, address;
  final double? rating, distanceKm;
  final int? priceRange;
  final String? emoji, description, imageUrl, openStatus, moodAlignment;
  final List<String> moodTags, cuisineTags, menuHighlights;
  final bool matchesMood;
  final double? aiScore;

  const Restaurant({
    required this.id, required this.name, required this.cuisine,
    this.address = '', this.rating, this.distanceKm, this.priceRange,
    this.emoji, this.description, this.imageUrl, this.openStatus,
    this.moodAlignment, this.moodTags = const [],
    this.cuisineTags = const [], this.menuHighlights = const [],
    this.matchesMood = false, this.aiScore,
  });

  factory Restaurant.fromJson(Map<String, dynamic> j) => Restaurant(
    id: j['id'] ?? '', name: j['name'] ?? '', cuisine: (j['cuisine_tags'] as List?)?.join(' · ') ?? '',
    address: j['address'] ?? '',
    rating: (j['rating'] as num?)?.toDouble(),
    distanceKm: (j['distance_km'] as num?)?.toDouble(),
    priceRange: j['price_range'],
    emoji: j['emoji'], description: j['description'],
    imageUrl: j['image_url'],
    openStatus: 'Open',
    moodAlignment: j['mood_alignment'],
    moodTags: List<String>.from(j['mood_tags'] ?? []),
    cuisineTags: List<String>.from(j['cuisine_tags'] ?? []),
    menuHighlights: List<String>.from(j['menu_highlights'] ?? []),
    matchesMood: j['matches_mood'] ?? false,
    aiScore: (j['ai_score'] as num?)?.toDouble(),
  );

  String get priceString    => '\$' * (priceRange ?? 2);
  String get distanceString => distanceKm != null ? '${distanceKm!.toStringAsFixed(1)} km' : '';
  double get safeRating     => rating ?? 0.0;

  /// Derives a theme colour from mood tags so screens that use accentColor
  /// continue to work without requiring a stored colour field.
  Color get accentColor {
    if (moodTags.contains('Comfort'))               return const Color(0xFFFF8B6B);
    if (moodTags.contains('Energized') ||
        moodTags.contains('Happy'))                 return const Color(0xFFF7C59F);
    if (moodTags.contains('Focus'))                 return const Color(0xFF6DBF9E);
    return const Color(0xFF4FACB8); // Calm / default
  }
}
