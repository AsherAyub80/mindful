import 'package:flutter/material.dart';

// ─── MODELS ──────────────────────────────────────────────────

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

class NutrientInfo {
  final String label; final int value, max; final Color color;
  const NutrientInfo({required this.label, required this.value, required this.max, required this.color});
}

// ─── STATIC MOCK DATA (used when backend not connected) ───────

class AppData {
  static const moodEmojis  = ['🌿', '⚡', '🤍', '🎯', '☀️'];
  static const moodLabels  = ['Calm', 'Energized', 'Comfort', 'Focus', 'Happy'];
  static const moodMessages = {
    'Calm'     : "Since you're feeling calm, here are serene, quiet spots nearby",
    'Energized': "Since you're energized, here are vibrant, lively places nearby",
    'Comfort'  : "Since you're seeking comfort, here are cozy, warm spots nearby",
    'Focus'    : "Since you need focus, here are quiet cafés and mindful spots",
    'Happy'    : "Since you're feeling happy, here are celebratory spots nearby",
  };

  static const meals = [
    Meal(id: 'm1', title: 'Zen Buddha Bowl',       emoji: '🥗', mood: 'Calm',      tag: 'Vegan',       calories: 420, prepTimeMin: 25, moodTags: ['Calm','Focus'],      dietaryTags: ['vegan','gluten-free'], description: 'A nourishing bowl bringing balance to your plate. Roasted chickpeas, brown rice, massaged kale, avocado and tahini.'),
    Meal(id: 'm2', title: 'Sunrise Smoothie Bowl',  emoji: '🍓', mood: 'Energized', tag: 'Gluten-Free',  calories: 320, prepTimeMin: 10, moodTags: ['Energized','Happy'],  dietaryTags: ['vegan','gluten-free'], description: 'A vibrant açaí base topped with mango, granola, chia and honey. Pure morning energy.'),
    Meal(id: 'm3', title: 'Mindful Ramen',          emoji: '🍜', mood: 'Comfort',   tag: 'Warm',         calories: 580, prepTimeMin: 40, moodTags: ['Comfort','Calm'],     dietaryTags: ['vegetarian'],         description: 'Deep miso broth with tofu, bok choy, soft egg and hand-pulled noodles. Warm your soul.'),
    Meal(id: 'm4', title: 'Serenity Salad',         emoji: '🥙', mood: 'Calm',      tag: 'Raw',          calories: 280, prepTimeMin: 15, moodTags: ['Calm','Focus'],       dietaryTags: ['vegan','raw'],         description: 'Crisp romaine, cucumber, radish and edamame with a ginger-sesame dressing.'),
    Meal(id: 'm5', title: 'Golden Turmeric Oats',   emoji: '🌾', mood: 'Comfort',   tag: 'Anti-Inflam',  calories: 380, prepTimeMin: 5,  moodTags: ['Calm','Comfort'],     dietaryTags: ['vegan','gluten-free'], description: 'Creamy overnight oats with turmeric, cinnamon and almond butter. Anti-inflammatory and warming.'),
    Meal(id: 'm6', title: 'Power Green Smoothie',   emoji: '🥤', mood: 'Energized', tag: 'Raw',          calories: 260, prepTimeMin: 5,  moodTags: ['Energized','Focus'],  dietaryTags: ['vegan','raw'],         description: 'Spinach, banana, spirulina, hemp seeds and coconut water. Pure plant power.'),
    Meal(id: 'm7', title: 'Comfort Lentil Soup',    emoji: '🍲', mood: 'Comfort',   tag: 'Vegan',        calories: 340, prepTimeMin: 40, moodTags: ['Comfort','Calm'],     dietaryTags: ['vegan','gluten-free'], description: 'Red lentils with cumin, coriander, lemon and spinach. Silky, hearty comfort.'),
    Meal(id: 'm8', title: 'Happy Mango Tacos',      emoji: '🌮', mood: 'Happy',     tag: 'Vibrant',      calories: 520, prepTimeMin: 35, moodTags: ['Happy','Energized'],  dietaryTags: ['vegan'],               description: 'Crispy black bean tacos with mango salsa, purple cabbage slaw and chipotle cashew cream.'),
  ];

  static const ingredients = [
    '1 cup brown rice', '1 cup chickpeas (roasted)', '1 avocado, sliced',
    '2 cups kale, massaged', '1 beet, thinly sliced', '2 tbsp tahini',
    '1 lemon, juiced', '1 tsp sesame seeds', 'Pinch of sea salt',
  ];

  static const steps = [
    'Cook brown rice according to package and let cool slightly.',
    'Toss chickpeas in olive oil and roast at 400°F for 25 minutes until crispy.',
    'Massage kale with olive oil and a pinch of sea salt for 2 minutes until softened.',
    'Whisk tahini, lemon juice, 2 tbsp water and garlic powder into a smooth dressing.',
    'Assemble bowl: rice base, then chickpeas, kale, avocado and beet. Drizzle tahini dressing.',
  ];

