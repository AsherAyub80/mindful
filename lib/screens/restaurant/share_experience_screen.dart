import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/app_data.dart';
import '../../widgets/glass_widgets.dart';

class ShareExperienceScreen extends StatefulWidget {
  final Restaurant restaurant;
  final String mood;
  final String moodEmoji;
  const ShareExperienceScreen({super.key, required this.restaurant, required this.mood, required this.moodEmoji});

  @override
  State<ShareExperienceScreen> createState() => _ShareExperienceScreenState();
}

class _ShareExperienceScreenState extends State<ShareExperienceScreen>
    with SingleTickerProviderStateMixin {
  String? _moodAfter;
  final _orderCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _hasPhoto = false;
  bool _submitted = false;
  late AnimationController _successCtrl;

  final List<_MoodOption> _moodOptions = const [
    _MoodOption('😊', 'Happier'),
    _MoodOption('🌿', 'Calm'),
    _MoodOption('⚡', 'Energized'),
    _MoodOption('🤍', 'Comforted'),
    _MoodOption('✨', 'Glowing'),
    _MoodOption('🧘', 'Centered'),
  ];

  @override
  void initState() {
    super.initState();
    _successCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _orderCtrl.dispose();
    _noteCtrl.dispose();
    _successCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_moodAfter == null || _orderCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in what you ordered and your mood after 🌿'),
          backgroundColor: AppColors.bgMid,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    // Add to community feed
    final newPost = CommunityPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      user: 'Alex Rivers',
      handle: '@alex_mindful',
      time: 'Just now',
      dish: widget.restaurant.name,
      likes: 0,
      comments: 0,
      liked: false,
      saved: false,
      mood: '$_moodAfter',
      avatar: 'AR',
      postType: PostType.dining,
      moodBefore: '${widget.moodEmoji} ${widget.mood}',
      moodAfter: _moodAfter,
      restaurantName: widget.restaurant.name,
      note: _noteCtrl.text.trim().isNotEmpty ? _noteCtrl.text.trim() : 'Great experience overall!',
    );
    AppData.posts.insert(0, newPost);
    setState(() => _submitted = true);
    _successCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Stack(
        children: [
          Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
          AmbientBlob(alignment: const Alignment(0.9, -0.7), color: widget.restaurant.accentColor, size: 200),
          const AmbientBlob(alignment: Alignment(-0.8, 0.6), color: AppColors.emerald, size: 160),
          SafeArea(
            child: _submitted ? _buildSuccessState(context) : _buildForm(context),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRestaurantHeader(),
                const SizedBox(height: 24),
                _buildMoodBeforeSection(),
                const SizedBox(height: 20),
                _buildOrderField(),
                const SizedBox(height: 20),
                _buildMoodAfterSection(),
                const SizedBox(height: 20),
                _buildNoteField(),
                const SizedBox(height: 20),
                _buildPhotoSection(),
                const SizedBox(height: 28),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          NeuButton(
            onTap: () => Navigator.pop(context),
            borderRadius: 20, width: 40, height: 40, padding: EdgeInsets.zero,
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text('Share Your Experience',
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantHeader() {
    final r = widget.restaurant;
    return GlassCard(
      gradient: LinearGradient(
        colors: [r.accentColor.withOpacity(0.2), r.accentColor.withOpacity(0.08)],
      ),
      backgroundColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: r.accentColor.withOpacity(0.2),
              border: Border.all(color: r.accentColor.withOpacity(0.4)),
            ),
            child: Center(child: Text(r.emoji??"", style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r.name,
                    style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(r.cuisine, style: const TextStyle(color: AppColors.white50, fontSize: 12)),
                const SizedBox(height: 4),
                StarRating(rating: r.safeRating, size: 13),
              ],
            ),
          ),
          PillBadge(label: '🍽️ Dining Out', bgColor: AppColors.primary.withOpacity(0.2), textColor: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildMoodBeforeSection() {
    return _FormSection(
      label: '😶 Mood Before',
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Text(widget.moodEmoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(widget.mood,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            PillBadge(label: 'Auto-detected', bgColor: AppColors.primary.withOpacity(0.15), textColor: AppColors.accent, fontSize: 9),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderField() {
    return _FormSection(
      label: '🍜 What did you order?',
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: TextField(
          controller: _orderCtrl,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'e.g. Matcha Buddha Bowl, Ginger Miso Soup...',
            hintStyle: TextStyle(color: AppColors.white50, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodAfterSection() {
    return _FormSection(
      label: '✨ Mood After',
      child: Wrap(
        spacing: 8, runSpacing: 8,
        children: _moodOptions.map((m) {
          final isSelected = _moodAfter == '${m.emoji} ${m.label}';
          return GestureDetector(
            onTap: () => setState(() => _moodAfter = '${m.emoji} ${m.label}'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [AppColors.primary, AppColors.deep])
                    : null,
                color: isSelected ? null : AppColors.white10,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.white15,
                ),
                boxShadow: isSelected
                    ? [const BoxShadow(color: Color(0x664FACB8), blurRadius: 10)]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(m.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(m.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.white70,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNoteField() {
    return _FormSection(
      label: '📝 Add a note (optional)',
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: TextField(
          controller: _noteCtrl,
          maxLines: 3,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: 'Share how this experience made you feel...',
            hintStyle: TextStyle(color: AppColors.white50, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return _FormSection(
      label: '📷 Add a photo (optional)',
      child: GestureDetector(
        onTap: () => setState(() => _hasPhoto = !_hasPhoto),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: _hasPhoto ? 160 : 70,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _hasPhoto ? AppColors.primary.withOpacity(0.4) : AppColors.white20,
              style: BorderStyle.solid,
              width: 1,
            ),
            color: _hasPhoto
                ? AppColors.primary.withOpacity(0.08)
                : AppColors.white10,
          ),
          child: Center(
            child: _hasPhoto
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('📸', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: 8),
                      const Text('Photo added!',
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13)),
                      const SizedBox(height: 2),
                      const Text('Tap to remove',
                          style: TextStyle(color: AppColors.white50, fontSize: 11)),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_rounded, color: AppColors.white50, size: 20),
                      SizedBox(width: 8),
                      Text('Tap to upload a photo',
                          style: TextStyle(color: AppColors.white50, fontSize: 13)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return NeuButton(
      active: true,
      onTap: _submit,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      borderRadius: 18,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🌿', style: TextStyle(fontSize: 18)),
          SizedBox(width: 10),
          Text('Share with Community',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildSuccessState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.elasticOut,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.emerald]),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30)],
                ),
                child: const Center(child: Text('✨', style: TextStyle(fontSize: 44))),
              ),
            ),
            const SizedBox(height: 28),
            Text('Experience Shared!',
                style: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
              'Your dining experience has been added to the community feed. Thank you for inspiring others!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.white70, fontSize: 14, height: 1.6),
            ),
            const SizedBox(height: 8),
            if (_moodAfter != null) ...[
              const SizedBox(height: 8),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Column(
                  children: [
                    const Text('Your mood journey today',
                        style: TextStyle(color: AppColors.white50, fontSize: 11, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    MoodArrow(
                      before: '${widget.moodEmoji} ${widget.mood}',
                      after: _moodAfter!,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            NeuButton(
              active: true,
              onTap: () {
                int count = 0;
                Navigator.popUntil(context, (_) => count++ >= 3);
              },
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: 16,
              child: const Text('Back to Community Feed',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            NeuButton(
              onTap: () {
                int count = 0;
                Navigator.popUntil(context, (_) => count++ >= 4);
              },
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              borderRadius: 16,
              child: const Text('Go Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white70, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _MoodOption {
  final String emoji, label;
  const _MoodOption(this.emoji, this.label);
}
