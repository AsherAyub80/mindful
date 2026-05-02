import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';

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
