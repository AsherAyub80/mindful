import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/app_data.dart';
import '../../widgets/glass_widgets.dart';
import 'share_experience_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String mood;
  final String moodEmoji;
  const RestaurantDetailScreen({super.key, required this.restaurant, required this.mood, required this.moodEmoji});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _saved = false;
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..forward();
  }

  @override
  void dispose() { _entryCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final r = widget.restaurant;
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
          AmbientBlob(alignment: const Alignment(-0.8, -0.5), color: r.accentColor, size: 240),
          CustomScrollView(
            slivers: [
              _buildHeroAppBar(context),
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _entryCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _entryCtrl.value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - _entryCtrl.value)),
                      child: child,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildHeader(),
                        const SizedBox(height: 16),
                        _buildInfoRow(),
                        const SizedBox(height: 16),
                        _buildDescription(),
                        const SizedBox(height: 20),
                        _buildMenuHighlights(),
                        const SizedBox(height: 20),
                        _buildMoodMatch(),
                        const SizedBox(height: 24),
                        _buildShareButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroAppBar(BuildContext context) {
    final r = widget.restaurant;
    return SliverAppBar(
      expandedHeight: 220,
      backgroundColor: Colors.transparent,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: NeuButton(
          onTap: () => Navigator.pop(context),
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
            child: Text(_saved ? '🔖' : '📌', style: const TextStyle(fontSize: 16)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
          child: NeuButton(
            onTap: () {},
            borderRadius: 20, width: 40, height: 40, padding: EdgeInsets.zero,
            child: const Icon(Icons.share_rounded, color: Colors.white, size: 18),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [r.accentColor.withOpacity(0.4), const Color(0xFF0A1520)],
            ),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(top: -30, right: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(shape: BoxShape.circle, color: r.accentColor.withOpacity(0.08)))),
              Positioned(bottom: 20, left: -20, child: Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, color: r.accentColor.withOpacity(0.06)))),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(r.emoji??'', style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: r.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: r.accentColor.withOpacity(0.4), width: 0.5),
                      ),
                      child: Text(r.openStatus??'',
                          style: TextStyle(color: r.accentColor, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  height: 60,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xFF080F18), Colors.transparent],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final r = widget.restaurant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(r.name,
                  style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 12),
            Column(
              children: [
                StarRating(rating: r.safeRating, size: 16),
                const SizedBox(height: 2),
                Text('${(r.safeRating * 100).toInt()} reviews',
                    style: const TextStyle(color: AppColors.white50, fontSize: 10)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(r.cuisine, style: const TextStyle(color: AppColors.white50, fontSize: 13)),
      ],
    );
  }

  Widget _buildInfoRow() {
    final r = widget.restaurant;
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _DetailTile(icon: '📍', label: 'Distance', value: r.distanceString),
          _Divider(),
          _DetailTile(icon: '💰', label: 'Price', value: r.priceString),
          _Divider(),
          _DetailTile(icon: '⭐', label: 'Rating', value: r.safeRating.toStringAsFixed(1)),
          _Divider(),
          _DetailTile(icon: '🕐', label: 'Status', value: 'Open'),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 16),
            SizedBox(width: 8),
            Text('About', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          ]),
          const SizedBox(height: 10),
          Text(widget.restaurant.description??"",
              style: const TextStyle(color: AppColors.white70, fontSize: 13, height: 1.6)),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.location_on_rounded, color: AppColors.white50, size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(widget.restaurant.address,
                style: const TextStyle(color: AppColors.white50, fontSize: 12))),
          ]),
        ],
      ),
    );
  }

  Widget _buildMenuHighlights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: '🍴 Menu Highlights'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 3.2,
          children: widget.restaurant.menuHighlights.map((item) => GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(color: widget.restaurant.accentColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(item, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMoodMatch() {
    return GlassCard(
      gradient: LinearGradient(
        colors: [AppColors.primary.withOpacity(0.2), AppColors.emerald.withOpacity(0.12)],
      ),
      backgroundColor: Colors.transparent,
      child: Row(
        children: [
          Text(widget.moodEmoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Perfect for your ${widget.mood} mood',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 3),
                const Text('This spot is curated by MindfulMeals AI based on how you\'re feeling today.',
                    style: TextStyle(color: AppColors.white50, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context) {
    return NeuButton(
      active: true,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ShareExperienceScreen(
          restaurant: widget.restaurant,
          mood: widget.mood,
          moodEmoji: widget.moodEmoji,
        )),
      ),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: 18,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👉', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Text('Share Your Experience',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String icon, label, value;
  const _DetailTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
          Text(label, style: const TextStyle(color: AppColors.white50, fontSize: 9)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 0.5, height: 36, color: AppColors.white15);
  }
}
