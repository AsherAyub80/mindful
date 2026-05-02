import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindful_meals/services/api_service.dart';
import '../theme/app_colors.dart';
import '../models/app_data.dart';
import '../widgets/glass_widgets.dart';
import '../providers/auth_provider.dart';

// ProfileScreen uses ConsumerStatefulWidget so it can:
//   • read the logged-in user name/handle/streak from authProvider
//   • call authProvider.notifier.logout() from the Sign Out button
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _notifs = true;
  late AnimationController _barController;
  late List<Animation<double>> _barAnims;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _barAnims = AppData.nutrients
        .map((n) => Tween<double>(begin: 0, end: n.value / n.max).animate(
              CurvedAnimation(
                  parent: _barController, curve: Curves.easeOutCubic),
            ))
        .toList();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Live user from backend; falls back to demo values if not connected
    final user = ref.watch(authProvider).user;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        children: [
          _buildProfileHeader(user),
          const SizedBox(height: 20),
          _buildStatsGrid(user),
          const SizedBox(height: 20),
          _buildNutritionCard(),
          const SizedBox(height: 20),
          _buildPreferences(),
          const SizedBox(height: 20),
          _buildSignOutButton(),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildProfileHeader(UserProfile? user) {
    final name = user?.name ?? 'Alex Rivers';
    final handle = user?.handle ?? 'alex_mindful';

    return GlassCard(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0x2E4FACB8), Color(0x213DAA7A)],
      ),
      backgroundColor: Colors.transparent,
      child: Column(
        children: [
          // Avatar — show network image if available, else emoji
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.emeraldGradient,
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.35), blurRadius: 24)
              ],
            ),
            child: user?.avatarUrl != null
                ? ClipOval(
                    child: Image.network(user!.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                            child: Text('🧘', style: TextStyle(fontSize: 30)))))
                : const Center(
                    child: Text('🧘', style: TextStyle(fontSize: 30))),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('@$handle · Member',
              style: const TextStyle(color: AppColors.white50, fontSize: 13)),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              GlassChip(label: '🌱 Plant-Based', color: AppColors.secondary),
              GlassChip(label: '💧 Hydration Pro', color: AppColors.accent),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats grid — streak comes from live user data ────────────
  Widget _buildStatsGrid(UserProfile? user) {
    final streak = user?.streakCount ?? 0;
    final stats = [
      ('🥗', '47', 'Recipes'),
      ('🔥', '$streak', 'Streak'),
      ('⭐', '4.8', 'Rating'),
      ('👥', '128', 'Follow'),
    ];
    return Row(
      children: List.generate(stats.length, (i) {
        final s = stats[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 3 ? 8 : 0),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  Text(s.$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(s.$2,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  Text(s.$3,
                      style: const TextStyle(
                          color: AppColors.white50, fontSize: 10)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ── Nutrition bars (animated) ────────────────────────────────
  Widget _buildNutritionCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Today's Nutrition",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15)),
          const SizedBox(height: 14),
          ...List.generate(AppData.nutrients.length, (i) {
            final n = AppData.nutrients[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(n.label,
                          style: const TextStyle(
                              color: AppColors.white70, fontSize: 12)),
                      Text('${n.value} / ${n.max}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: Container(
                      height: 6,
                      color: AppColors.white10,
                      child: AnimatedBuilder(
                        animation: _barAnims[i],
                        builder: (_, __) => FractionallySizedBox(
                          widthFactor: _barAnims[i].value,
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [n.color, n.color.withOpacity(0.6)]),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Preferences ──────────────────────────────────────────────
  Widget _buildPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('PREFERENCES',
            style: TextStyle(
                color: AppColors.white50,
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 10),
        _PrefRow(
            icon: '🥗', label: 'Dietary', value: 'Plant-Based, Gluten-Free'),
        _PrefRow(icon: '⚠️', label: 'Allergies', value: 'Tree Nuts, Shellfish'),
        _PrefRow(
            icon: '🎯', label: 'Goals', value: 'Weight Balance, Mindfulness'),
        _PrefRow(
          icon: '🔔',
          label: 'Notifications',
          value: _notifs ? 'Enabled' : 'Disabled',
          trailing: GestureDetector(
            onTap: () => setState(() => _notifs = !_notifs),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 24,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: _notifs ? AppColors.primary : AppColors.white10,
                border: Border.all(
                    color: _notifs ? AppColors.primary : AppColors.white20),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment:
                    _notifs ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Color(0x4D000000), blurRadius: 3)
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Sign Out ─────────────────────────────────────────────────
  Widget _buildSignOutButton() {
    final isLoading = ref.watch(authProvider).isLoading;
    return NeuButton(
      onTap: isLoading
          ? null
          : () async {
              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF0F2A35),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  title: const Text('Sign Out',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                  content: const Text('Are you sure you want to sign out?',
                      style: TextStyle(color: AppColors.white70)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel',
                          style: TextStyle(color: AppColors.white50)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Sign Out',
                          style: TextStyle(
                              color: AppColors.coral,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
              if (confirmed == true && mounted) {
                await ref.read(authProvider.notifier).logout();
                // AuthGate will automatically redirect to LoginScreen
              }
            },
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      borderRadius: 16,
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  color: AppColors.coral, strokeWidth: 2))
          : const Text(
              'Sign Out',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.coral,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
    );
  }
}

// ── Shared preference row widget ─────────────────────────────
class _PrefRow extends StatelessWidget {
  final String icon, label, value;
  final Widget? trailing;

  const _PrefRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: AppColors.white50, fontSize: 11)),
                  const SizedBox(height: 1),
                  Text(value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
