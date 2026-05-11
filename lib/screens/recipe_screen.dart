// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../theme/app_colors.dart';
// import '../models/app_data.dart';
// import '../widgets/glass_widgets.dart';

// class RecipeScreen extends StatefulWidget {
//   final Function(int) onNavigate;
//   const RecipeScreen({super.key, required this.onNavigate});

//   @override
//   State<RecipeScreen> createState() => _RecipeScreenState();
// }

// class _RecipeScreenState extends State<RecipeScreen>
//     with TickerProviderStateMixin {
//   bool _liked = false;
//   bool _saved = false;
//   int _activeTab = 0;
//   final Set<int> _checkedSteps = {};
//   late TabController _tabController;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _tabController
//         .addListener(() => setState(() => _activeTab = _tabController.index));
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return CustomScrollView(
//       slivers: [
//         _buildHeroAppBar(),
//         SliverToBoxAdapter(
//           child: Padding(
//             padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 12),
//                 _buildTags(),
//                 const SizedBox(height: 8),
//                 _buildTitle(),
//                 const SizedBox(height: 16),
//                 _buildStatsRow(),
//                 const SizedBox(height: 16),
//                 _buildARButton(),
//                 const SizedBox(height: 16),
//                 _buildTabBar(),
//                 const SizedBox(height: 12),
//                 _activeTab == 0 ? _buildIngredients() : _buildSteps(),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildHeroAppBar() {
//     return SliverAppBar(
//       expandedHeight: 200,
//       backgroundColor: Colors.transparent,
//       leading: Padding(
//         padding: const EdgeInsets.all(8),
//         child: NeuButton(
//           onTap: () => widget.onNavigate(0),
//           borderRadius: 20,
//           width: 40,
//           height: 40,
//           padding: EdgeInsets.zero,
//           child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
//         ),
//       ),
//       actions: [
//         Padding(
//           padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
//           child: NeuButton(
//             onTap: () => setState(() => _saved = !_saved),
//             borderRadius: 20,
//             width: 40,
//             height: 40,
//             padding: EdgeInsets.zero,
//             child: Text(_saved ? '🔖' : '📌',
//                 style: const TextStyle(fontSize: 16)),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
//           child: NeuButton(
//             onTap: () => setState(() => _liked = !_liked),
//             borderRadius: 20,
//             width: 40,
//             height: 40,
//             padding: EdgeInsets.zero,
//             child: Text(_liked ? '❤️' : '🤍',
//                 style: const TextStyle(fontSize: 16)),
//           ),
//         ),
//       ],
//       flexibleSpace: FlexibleSpaceBar(
//         background: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//               colors: [Color(0xFF1A5C42), Color(0xFF0F3D56)],
//             ),
//           ),
//           child: Stack(
//             children: [
//               const Center(child: Text('🥗', style: TextStyle(fontSize: 80))),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   height: 80,
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.bottomCenter,
//                       end: Alignment.topCenter,
//                       colors: [Color(0xFF080F18), Colors.transparent],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTags() {
//     return Wrap(
//       spacing: 6,
//       children: ['Vegan', 'Gluten-Free', 'Mood Boost']
//           .map((t) => GlassChip(label: t, color: AppColors.secondary))
//           .toList(),
//     );
//   }

//   Widget _buildTitle() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('Zen Buddha Bowl',
//             style: GoogleFonts.playfairDisplay(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.w700)),
//         const SizedBox(height: 6),
//         const Text(
//           'A nourishing bowl that brings balance and serenity to your plate. Packed with whole grains, roasted vegetables, and a tahini drizzle.',
//           style: TextStyle(color: AppColors.white50, fontSize: 13, height: 1.5),
//         ),
//       ],
//     );
//   }

//   Widget _buildStatsRow() {
//     final stats = [
//       ('⏱', '25 min', 'Time'),
//       ('🔥', '420', 'Cal'),
//       ('💪', '18g', 'Protein'),
//       ('🌾', '52g', 'Carbs'),
//     ];
//     return Row(
//       children: stats
//           .map((s) => Expanded(
//                 child: Padding(
//                   padding: EdgeInsets.only(right: stats.indexOf(s) < 3 ? 8 : 0),
//                   child: GlassCard(
//                     padding: const EdgeInsets.symmetric(vertical: 10),
//                     child: Column(
//                       children: [
//                         Text(s.$1, style: const TextStyle(fontSize: 18)),
//                         const SizedBox(height: 2),
//                         Text(s.$2,
//                             style: const TextStyle(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.w700,
//                                 fontSize: 13)),
//                         Text(s.$3,
//                             style: const TextStyle(
//                                 color: AppColors.white50, fontSize: 10)),
//                       ],
//                     ),
//                   ),
//                 ),
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildARButton() {
//     return NeuButton(
//       onTap: () => Navigator.of(context).pushNamed('/ar'),
//       padding: const EdgeInsets.symmetric(vertical: 14),
//       borderRadius: 16,
//       child: Container(
//         width: double.infinity,
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Color(0x384FACB8), Color(0x293DAA7A)],
//           ),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text('📱', style: TextStyle(fontSize: 18)),
//             const SizedBox(width: 10),
//             const Text('Preview in AR',
//                 style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600)),
//             const SizedBox(width: 10),
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.3),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Text('NEW',
//                   style: TextStyle(
//                       color: AppColors.accent,
//                       fontSize: 10,
//                       fontWeight: FontWeight.w700)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTabBar() {
//     return GlassCard(
//       padding: const EdgeInsets.all(6),
//       borderRadius: 14,
//       child: Row(
//         children: [
//           Expanded(
//               child: _TabBtn(
//                   label: '🥦 Ingredients',
//                   active: _activeTab == 0,
//                   onTap: () {
//                     _tabController.index = 0;
//                     setState(() => _activeTab = 0);
//                   })),
//           const SizedBox(width: 6),
//           Expanded(
//               child: _TabBtn(
//                   label: '📋 Steps',
//                   active: _activeTab == 1,
//                   onTap: () {
//                     _tabController.index = 1;
//                     setState(() => _activeTab = 1);
//                   })),
//         ],
//       ),
//     );
//   }

//   Widget _buildIngredients() {
//     return Column(
//       children: AppData.ingredients
//           .map((ing) => Padding(
//                 padding: const EdgeInsets.only(bottom: 8),
//                 child: GlassCard(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 8,
//                         height: 8,
//                         decoration: const BoxDecoration(
//                             color: AppColors.secondary, shape: BoxShape.circle),
//                       ),
//                       const SizedBox(width: 12),
//                       Text(ing,
//                           style: const TextStyle(
//                               color: Color(0xD9FFFFFF), fontSize: 14)),
//                     ],
//                   ),
//                 ),
//               ))
//           .toList(),
//     );
//   }

//   Widget _buildSteps() {
//     return Column(
//       children: List.generate(AppData.steps.length, (i) {
//         final done = _checkedSteps.contains(i);
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 10),
//           child: GestureDetector(
//             onTap: () => setState(
//                 () => done ? _checkedSteps.remove(i) : _checkedSteps.add(i)),
//             child: AnimatedOpacity(
//               duration: const Duration(milliseconds: 200),
//               opacity: done ? 0.45 : 1.0,
//               child: GlassCard(
//                 padding: const EdgeInsets.all(12),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AnimatedContainer(
//                       duration: const Duration(milliseconds: 200),
//                       width: 24,
//                       height: 24,
//                       decoration: BoxDecoration(
//                         color: done ? AppColors.secondary : AppColors.white10,
//                         shape: BoxShape.circle,
//                         border: Border.all(color: AppColors.white20),
//                       ),
//                       child: Center(
//                         child: done
//                             ? const Icon(Icons.check,
//                                 color: Colors.white, size: 14)
//                             : Text('${i + 1}',
//                                 style: const TextStyle(
//                                     color: AppColors.primary,
//                                     fontSize: 12,
//                                     fontWeight: FontWeight.w700)),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     Expanded(
//                       child: Text(AppData.steps[i],
//                           style: const TextStyle(
//                               color: Color(0xD9FFFFFF),
//                               fontSize: 13,
//                               height: 1.5)),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }

