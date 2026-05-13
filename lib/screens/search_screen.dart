// lib/screens/search_screen.dart
// ══════════════════════════════════════════════════════════════
//  MindfulMeals — Smart Meal Search Screen
//  Calls POST /v1/meals/search (smartMealSearch on backend)
//  Debounced 500ms · Shows AI-extracted filters as chips
//  Tap a meal → set selectedMealIdProvider → push RecipeScreen
// ══════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/app_data.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';
import '../providers/meal_provider.dart';
import 'recipe_screen.dart';
import 'ar_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode  = FocusNode();
  Timer? _debounce;

  List<Meal>         _results  = [];
  Map<String, dynamic> _filters = {};
  bool   _loading     = false;
  bool   _hasSearched = false;
  String _lastQuery   = '';

  // Suggestion chips shown before any search
  static const _suggestions = [
    ('🌿', 'Calm & light'),
    ('⚡', 'Energy boost'),
    ('🤍', 'Comfort food'),
    ('🎯', 'Focus meal'),
    ('🌱', 'Vegan'),
    ('⏱️', 'Under 15 min'),
    ('🍲', 'Soup'),
    ('🥗', 'Salad'),
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() { _results = []; _filters = {}; _hasSearched = false; _loading = false; });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(query.trim()));
  }

  Future<void> _search(String query) async {
    if (query == _lastQuery && _hasSearched) return;
    _lastQuery = query;
    try {
      final data = await ApiService.searchMeals(query);
      final rawMeals = data['meals'] as List? ?? [];
      setState(() {
        _results    = rawMeals.map((m) => Meal.fromJson(m as Map<String, dynamic>)).toList();
        _filters    = (data['filters'] as Map<String, dynamic>?) ?? {};
        _loading    = false;
        _hasSearched = true;
      });
    } catch (_) {
      // Fallback: filter local mock data by query
      final q = query.toLowerCase();
      setState(() {
        _results = AppData.meals
            .where((m) =>
                m.title.toLowerCase().contains(q) ||
                m.description.toLowerCase().contains(q) ||
                m.moodTags.any((t) => t.toLowerCase().contains(q)) ||
                m.dietaryTags.any((t) => t.toLowerCase().contains(q)))
            .toList();
        _filters    = {};
        _loading    = false;
        _hasSearched = true;
      });
    }
  }

  void _openRecipe(Meal meal) {
    ref.read(selectedMealIdProvider.notifier).state = meal.id;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeScreen(
          onNavigate: (int i) {
            if (i == 2) {
              Navigator.push(context, MaterialPageRoute(
                builder: (_) => ARScreen(onNavigate: (_) => Navigator.pop(context)),
              ));
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }

  void _fillSuggestion(String text) {
    _controller.text = text;
    _controller.selection = TextSelection.fromPosition(
      TextPosition(offset: text.length),
    );
    _onQueryChanged(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
        const AmbientBlob(alignment: Alignment(-0.9, -0.6), color: AppColors.primary, size: 220),
        const AmbientBlob(alignment: Alignment(0.8, 0.7),  color: AppColors.emerald, size: 180),
        SafeArea(
          child: Column(children: [
            _buildSearchBar(),
            if (_filters.isNotEmpty) _buildFilterChips(),
            Expanded(child: _buildContent()),
          ]),
        ),
      ]),
    );
  }

  // ── Search bar ───────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        // Back button
        NeuButton(
          onTap: () => Navigator.pop(context),
          borderRadius: 12, width: 40, height: 40, padding: EdgeInsets.zero,
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        // Search field
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            borderRadius: 14,
            child: Row(children: [
              const Icon(Icons.search_rounded, color: AppColors.white50, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode:  _focusNode,
                  onChanged:  _onQueryChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (q) { if (q.trim().isNotEmpty) _search(q.trim()); },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Search meals, moods, ingredients…',
                    hintStyle: TextStyle(color: AppColors.white50, fontSize: 14),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    _onQueryChanged('');
                    _focusNode.requestFocus();
                  },
                  child: const Icon(Icons.close_rounded, color: AppColors.white50, size: 16),
                ),
            ]),
          ),
        ),
      ]),
    );
  }

  // ── AI-extracted filter chips ─────────────────────────────────
  Widget _buildFilterChips() {
    final chips = <String>[];
    if (_filters['mood'] != null) chips.add('😌 ${_filters['mood']}');
    if (_filters['maxCalories'] != null) chips.add('🔥 < ${_filters['maxCalories']} cal');
    final dietary = (_filters['dietary'] as List?)?.cast<String>() ?? [];
    chips.addAll(dietary.map((d) => '🌱 $d'));

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('AI detected filters',
            style: TextStyle(color: AppColors.white50, fontSize: 11, letterSpacing: 0.5)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: chips.map((c) => GlassChip(label: c, color: AppColors.primary)).toList(),
        ),
      ]),
    );
  }

  // ── Main content area ─────────────────────────────────────────
  Widget _buildContent() {
    if (_loading) return _buildSkeletons();
    if (!_hasSearched) return _buildSuggestions();
    if (_results.isEmpty) return _buildEmpty();
    return _buildResults();
  }

  // ── Suggestions (pre-search) ──────────────────────────────────
  Widget _buildSuggestions() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Try searching for…',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: _suggestions.map((s) => GestureDetector(
            onTap: () => _fillSuggestion(s.$2),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(s.$1, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(s.$2, style: const TextStyle(color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w500)),
              ]),
            ),
          )).toList(),
        ),
        const SizedBox(height: 32),
        const Text('POPULAR MEALS',
            style: TextStyle(color: AppColors.white50, fontSize: 11,
                letterSpacing: 1, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        ...AppData.meals.take(3).map((m) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _MealResultCard(meal: m, onTap: () => _openRecipe(m)),
        )),
      ]),
    );
  }

  // ── Skeleton loaders ──────────────────────────────────────────
  Widget _buildSkeletons() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => GlassCard(
        child: Row(children: [
          const SkeletonLoader(width: 52, height: 52, borderRadius: 14),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SkeletonLoader(width: 180, height: 14, borderRadius: 7),
            const SizedBox(height: 6),
            SkeletonLoader(width: 110, height: 11, borderRadius: 5),
          ])),
        ]),
      ),
    );
  }

  // ── No results ────────────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('🔍', style: TextStyle(fontSize: 52)),
          const SizedBox(height: 16),
          Text('No meals found',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Try searching for a mood, ingredient\nor cuisine style',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.white50, fontSize: 13, height: 1.5)),
          const SizedBox(height: 24),
          NeuButton(
            active: true,
            onTap: () { _controller.clear(); _onQueryChanged(''); _focusNode.requestFocus(); },
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: const Text('Clear search',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ]),
      ),
    );
  }

  // ── Results list ──────────────────────────────────────────────
  Widget _buildResults() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${_results.length} meal${_results.length == 1 ? '' : 's'} found',
              style: const TextStyle(color: AppColors.white50, fontSize: 12)),
          PillBadge(
            label: '✨ AI-ranked',
            bgColor: AppColors.primary.withOpacity(0.2),
            textColor: AppColors.accent,
          ),
        ]),
      ),
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _results.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _MealResultCard(
            meal: _results[i],
            onTap: () => _openRecipe(_results[i]),
          ),
        ),
      ),
    ]);
  }
}

