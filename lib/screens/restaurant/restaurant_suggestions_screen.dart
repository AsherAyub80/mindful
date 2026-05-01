import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/app_data.dart';
import '../../widgets/glass_widgets.dart';
import 'restaurant_detail_screen.dart';

class RestaurantSuggestionsScreen extends StatefulWidget {
  final String mood;
  final String moodEmoji;
  const RestaurantSuggestionsScreen(
      {super.key, required this.mood, required this.moodEmoji});

  @override
  State<RestaurantSuggestionsScreen> createState() =>
      _RestaurantSuggestionsScreenState();
}

class _RestaurantSuggestionsScreenState
    extends State<RestaurantSuggestionsScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  List<Restaurant> _restaurants = [];
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _simulateLoad();
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  void _simulateLoad() {
    Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      final filtered = AppData.restaurants
          .where((r) => r.moodTags.contains(widget.mood) || r.moodTags.isEmpty)
          .toList();
      setState(() {
        _restaurants = filtered.isEmpty ? AppData.restaurants : filtered;
        _loading = false;
      });
      _staggerCtrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Container(
              decoration:
                  const BoxDecoration(gradient: AppColors.backgroundGradient)),
          const AmbientBlob(
              alignment: Alignment(-0.9, -0.6),
              color: AppColors.primary,
              size: 220),
          const AmbientBlob(
              alignment: Alignment(0.8, 0.5),
              color: AppColors.emerald,
              size: 180),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                _buildMoodContextBanner(),
                Expanded(
                  child:
                      _loading ? _buildSkeletonList() : _buildRestaurantList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          NeuButton(
            onTap: () => Navigator.pop(context),
            borderRadius: 20,
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            child:
                const Icon(Icons.chevron_left, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Restaurants Near You',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
          ),
          NeuButton(
            onTap: () {},
            borderRadius: 20,
            width: 40,
            height: 40,
            padding: EdgeInsets.zero,
            child:
                const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodContextBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: GlassCard(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.22),
            AppColors.emerald.withOpacity(0.16)
          ],
        ),
        backgroundColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Center(
                  child: Text(widget.moodEmoji,
                      style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    PillBadge(
                      label: widget.mood,
                      bgColor: AppColors.primary.withOpacity(0.25),
                      textColor: AppColors.accent,
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.location_on_rounded,
                        color: AppColors.primary, size: 13),
                    const Text('1.5 km radius',
                        style:
                            TextStyle(color: AppColors.white50, fontSize: 11)),
                  ]),
                  const SizedBox(height: 5),
                  Text(
                    AppData.moodMessages[widget.mood] ??
                        'Here are some great places nearby',
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: 4,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, __) => const RestaurantCardSkeleton(),
    );
  }

  Widget _buildRestaurantList() {
    if (_restaurants.isEmpty) return _buildEmptyState();
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: _restaurants.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, i) {
        final delay = i * 0.12;
        return AnimatedBuilder(
          animation: _staggerCtrl,
          builder: (_, child) {
            final t = Curves.easeOutCubic.transform(
              ((_staggerCtrl.value - delay) / (1 - delay)).clamp(0.0, 1.0),
            );
            return Opacity(
              opacity: t,
              child: Transform.translate(
                  offset: Offset(0, 30 * (1 - t)), child: child),
            );
          },
          child: _RestaurantCard(
            restaurant: _restaurants[i],
            mood: widget.mood,
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantDetailScreen(
                    restaurant: _restaurants[i],
                    mood: widget.mood,
                    moodEmoji: widget.moodEmoji,
                  ),
                )),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🍽️', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text('No restaurants found nearby',
              style: GoogleFonts.playfairDisplay(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          const Text('Try adjusting your mood or location filter',
              style: TextStyle(color: AppColors.white50, fontSize: 13)),
          const SizedBox(height: 24),
          NeuButton(
            onTap: () => setState(() {
              _loading = true;
              _simulateLoad();
            }),
            active: true,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Text('Try Again',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final String mood;
  final VoidCallback onTap;
  const _RestaurantCard(
      {required this.restaurant, required this.mood, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final matches = restaurant.moodTags.contains(mood);
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              children: [
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        restaurant.accentColor.withOpacity(0.3),
                        restaurant.accentColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Center(
                      child: Text(restaurant.emoji ?? "",
                          style: const TextStyle(fontSize: 52))),
                ),
                if (matches)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      borderRadius: 20,
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('💙', style: TextStyle(fontSize: 11)),
                          SizedBox(width: 4),
                          Text('Matches your mood',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(0)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [const Color(0xFF080F18), Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(restaurant.name,
                            style: GoogleFonts.playfairDisplay(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                      ),
                      StarRating(rating: restaurant.safeRating),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(restaurant.cuisine,
                      style: const TextStyle(
                          color: AppColors.white50, fontSize: 12)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoPill(
                          icon: Icons.location_on_rounded,
                          label: restaurant.distanceString,
                          color: AppColors.primary),
                      const SizedBox(width: 8),
                      _InfoPill(
                          icon: Icons.attach_money_rounded,
                          label: restaurant.priceString,
                          color: AppColors.secondary),
                      const SizedBox(width: 8),
                      _InfoPill(
                          icon: Icons.access_time_rounded,
                          label: 'Open Now',
                          color: AppColors.emerald),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoPill(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class RestaurantCardSkeleton extends StatelessWidget {
  const RestaurantCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(
              width: double.infinity, height: 130, borderRadius: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SkeletonLoader(
                        width: 150, height: 18, borderRadius: 9),
                    const Spacer(),
                    const SkeletonLoader(
                        width: 40, height: 14, borderRadius: 7),
                  ],
                ),
                const SizedBox(height: 8),
                const SkeletonLoader(width: 100, height: 14, borderRadius: 7),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const SkeletonLoader(
                        width: 60, height: 20, borderRadius: 8),
                    const SizedBox(width: 8),
                    const SkeletonLoader(
                        width: 50, height: 20, borderRadius: 8),
                    const SizedBox(width: 8),
                    const SkeletonLoader(
                        width: 70, height: 20, borderRadius: 8),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
