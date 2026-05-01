import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../models/app_data.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';
import 'restaurant/restaurant_suggestions_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Function(int) onNavigate;
  const HomeScreen({super.key, required this.onNavigate});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _moodCtrl;
  late Animation<double> _moodFade;
  List<Meal> _meals = [];
  bool _mealsLoading = false;
  Map<String, dynamic>? _aiIntent;

  @override
  void initState() {
    super.initState();
    _moodCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _moodFade = CurvedAnimation(parent: _moodCtrl, curve: Curves.easeIn);
    _moodCtrl.forward();
    _loadMeals();
  }

  @override
  void dispose() { _moodCtrl.dispose(); super.dispose(); }

  Future<void> _loadMeals() async {
    final mood = ref.read(moodProvider).mood;
    setState(() => _mealsLoading = true);
    try {
      final data = await ApiService.getAiMeals(mood);
      final recs = data['recommendations'] as List? ?? [];
      setState(() { _meals = recs.map((m) => Meal.fromJson(m)).toList(); _aiIntent = data['intent']; });
    } catch (_) {
      // Use mock data if backend not running
      setState(() => _meals = AppData.meals.where((m) => m.mood == mood).toList());
    } finally {
      setState(() => _mealsLoading = false);
    }
  }

  Future<void> _selectMood(int i) async {
    _moodCtrl.reverse().then((_) async {
      await ref.read(moodProvider.notifier).selectMood(AppData.moodLabels[i], i);
      _moodCtrl.forward();
      await _loadMeals();
    });
  }

  String get _greeting {
    final h = DateTime.now().hour;
    return h < 12 ? 'Good Morning' : h < 17 ? 'Good Afternoon' : 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final moodState = ref.watch(moodProvider);
    final user = ref.watch(authProvider).user;
    final intent = _aiIntent ?? moodState.intent;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 16),
        // Header
        Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_greeting, style: const TextStyle(color: AppColors.white50, fontSize: 13)),
            const SizedBox(height: 2),
            Text(user != null ? 'Hello, ${user.name.split(' ')[0]}! 🌿' : 'How are you feeling?',
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
          ])),
          Stack(children: [
            GlassCard(padding: const EdgeInsets.all(10), borderRadius: 22,
                child: const Text('🧘', style: TextStyle(fontSize: 20))),
            Positioned(top: 0, right: 0,
              child: Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgDark, width: 2)))),
          ]),
        ]),
        const SizedBox(height: 20),

        // AI insight banner — shows real data from backend if available
        GlassCard(
          gradient: const LinearGradient(colors: [Color(0x384FACB8), Color(0x293DAA7A)]),
          backgroundColor: Colors.transparent,
          child: Row(children: [
            const Text('🤖', style: TextStyle(fontSize: 26)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                child: const Text('AI INSIGHT', style: TextStyle(color: AppColors.accent, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1)),
              ),
              const SizedBox(height: 4),
              FadeTransition(opacity: _moodFade,
                child: Text(
                  intent != null
                      ? intent['intent'] as String? ?? "Nourishing meals selected for your ${moodState.mood} state."
                      : "You're feeling ${moodState.mood.toLowerCase()}. Choose how you'd like to nourish yourself today.",
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.45),
                )),
            ])),
          ]),
        ),
        const SizedBox(height: 20),

        // Mood selector
        const Text("TODAY'S MOOD", style: TextStyle(color: AppColors.white50, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        SizedBox(height: 42, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: AppData.moodLabels.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final active = moodState.moodIndex == i;
            return NeuButton(
              active: active, onTap: () => _selectMood(i),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text(AppData.moodEmojis[i], style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(AppData.moodLabels[i], style: TextStyle(fontSize: 13,
                    color: active ? Colors.white : AppColors.white70,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400)),
              ]),
            );
          },
        )),
        const SizedBox(height: 20),

        // Cook / Go Out choice cards
        const Text("WHAT'S YOUR PLAN?", style: TextStyle(color: AppColors.white50, fontSize: 11, letterSpacing: 1, fontWeight: FontWeight.w500)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _ChoiceCard(
            emoji: '🍳', title: 'Cook at Home', subtitle: 'Mindful recipes for your mood',
            color: AppColors.emerald, onTap: () => widget.onNavigate(1),
          )),
          const SizedBox(width: 12),
          Expanded(child: _ChoiceCard(
            emoji: '🍽️', title: 'Go Out', subtitle: 'Restaurants matching your vibe',
            color: AppColors.primary, badge: 'Near You',
            onTap: () => _showMealChoiceModal(context, moodState),
          )),
        ]),
        const SizedBox(height: 24),

        // Meal suggestions
        SectionHeader(title: 'Suggested for You', action: 'See all →'),
        const SizedBox(height: 14),
        if (_mealsLoading)
          Column(children: List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassCard(child: Row(children: [
              const SkeletonLoader(width: 56, height: 56, borderRadius: 16),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SkeletonLoader(width: 140, height: 14, borderRadius: 7),
                const SizedBox(height: 6),
                SkeletonLoader(width: 100, height: 11, borderRadius: 5),
              ]),
            ])),
          )))
        else
          ..._meals.isEmpty
              ? [const Center(child: Text('No meals found for this mood', style: TextStyle(color: AppColors.white50)))]
              : _meals.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MealCard(meal: m, onTap: () => widget.onNavigate(1)),
                )),
        const SizedBox(height: 20),

        // Streak banner
        GlassCard(
          gradient: const LinearGradient(colors: [Color(0x2EF7C59F), Color(0x21FF8B6B)]),
          backgroundColor: Colors.transparent,
          child: Row(children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${ref.watch(authProvider).user?.streakCount ?? 0}-Day Streak!',
                  style: const TextStyle(color: AppColors.gold, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              const Text("You're building incredible habits!", style: TextStyle(color: AppColors.white50, fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    );
  }

  void _showMealChoiceModal(BuildContext context, MoodState moodState) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              decoration: BoxDecoration(color: const Color(0xE6080F18), borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.white15)),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.white20, borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 18),
                Text('How would you like to eat?', style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text("You're feeling ${moodState.mood.toLowerCase()} today", style: const TextStyle(color: AppColors.white50, fontSize: 13)),
                const SizedBox(height: 24),
                Row(children: [
                  Expanded(child: _ModalOption(emoji: '🍳', title: 'Cook at Home', subtitle: 'Mindful recipes tailored to your mood', color: AppColors.emerald, onTap: () { Navigator.pop(context); widget.onNavigate(1); })),
                  const SizedBox(width: 12),
                  Expanded(child: _ModalOption(emoji: '🍽️', title: 'Go Out', subtitle: 'Restaurants matching your vibe nearby', color: AppColors.primary, highlighted: true,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => RestaurantSuggestionsScreen(mood: moodState.mood, moodEmoji: AppData.moodEmojis[moodState.moodIndex])));
                    },
                  )),
                ]),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Maybe later', style: TextStyle(color: AppColors.white50))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────