// ── Meal result card ──────────────────────────────────────────
class _MealResultCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback onTap;
  const _MealResultCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = meal.moodTags.isNotEmpty ? AppColors.secondary : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Row(children: [
          Container(
            width: 56, height: 56,
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Text(meal.emoji, style: const TextStyle(fontSize: 26))),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (meal.dietaryTags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: GlassChip(label: meal.dietaryTags.first, color: color),
                  ),
                Text(meal.title,
                    style: const TextStyle(color: Colors.white, fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Row(children: [
                  if (meal.prepTimeMin != null)
                    Text('⏱ ${meal.prepTimeMin} min',
                        style: const TextStyle(color: AppColors.white50, fontSize: 11)),
                  if (meal.prepTimeMin != null && meal.calories != null)
                    const Text(' · ', style: TextStyle(color: AppColors.white50, fontSize: 11)),
                  if (meal.calories != null)
                    Text('🔥 ${meal.calories} kcal',
                        style: const TextStyle(color: AppColors.white50, fontSize: 11)),
                ]),
                if (meal.moodTags.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    children: meal.moodTags.take(2).map((t) =>
                      GlassChip(label: t, color: AppColors.primary)).toList(),
                  ),
                ],
              ]),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(Icons.chevron_right, color: AppColors.white20, size: 20),
          ),
        ]),
      ),
    );
  }
}
