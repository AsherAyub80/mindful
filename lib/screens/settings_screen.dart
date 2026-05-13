// lib/screens/settings_screen.dart
// ══════════════════════════════════════════════════════════════
//  MindfulMeals — Settings & Preferences Screen
//  Loads:  GET  /v1/users/me/preferences
//  Saves:  PUT  /v1/users/me/preferences
//  Pushed from ProfileScreen via "Settings & Preferences" row
// ══════════════════════════════════════════════════════════════

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _loading = true;
  bool _saving  = false;
  bool _dirty   = false;   // track unsaved changes

  List<String> _dietary    = [];
  List<String> _allergies  = [];
  List<String> _goals      = [];
  int          _calorieTarget = 2000;
  bool         _notificationsOn = true;

  // Option sets
  static const _dietaryOptions = [
    ('🌱', 'vegan'),
    ('🥚', 'vegetarian'),
    ('🌾', 'gluten-free'),
    ('🪴', 'plant-based'),
    ('🥦', 'raw'),
    ('🥛', 'dairy-free'),
    ('🫒', 'mediterranean'),
    ('☪️', 'halal'),
  ];

  static const _allergyOptions = [
    ('🌰', 'tree-nuts'),
    ('🦐', 'shellfish'),
    ('🥛', 'dairy'),
    ('🌾', 'gluten'),
    ('🥚', 'eggs'),
    ('🫘', 'soy'),
    ('🥜', 'peanuts'),
    ('🌿', 'sesame'),
  ];

  static const _goalOptions = [
    ('⚖️', 'weight-balance'),
    ('🧘', 'mindfulness'),
    ('⚡', 'energy'),
    ('🎯', 'focus'),
    ('😴', 'sleep'),
    ('💆', 'stress-relief'),
    ('🦠', 'gut-health'),
    ('💪', 'muscle-gain'),
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getPreferences();
      final prefs = data['preferences'] as Map<String, dynamic>? ?? {};
      setState(() {
        _dietary    = List<String>.from(prefs['dietary_tags'] ?? []);
        _allergies  = List<String>.from(prefs['allergy_tags'] ?? []);
        _goals      = List<String>.from(prefs['goal_tags']    ?? []);
        _calorieTarget = (prefs['calorie_target'] as int?) ?? 2000;
        _notificationsOn = prefs['notifications_on'] as bool? ?? true;
        _loading    = false;
        _dirty      = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ApiService.updatePreferences({
        'dietary_tags':    _dietary,
        'allergy_tags':    _allergies,
        'goal_tags':       _goals,
        'calorie_target':  _calorieTarget,
        'notifications_on': _notificationsOn,
      });
      setState(() { _saving = false; _dirty = false; });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('✅ Preferences saved!'),
          backgroundColor: AppColors.emerald,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (_) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Could not save — check your connection'),
          backgroundColor: AppColors.coral,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  void _toggleTag(List<String> list, String tag) {
    setState(() {
      if (list.contains(tag)) list.remove(tag);
      else list.add(tag);
      _dirty = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
        const AmbientBlob(alignment: Alignment(-0.8, -0.5), color: AppColors.primary,  size: 200),
        const AmbientBlob(alignment: Alignment(0.8,   0.6), color: AppColors.emerald,  size: 160),
        SafeArea(
          child: _loading ? _buildSkeleton() : _buildContent(),
        ),
      ]),
    );
  }

  // ── Loading skeleton ──────────────────────────────────────────
  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildTopBar(),
        const SizedBox(height: 24),
        ...List.generate(4, (_) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GlassCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SkeletonLoader(width: 140, height: 14, borderRadius: 7),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8,
              children: List.generate(5, (_) => SkeletonLoader(width: 80, height: 32, borderRadius: 10))),
          ])),
        )),
      ]),
    );
  }

  // ── Main content ──────────────────────────────────────────────
  Widget _buildContent() {
    return Column(children: [
      _buildTopBar(),
      Expanded(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(children: [
            _buildSection(
              emoji: '🥗',
              title: 'Dietary Preferences',
              subtitle: "We'll prioritise meals that match your lifestyle",
              options: _dietaryOptions,
              selected: _dietary,
              color: AppColors.emerald,
            ),
            const SizedBox(height: 16),
            _buildSection(
              emoji: '⚠️',
              title: 'Allergies & Intolerances',
              subtitle: 'These will be excluded from all suggestions',
              options: _allergyOptions,
              selected: _allergies,
              color: AppColors.coral,
            ),
            const SizedBox(height: 16),
            _buildSection(
              emoji: '🎯',
              title: 'Wellness Goals',
              subtitle: 'AI uses these to personalise your meal plan',
              options: _goalOptions,
              selected: _goals,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            _buildCalorieRow(),
            const SizedBox(height: 16),
            _buildNotificationRow(),
          ]),
        ),
      ),
      _buildSaveBar(),
    ]);
  }

  // ── Top bar ───────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(children: [
        NeuButton(
          onTap: () => Navigator.pop(context),
          borderRadius: 12, width: 40, height: 40, padding: EdgeInsets.zero,
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text('Settings & Preferences',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        ),
        if (_dirty)
          PillBadge(
            label: 'Unsaved',
            bgColor: AppColors.gold.withOpacity(0.2),
            textColor: AppColors.gold,
          ),
      ]),
    );
  }

  // ── Tag section (dietary / allergy / goals) ───────────────────
  Widget _buildSection({
    required String emoji,
    required String title,
    required String subtitle,
    required List<(String, String)> options,
    required List<String> selected,
    required Color color,

  }) {
    return GlassCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title,
                style: const TextStyle(color: Colors.white,
                    fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: const TextStyle(color: AppColors.white50, fontSize: 11, height: 1.3)),
          ])),
        ]),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: options.map((opt) {
            final isSelected = selected.contains(opt.$2);
            return GestureDetector(
              onTap: () => _toggleTag(selected, opt.$2),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(colors: [color.withOpacity(0.8), color.withOpacity(0.5)])
                      : null,
                  color: isSelected ? null : AppColors.white10,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppColors.white15,
                  ),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(opt.$1, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Text(opt.$2,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.white70,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      )),
                  if (isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                  ],
                ]),
              ),
            );
          }).toList(),
        ),
        if (selected.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${selected.length} selected',
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ]),
    );
  }

  // ── Calorie target row ────────────────────────────────────────
  Widget _buildCalorieRow() {
    return GlassCard(
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Daily Calorie Target',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text('Used to filter and rank meal suggestions',
                style: const TextStyle(color: AppColors.white50, fontSize: 11)),
          ]),
        ),
        const SizedBox(width: 12),
        // Minus
        _CalBtn(
          icon: Icons.remove_rounded,
          onTap: () {
            if (_calorieTarget > 500) {
              setState(() { _calorieTarget -= 50; _dirty = true; });
            }
          },
        ),
        const SizedBox(width: 10),
        Container(
          width: 68,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Text('$_calorieTarget',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 13,
                  fontWeight: FontWeight.w700)),
        ),
        const SizedBox(width: 10),
        // Plus
        _CalBtn(
          icon: Icons.add_rounded,
          onTap: () {
            if (_calorieTarget < 5000) {
              setState(() { _calorieTarget += 50; _dirty = true; });
            }
          },
        ),
      ]),
    );
  }

  // ── Notifications row ─────────────────────────────────────────
  Widget _buildNotificationRow() {
    return GlassCard(
      child: Row(children: [
        const Text('🔔', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Meal Reminders',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            const Text('Daily nudges to log your mood and meals',
                style: TextStyle(color: AppColors.white50, fontSize: 11)),
          ]),
        ),
        GestureDetector(
          onTap: () => setState(() { _notificationsOn = !_notificationsOn; _dirty = true; }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44, height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: _notificationsOn ? AppColors.primary : AppColors.white10,
              border: Border.all(
                  color: _notificationsOn ? AppColors.primary : AppColors.white20),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: _notificationsOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Container(
                  width: 18, height: 18,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x4D000000), blurRadius: 3)],
                  ),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // ── Sticky save bar ───────────────────────────────────────────
  Widget _buildSaveBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xEB080F18),
        border: Border(top: BorderSide(color: AppColors.white15, width: 0.5)),
      ),
      child: NeuButton(
        active: _dirty,
        onTap: (_dirty && !_saving) ? _save : null,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        borderRadius: 16,
        child: _saving
            ? const SizedBox(width: 20, height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(
                _dirty ? 'Save Preferences' : 'All preferences saved ✓',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _dirty ? Colors.white : AppColors.white50,
                  fontSize: 14, fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ── Small +/- button ─────────────────────────────────────────
class _CalBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CalBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          color: AppColors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.white15),
        ),
        child: Icon(icon, color: AppColors.white70, size: 16),
      ),
    );
  }
}