  static const restaurants = [
    Restaurant(id: 'r1', name: 'The Zen Garden',   cuisine: 'Japanese · Vegan',         emoji: '🍵', rating: 4.8, distanceKm: 0.3, priceRange: 2, address: '42 Serenity Lane, Midtown',          openStatus: 'Open · Closes 10 PM', moodTags: ['Calm','Focus'],            matchesMood: true,  menuHighlights: ['Matcha Buddha Bowl','Tempeh Bento','Ginger Miso Soup','Cold Brew Matcha'],       description: 'A tranquil Japanese-inspired space with plant-based bento boxes, matcha drinks and a bamboo-lined interior.'),
    Restaurant(id: 'r2', name: 'Bloom Kitchen',    cuisine: 'Mediterranean · Healthy',  emoji: '🌸', rating: 4.6, distanceKm: 0.7, priceRange: 2, address: '8 Blossom Street, Garden District',  openStatus: 'Open · Closes 11 PM', moodTags: ['Happy','Energized','Calm'], matchesMood: true,  menuHighlights: ['Quinoa Mezze Platter','Falafel Wrap','Roasted Beet Salad','Pomegranate Spritz'], description: 'A bright, airy Mediterranean kitchen celebrating seasonal vegetables and whole grains.'),
    Restaurant(id: 'r3', name: 'Ember & Soul',     cuisine: 'Farm-to-Table · Comfort',  emoji: '🔥', rating: 4.9, distanceKm: 1.2, priceRange: 3, address: '19 Hearthstone Ave, Old Quarter',   openStatus: 'Open · Closes 11:30 PM', moodTags: ['Comfort','Happy'],       matchesMood: false, menuHighlights: ['Wood-Fire Veggie Roast','Creamy Lentil Soup','Sourdough & Butter','Spiced Cider'], description: 'Rustic farm-to-table comfort food with a wood-fire kitchen. Warm interiors and hearty soups.'),
    Restaurant(id: 'r4', name: 'Aura Café',        cuisine: 'Café · Superfood',         emoji: '✨', rating: 4.5, distanceKm: 0.5, priceRange: 1, address: '3 Mindful Place, Arts District',     openStatus: 'Open · Closes 8 PM',  moodTags: ['Focus','Energized','Calm'], matchesMood: true,  menuHighlights: ['Blue Spirulina Latte','Acai Power Bowl','Avocado Toast','Turmeric Latte'],        description: 'A minimal, light-filled café specialising in superfood lattes, acai bowls and plant-based bites.'),
    Restaurant(id: 'r5', name: 'Roots & Rituals',  cuisine: 'Ayurvedic · Wellness',     emoji: '🌱', rating: 4.7, distanceKm: 1.8, priceRange: 2, address: '77 Balance Road, Wellness Quarter', openStatus: 'Open · Closes 9:30 PM', moodTags: ['Calm','Comfort','Focus'],  matchesMood: true,  menuHighlights: ['Golden Healing Broth','Ashwagandha Smoothie','Dosha Bowl','Herbal Sleep Tea'],    description: 'An Ayurveda-inspired wellness restaurant curating meals around doshas and energy types.'),
  ];

  static List<CommunityPost> posts = [
    CommunityPost(id: 'p1', user: 'Aria Chen',   handle: '@aria_eats',       time: '2h', dish: 'Turmeric Golden Latte', likes: 142, comments: 28, liked: false, saved: false, mood: '✨ Glowing',    avatar: 'AC', postType: PostType.recipe),
    CommunityPost(id: 'p4', user: 'Priya Nair',  handle: '@priya_mindful',   time: '3h', dish: 'The Zen Garden',       likes: 204, comments: 37, liked: false, saved: false, mood: '🌿 Calm',       avatar: 'PN', postType: PostType.dining,  moodBefore: 'Stressed 😓', moodAfter: 'Calm 🌿',   restaurantName: 'The Zen Garden',  note: 'The matcha bowl completely reset my afternoon. So peaceful inside.'),
    CommunityPost(id: 'p2', user: 'Marcus Lee',  handle: '@mindful_marcus',  time: '4h', dish: 'Forest Berry Oats',   likes: 89,  comments: 15, liked: false, saved: true,  mood: '🧘 Centered',   avatar: 'ML', postType: PostType.recipe),
    CommunityPost(id: 'p5', user: 'Jin Park',    handle: '@jin_eats',        time: '5h', dish: 'Ember & Soul',        likes: 317, comments: 52, liked: true,  saved: false, mood: '🤍 Comforted',  avatar: 'JP', postType: PostType.dining,  moodBefore: 'Lonely 💙',   moodAfter: 'Warm 🤍',   restaurantName: 'Ember & Soul',    note: 'Their lentil soup is pure therapy. Felt like home.'),
    CommunityPost(id: 'p3', user: 'Sofia Reyes', handle: '@sofia_cooks',     time: '6h', dish: 'Watermelon Feta Toast', likes: 231, comments: 44, liked: false, saved: false, mood: '🌞 Radiant',  avatar: 'SR', postType: PostType.recipe),
  ];

  static const nutrients = [
    NutrientInfo(label: 'Calories', value: 1840, max: 2000, color: Color(0xFFFF8B6B)),
    NutrientInfo(label: 'Protein',  value: 72,   max: 90,   color: Color(0xFF4FACB8)),
    NutrientInfo(label: 'Carbs',    value: 220,  max: 260,  color: Color(0xFF6DBF9E)),
    NutrientInfo(label: 'Fat',      value: 58,   max: 70,   color: Color(0xFFF7C59F)),
  ];
}