// class _TabBtn extends StatelessWidget {
//   final String label;
//   final bool active;
//   final VoidCallback onTap;

//   const _TabBtn(
//       {required this.label, required this.active, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: const EdgeInsets.symmetric(vertical: 9),
//         decoration: BoxDecoration(
//           gradient: active
//               ? const LinearGradient(
//                   colors: [AppColors.primary, AppColors.deep])
//               : null,
//           color: active ? null : Colors.transparent,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: active
//               ? [const BoxShadow(color: Color(0x664FACB8), blurRadius: 12)]
//               : null,
//         ),
//         child: Text(label,
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               color: active ? Colors.white : AppColors.white50,
//               fontSize: 13,
//               fontWeight: FontWeight.w600,
//             )),
//       ),
//     );
//   }
// }

// lib/screens/recipe_screen.dart
// ══════════════════════════════════════════════════════════════
//  MindfulMeals — Dynamic Recipe Screen
//
//  Data source: GET /v1/meals/:id  (Node.js backend)
//  Falls back gracefully to AppData mock if backend not running.
//  NEVER hardcodes meal content — everything comes from the API.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../models/app_data.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';
import '../providers/meal_provider.dart';

class RecipeScreen extends ConsumerStatefulWidget {
  final Function(int) onNavigate;
  const RecipeScreen({super.key, required this.onNavigate});

