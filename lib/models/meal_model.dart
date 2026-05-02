class Meal {
  final String id, title, emoji, description;
  final String? mood, tag, imageUrl, moodAlignment, quickTip;
  final int? calories, prepTimeMin;
  final List<String> moodTags, dietaryTags;
  final double? aiScore;

  const Meal({
    required this.id, required this.title, required this.emoji,
    this.description = '', this.mood, this.tag, this.imageUrl,
    this.moodAlignment, this.quickTip, this.calories, this.prepTimeMin,
    this.moodTags = const [], this.dietaryTags = const [],
    this.aiScore,
  });

  factory Meal.fromJson(Map<String, dynamic> j) => Meal(
    id: j['id'] ?? '', title: j['title'] ?? '', emoji: j['emoji'] ?? '🍽️',
    description: j['description'] ?? '',
    calories: j['calories'], prepTimeMin: j['prep_time_min'],
    moodTags: List<String>.from(j['mood_tags'] ?? []),
    dietaryTags: List<String>.from(j['dietary_tags'] ?? []),
    imageUrl: j['image_url'],
    aiScore: (j['ai_score'] as num?)?.toDouble(),
    moodAlignment: j['mood_alignment'],
    quickTip: j['quick_tip'],
  );
}
