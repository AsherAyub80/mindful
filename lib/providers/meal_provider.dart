// lib/providers/meal_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Holds the ID of the meal the user tapped on HomeScreen.
/// HomeScreen sets this before calling onNavigate(1).
/// RecipeScreen reads it on init to know which meal to fetch.
final selectedMealIdProvider = StateProvider<String?>((ref) => null);