class _ChoiceCard extends StatefulWidget {
  final String emoji, title, subtitle; final Color color;
  final VoidCallback onTap; final String? badge;
  const _ChoiceCard({required this.emoji, required this.title, required this.subtitle, required this.color, required this.onTap, this.badge});
  @override State<_ChoiceCard> createState() => _ChoiceCardState();
}

class _ChoiceCardState extends State<_ChoiceCard> with SingleTickerProviderStateMixin {
  late AnimationController _c; late Animation<double> _s;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); _s = Tween<double>(begin: 1.0, end: 0.97).animate(_c); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(), onTapUp: (_) { _c.reverse(); widget.onTap(); }, onTapCancel: () => _c.reverse(),
      child: ScaleTransition(scale: _s,
        child: ClipRRect(borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: widget.color.withOpacity(0.15),
                border: Border.all(color: widget.color.withOpacity(0.35)),
                boxShadow: [BoxShadow(color: widget.color.withOpacity(0.12), blurRadius: 20)],
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(widget.emoji, style: const TextStyle(fontSize: 28)),
                  if (widget.badge != null) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(color: widget.color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: Text(widget.badge!, style: TextStyle(color: widget.color, fontSize: 9, fontWeight: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(widget.subtitle, style: const TextStyle(color: AppColors.white50, fontSize: 11)),
                const SizedBox(height: 10),
                Row(children: [const Spacer(), Icon(Icons.arrow_forward_rounded, color: AppColors.primary, size: 16)]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final Meal meal; final VoidCallback onTap;
  const _MealCard({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = meal.moodTags.isNotEmpty ? const Color(0xFF3DAA7A) : AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(borderRadius: BorderRadius.circular(16),
        child: Stack(children: [
          GlassCard(padding: EdgeInsets.zero,
            child: Row(children: [
              Container(width: 56, height: 56, margin: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(meal.emoji, style: const TextStyle(fontSize: 26)))),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if (meal.tag != null) GlassChip(label: meal.tag!, color: color),
                const SizedBox(height: 4),
                Text(meal.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('${meal.prepTimeMin ?? '?'} min · ${meal.calories ?? '?'} kcal',
                    style: const TextStyle(color: AppColors.white50, fontSize: 12)),
                if (meal.moodAlignment != null) ...[
                  const SizedBox(height: 3),
                  Text(meal.moodAlignment!, style: const TextStyle(color: AppColors.mint, fontSize: 11, fontStyle: FontStyle.italic), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
              ])),
              const Padding(padding: EdgeInsets.all(14), child: Icon(Icons.chevron_right, color: AppColors.white20)),
            ]),
          ),
          Positioned(top: 0, right: 0, bottom: 0,
            child: Container(width: 80, decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.centerRight, end: Alignment.centerLeft,
                  colors: [color.withOpacity(0.1), Colors.transparent])))),
        ]),
      ),
    );
  }
}

class _ModalOption extends StatefulWidget {
  final String emoji, title, subtitle; final Color color;
  final VoidCallback onTap; final bool highlighted;
  const _ModalOption({required this.emoji, required this.title, required this.subtitle, required this.color, required this.onTap, this.highlighted = false});
  @override State<_ModalOption> createState() => _ModalOptionState();
}
class _ModalOptionState extends State<_ModalOption> with SingleTickerProviderStateMixin {
  late AnimationController _c; late Animation<double> _s;
  @override void initState() { super.initState(); _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100)); _s = Tween<double>(begin: 1.0, end: 0.96).animate(_c); }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _c.forward(), onTapUp: (_) { _c.reverse(); widget.onTap(); }, onTapCancel: () => _c.reverse(),
      child: ScaleTransition(scale: _s,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: widget.highlighted ? LinearGradient(colors: [widget.color.withOpacity(0.3), widget.color.withOpacity(0.15)]) : null,
            color: widget.highlighted ? null : AppColors.white10,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.highlighted ? widget.color.withOpacity(0.5) : AppColors.white15, width: widget.highlighted ? 1.5 : 1),
            boxShadow: widget.highlighted ? [BoxShadow(color: widget.color.withOpacity(0.2), blurRadius: 20)] : null,
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.emoji, style: const TextStyle(fontSize: 30)),
            const SizedBox(height: 10),
            Text(widget.title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(widget.subtitle, style: const TextStyle(color: AppColors.white50, fontSize: 11, height: 1.4)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: widget.color.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Text("Let's go", style: TextStyle(color: widget.color, fontSize: 10, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: widget.color, size: 12),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