  @override
  ConsumerState<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends ConsumerState<RecipeScreen>
    with TickerProviderStateMixin {
  // ── UI state ──────────────────────────────────────────────────
  bool _liked = false;
  bool _saved = false;
  int _activeTab = 0;
  final Set<int> _checkedSteps = {};
  late TabController _tabController;

  // ── Data state ────────────────────────────────────────────────
  bool _loading = true;
  bool _usedMock = false;
  Map<String, dynamic>? _meal;

  // Normalised lists — same shape regardless of API vs mock
  List<Map<String, dynamic>> _ingredientItems = [];
  List<Map<String, dynamic>> _stepItems = [];

  // ── Lifecycle ─────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _activeTab = _tabController.index);
    });
    // Fetch after first frame so ref is ready
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMeal());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Data loading ──────────────────────────────────────────────
  Future<void> _loadMeal() async {
    final mealId = ref.read(selectedMealIdProvider);

    if (mealId == null || mealId.isEmpty) {
      _applyMock();
      return;
    }

    setState(() => _loading = true);
    try {
      final data = await ApiService.getMealDetail(mealId);
      final meal = data['meal'] as Map<String, dynamic>?;
      if (meal == null) throw Exception('Empty response');
      _applyApiData(meal);
    } catch (_) {
      _applyMock();
    }
  }

  void _applyApiData(Map<String, dynamic> meal) {
    // Ingredients sorted by sort_order
    final rawIng = List<Map<String, dynamic>>.from(
      (meal['meal_ingredients'] as List? ?? [])
          .map((i) => Map<String, dynamic>.from(i as Map)),
    );
    rawIng.sort((a, b) =>
        ((a['sort_order'] as int?) ?? 0)
            .compareTo((b['sort_order'] as int?) ?? 0));

    final ingredients = rawIng.map((i) {
      final qty  = (i['quantity'] as String? ?? '').trim();
      final name = (i['name']     as String? ?? '').trim();
      return {
        'display': qty.isNotEmpty ? '$qty  $name' : name,
        'sort_order': i['sort_order'] ?? 0,
      };
    }).toList();

    // Steps sorted by step_number
    final rawSteps = List<Map<String, dynamic>>.from(
      (meal['meal_steps'] as List? ?? [])
          .map((s) => Map<String, dynamic>.from(s as Map)),
    );
    rawSteps.sort((a, b) =>
        ((a['step_number'] as int?) ?? 0)
            .compareTo((b['step_number'] as int?) ?? 0));

    final steps = rawSteps.map((s) => {
          'number':      (s['step_number']  as int?)    ?? 0,
          'instruction': (s['instruction']  as String?) ?? '',
        }).toList();

    setState(() {
      _meal           = meal;
      _ingredientItems = ingredients;
      _stepItems       = steps;
      _loading         = false;
      _usedMock        = false;
    });
  }

  void _applyMock() {
    final ingredients = AppData.ingredients.asMap().entries.map((e) {
      return {'display': e.value, 'sort_order': e.key};
    }).toList();

    final steps = AppData.steps.asMap().entries.map((e) => {
          'number':      e.key + 1,
          'instruction': e.value,
        }).toList();

    setState(() {
      _meal            = null;
      _ingredientItems = ingredients;
      _stepItems       = steps;
      _loading         = false;
      _usedMock        = true;
    });
  }

  // ── Convenience getters ───────────────────────────────────────
  String get _title =>
      (_meal?['title'] as String?) ?? 'Zen Buddha Bowl';

  String get _emoji =>
      (_meal?['emoji'] as String?) ?? '🥗';

  String get _description =>
      (_meal?['description'] as String?) ??
      'A nourishing bowl that brings balance and serenity to your plate. '
          'Packed with whole grains, roasted vegetables, and a tahini drizzle.';

  String? get _imageUrl => _meal?['image_url'] as String?;

  int?    get _calories => _meal?['calories']     as int?;
  int?    get _prepTime => _meal?['prep_time_min'] as int?;
  double? get _protein  => (_meal?['protein_g']   as num?)?.toDouble();
  double? get _carbs    => (_meal?['carbs_g']      as num?)?.toDouble();

  List<String> get _moodTags =>
      List<String>.from(_meal?['mood_tags']    as List? ?? []);
  List<String> get _dietaryTags =>
      List<String>.from(_meal?['dietary_tags'] as List? ?? []);

  String _formatStat(num? v, String unit) =>
      v != null ? '${v % 1 == 0 ? v.toInt() : v}$unit' : '—';

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
                color: AppColors.primary, strokeWidth: 2),
            SizedBox(height: 16),
            Text('Loading recipe…',
                style: TextStyle(color: AppColors.white50, fontSize: 13)),
          ],
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        _buildHeroAppBar(),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                if (_usedMock)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassChip(
                        label: 'Demo data — connect backend for live recipes',
                        color: AppColors.gold),
                  ),
                _buildTagsRow(),
                const SizedBox(height: 8),
                _buildTitleSection(),
                const SizedBox(height: 16),
                _buildNutritionRow(),
                const SizedBox(height: 16),
                _buildARButton(),
                const SizedBox(height: 16),
                _buildTabBar(),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: _activeTab == 0
                      ? _buildIngredients()
                      : _buildSteps(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Hero app bar ──────────────────────────────────────────────
  Widget _buildHeroAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: NeuButton(
          onTap: () => widget.onNavigate(0),
          borderRadius: 20, width: 40, height: 40, padding: EdgeInsets.zero,
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
          child: NeuButton(
            onTap: () => setState(() => _saved = !_saved),
            borderRadius: 20, width: 40, height: 40, padding: EdgeInsets.zero,
            child: Text(_saved ? '🔖' : '📌',
                style: const TextStyle(fontSize: 16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: NeuButton(
            onTap: () => setState(() => _liked = !_liked),
            borderRadius: 20, width: 40, height: 40, padding: EdgeInsets.zero,
            child: Text(_liked ? '❤️' : '🤍',
                style: const TextStyle(fontSize: 16)),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroBackground(),
      ),
    );
  }

  Widget _buildHeroBackground() {
    Widget emojiPlaceholder() => Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A5C42), Color(0xFF0F3D56)],
        ),
      ),
      child: Stack(children: [
        Center(child: Text(_emoji, style: const TextStyle(fontSize: 80))),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFF080F18), Colors.transparent],
              ),
            ),
          ),
        ),
      ]),
    );

    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Stack(children: [
        Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (_, __, ___) => emojiPlaceholder(),
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: Container(
            height: 80,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFF080F18), Colors.transparent],
              ),
            ),
          ),
        ),
      ]);
    }

    return emojiPlaceholder();
  }

  // ── Tags row (mood + dietary) ─────────────────────────────────
  Widget _buildTagsRow() {
    final all = [..._moodTags, ..._dietaryTags];
    if (all.isEmpty) {
      return Wrap(
        spacing: 6,
        children: ['Vegan', 'Gluten-Free', 'Mood Boost']
            .map((t) => GlassChip(label: t, color: AppColors.secondary))
            .toList(),
      );
    }
    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        ..._moodTags.map(
            (t) => GlassChip(label: '🧘 $t', color: AppColors.primary)),
        ..._dietaryTags.map(
            (t) => GlassChip(label: t, color: AppColors.secondary)),
      ],
    );
  }

  // ── Title + description ───────────────────────────────────────
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: GoogleFonts.playfairDisplay(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Text(
          _description,
          style: const TextStyle(
              color: AppColors.white50, fontSize: 13, height: 1.5),
        ),
      ],
    );
  }

  // ── Nutrition stats row ───────────────────────────────────────
  Widget _buildNutritionRow() {
    final stats = [
      ('⏱', _prepTime != null ? '$_prepTime min' : '—', 'Time'),
      ('🔥', _formatStat(_calories, ''), 'Cal'),
      ('💪', _formatStat(_protein, 'g'), 'Protein'),
      ('🌾', _formatStat(_carbs, 'g'), 'Carbs'),
    ];

    return Row(
      children: stats.asMap().entries.map((e) {
        final i = e.key;
        final s = e.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(s.$1, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(s.$2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13)),
                  Text(s.$3,
                      style: const TextStyle(
                          color: AppColors.white50, fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── AR preview button ─────────────────────────────────────────
  Widget _buildARButton() {
    return NeuButton(
      onTap: () => widget.onNavigate(2),
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: 16,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x384FACB8), Color(0x293DAA7A)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📱', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            const Text('Preview in AR',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('NEW',
                  style: TextStyle(
                      color: AppColors.accent,
                      fontSize: 10,
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────
  Widget _buildTabBar() {
    return GlassCard(
      padding: const EdgeInsets.all(6),
      borderRadius: 14,
      child: Row(
        children: [
          Expanded(
            child: _TabBtn(
              label: '🥦 Ingredients (${_ingredientItems.length})',
              active: _activeTab == 0,
              onTap: () {
                _tabController.index = 0;
                setState(() => _activeTab = 0);
              },
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TabBtn(
              label: '📋 Steps (${_stepItems.length})',
              active: _activeTab == 1,
              onTap: () {
                _tabController.index = 1;
                setState(() => _activeTab = 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Ingredients list ──────────────────────────────────────────
  Widget _buildIngredients() {
    if (_ingredientItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No ingredients listed',
              style: TextStyle(color: AppColors.white50)),
        ),
      );
    }

    return Column(
      key: const ValueKey('ingredients'),
      children: _ingredientItems
          .map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: AppColors.secondary,
                            shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          ing['display'] as String,
                          style: const TextStyle(
                              color: Color(0xD9FFFFFF), fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }

  // ── Steps list ────────────────────────────────────────────────
  Widget _buildSteps() {
    if (_stepItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('No steps listed',
              style: TextStyle(color: AppColors.white50)),
        ),
      );
    }

    return Column(
      key: const ValueKey('steps'),
      children: _stepItems.asMap().entries.map((entry) {
        final i    = entry.key;
        final step = entry.value;
        final done = _checkedSteps.contains(i);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => setState(() =>
                done ? _checkedSteps.remove(i) : _checkedSteps.add(i)),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: done ? 0.45 : 1.0,
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: done
                            ? AppColors.secondary
                            : AppColors.white10,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.white20),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : Text(
                                '${step['number']}',
                                style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step['instruction'] as String,
                        style: const TextStyle(
                            color: Color(0xD9FFFFFF),
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Tab button widget ─────────────────────────────────────────
class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabBtn(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(
                  colors: [AppColors.primary, AppColors.deep])
              : null,
          color: active ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: active
              ? [const BoxShadow(
                  color: Color(0x664FACB8), blurRadius: 12)]
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: active ? Colors.white : AppColors.white50,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
