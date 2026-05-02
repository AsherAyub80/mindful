import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/feed_provider.dart';
import '../theme/app_colors.dart';
import '../models/app_data.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedState = ref.watch(feedProvider);
    return Column(children: [
      Expanded(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.bgMid,
          onRefresh: () =>
              ref.read(feedProvider.notifier).loadFeed(refresh: true),
          child: CustomScrollView(slivers: [
            SliverToBoxAdapter(
                child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Column(children: [
                _buildHeader(context, ref, feedState),
                const SizedBox(height: 16),
                _buildTrending(),
                const SizedBox(height: 16),
                _buildStories(feedState),
                const SizedBox(height: 16),
                _buildFilterTabs(ref, feedState.filter ?? 'all'),
                const SizedBox(height: 4),
              ]),
            )),
            if (feedState.isLoading && feedState.posts.isEmpty)
              SliverToBoxAdapter(child: _buildSkeletons())
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    if (i == feedState.posts.length) {
                      if (feedState.hasMore && !feedState.isLoading) {
                        // Use microtask to avoid building while fetching
                        Future.microtask(
                            () => ref.read(feedProvider.notifier).loadFeed());
                      }

                      if (feedState.isLoading) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      }

                      if (!feedState.hasMore && feedState.posts.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                const Text('✨', style: TextStyle(fontSize: 24)),
                                const SizedBox(height: 8),
                                Text(
                                  'You\'ve reached the end of the feed',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.white50,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox(height: 24);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _PostCard(
                        post: feedState.posts[i],
                        onLike: () => ref
                            .read(feedProvider.notifier)
                            .toggleLike(feedState.posts[i].id),
                        onSave: () {
                          final posts = feedState.posts;
                          posts[i].saved = !posts[i].saved;
                          ref.read(feedProvider.notifier).state =
                              feedState.copyWith(posts: List.from(posts));
                        },
                      ),
                    );
                  },
                  childCount: feedState.posts.length + 1,
                )),
              ),
          ]),
        ),
      ),
    ]);
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, FeedState fs) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Community',
            style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700)),
        if (fs.usedMock)
          const Text('Showing demo data — connect backend for live feed',
              style: TextStyle(color: AppColors.white50, fontSize: 10)),
      ]),
      NeuButton(
        active: true,
        onTap: () => _showCreatePost(context, ref),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.add, color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text('Share',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    ]);
  }

  Widget _buildTrending() {
    return GlassCard(
      gradient:
          const LinearGradient(colors: [Color(0x2E4FACB8), Color(0x213DAA7A)]),
      backgroundColor: Colors.transparent,
      child: Row(children: [
        const Text('🔥', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          PillBadge(
              label: 'TRENDING THIS WEEK',
              bgColor: AppColors.primary.withOpacity(0.18),
              textColor: AppColors.accent),
          const SizedBox(height: 4),
          const Text('Avocado Mango Tartare · 2.4k shares',
              style: TextStyle(color: Colors.white, fontSize: 13)),
        ]),
      ]),
    );
  }

  Widget _buildStories(FeedState fs) {
    final posts = fs.posts.isNotEmpty ? fs.posts : AppData.posts;
    return SizedBox(
        height: 80,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          ...posts.take(5).map((p) => Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Column(children: [
                Stack(children: [
                  Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.emerald]),
                          border:
                              Border.all(color: AppColors.primary, width: 2)),
                      child: Center(
                          child: Text(p.avatar,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14)))),
                  if (p.postType == PostType.dining)
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                                color: AppColors.bgDark,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.white15)),
                            child: const Center(
                                child: Text('🍽️',
                                    style: TextStyle(fontSize: 9))))),
                ]),
                const SizedBox(height: 4),
                SizedBox(
                    width: 52,
                    child: Text(p.user.split(' ')[0],
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: AppColors.white50, fontSize: 10))),
              ]))),
          Column(children: [
            Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white10,
                    border: Border.all(
                        color: AppColors.white20, style: BorderStyle.solid)),
                child: const Center(
                    child: Text('+',
                        style: TextStyle(
                            color: AppColors.white50, fontSize: 20)))),
            const SizedBox(height: 4),
            const Text('You',
                style: TextStyle(color: AppColors.white50, fontSize: 10)),
          ]),
        ]));
  }

  Widget _buildFilterTabs(WidgetRef ref, String current) {
    return GlassCard(
      padding: const EdgeInsets.all(5),
      borderRadius: 14,
      child: Row(children: [
        for (final tab in [
          ('all', 'All'),
          ('recipe', '🍳 Recipes'),
          ('dining', '🍽️ Dining')
        ])
          Expanded(
              child: GestureDetector(
            onTap: () => ref.read(feedProvider.notifier).setFilter(tab.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: current == tab.$1
                    ? const LinearGradient(
                        colors: [AppColors.primary, AppColors.deep])
                    : null,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(tab.$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color:
                          current == tab.$1 ? Colors.white : AppColors.white50,
                      fontSize: 12,
                      fontWeight: current == tab.$1
                          ? FontWeight.w700
                          : FontWeight.w400)),
            ),
          )),
      ]),
    );
  }

  Widget _buildSkeletons() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
          children: List.generate(
              3,
              (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassCard(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Row(children: [
                            const SkeletonLoader(
                                width: 40, height: 40, borderRadius: 20),
                            const SizedBox(width: 10),
                            Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SkeletonLoader(
                                      width: 120, height: 12, borderRadius: 6),
                                  const SizedBox(height: 4),
                                  SkeletonLoader(
                                      width: 80, height: 10, borderRadius: 5)
                                ])
                          ]),
                          const SizedBox(height: 12),
                          const SkeletonLoader(
                              width: double.infinity,
                              height: 100,
                              borderRadius: 12),
                          const SizedBox(height: 10),
                          SkeletonLoader(
                              width: 160, height: 14, borderRadius: 7),
                        ])),
                  ))),
    );
  }

  void _showCreatePost(BuildContext context, WidgetRef ref) {
    String type = 'recipe';
    final noteCtrl = TextEditingController();
    final orderedItemsCtrl = TextEditingController();
    File? pickedImage;
    String? moodBefore;
    String? moodAfter;
    bool isSubmitting = false;

    const moods = [
      ('😊', 'Happy'),
      ('🌿', 'Calm'),
      ('⚡', 'Energized'),
      ('🤍', 'Comforted'),
      ('✨', 'Glowing'),
      ('🎯', 'Focused'),
    ];

    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) {
          return StatefulBuilder(builder: (_, setState) {
            Future<void> pickImage() async {
              final source = await showModalBottomSheet<ImageSource>(
                context: ctx,
                backgroundColor: Colors.transparent,
                builder: (_) => Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xEC0A131C),
                    border: Border.all(color: AppColors.white15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library,
                          color: AppColors.primary),
                      title: const Text('Gallery',
                          style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(ctx, ImageSource.gallery),
                    ),
                    ListTile(
                      leading: const Icon(Icons.camera_alt,
                          color: AppColors.emerald),
                      title: const Text('Camera',
                          style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.pop(ctx, ImageSource.camera),
                    ),
                  ]),
                ),
              );
              if (source == null) return;
              final picked = await ImagePicker()
                  .pickImage(source: source, maxWidth: 1200, imageQuality: 85);
              if (picked != null) {
                setState(() => pickedImage = File(picked.path));
              }
            }

            Future<void> submitPost() async {
              if (isSubmitting) return;
              setState(() => isSubmitting = true);
              try {
                final post = await ApiService.createPost(
                  postType: type,
                  note: noteCtrl.text.trim().isEmpty
                      ? null
                      : noteCtrl.text.trim(),
                  imageFile: pickedImage,
                  moodBefore: moodBefore,
                  moodAfter: moodAfter,
                  orderedItems: type == 'dining' &&
                          orderedItemsCtrl.text.trim().isNotEmpty
                      ? orderedItemsCtrl.text.trim()
                      : null,
                );
                ref
                    .read(feedProvider.notifier)
                    .addPost(CommunityPost.fromJson(post['post']));
              } catch (e) {
                print('Error creating post: $e');
                // Fallback: add local mock post
                ref.read(feedProvider.notifier).addPost(CommunityPost(
                      id: DateTime.now().toString(),
                      user: 'You',
                      handle: '@you',
                      time: 'Just now',
                      dish:
                          'Your ${type == "recipe" ? "Recipe" : "Experience"}',
                      likes: 0,
                      comments: 0,
                      liked: false,
                      saved: false,
                      mood: moodAfter ?? '',
                      avatar: 'ME',
                      postType:
                          type == 'dining' ? PostType.dining : PostType.recipe,
                      note: noteCtrl.text,
                      moodBefore: moodBefore,
                      moodAfter: moodAfter,
                      imageUrl: pickedImage?.path,
                    ));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            }

            Widget buildMoodChips(
                String? selected, void Function(String) onSelect,
                {bool isAfter = false}) {
              return Wrap(spacing: 8, runSpacing: 8, children: [
                for (final m in moods)
                  GestureDetector(
                    onTap: () => onSelect('${m.$1} ${m.$2}'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: selected == '${m.$1} ${m.$2}'
                            ? LinearGradient(
                                colors: isAfter
                                    ? [AppColors.emerald, AppColors.primary]
                                    : [AppColors.primary, AppColors.deep])
                            : null,
                        color: selected == '${m.$1} ${m.$2}'
                            ? null
                            : AppColors.white10,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected == '${m.$1} ${m.$2}'
                              ? Colors.transparent
                              : AppColors.white15,
                        ),
                      ),
                      child: Text('${m.$1} ${m.$2}',
                          style: TextStyle(
                            color: selected == '${m.$1} ${m.$2}'
                                ? Colors.white
                                : AppColors.white70,
                            fontSize: 12,
                            fontWeight: selected == '${m.$1} ${m.$2}'
                                ? FontWeight.w600
                                : FontWeight.w400,
                          )),
                    ),
                  ),
              ]);
            }

            return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.88),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xEC0A131C),
                border: Border.all(color: AppColors.white15),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Handle bar + title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppColors.white20,
                          borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(height: 16),
                    Text('Share an Experience',
                        style: GoogleFonts.playfairDisplay(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700)),
                  ]),
                ),
                // Scrollable content
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20, 16, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      // ── Type selector ──
                      Row(children: [
                        for (final t in [
                          ('recipe', '🍳', 'Recipe', AppColors.emerald),
                          ('dining', '🍽️', 'Dining Out', AppColors.primary),
                        ])
                          Expanded(
                              child: Padding(
                            padding: EdgeInsets.only(
                                right: t.$1 == 'recipe' ? 8 : 0),
                            child: GestureDetector(
                              onTap: () => setState(() => type = t.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: type == t.$1
                                      ? t.$4.withOpacity(0.25)
                                      : AppColors.white10,
                                  border: Border.all(
                                      color: type == t.$1
                                          ? t.$4
                                          : AppColors.white15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(children: [
                                  Text(t.$2,
                                      style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 4),
                                  Text(t.$3,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ]),
                              ),
                            ),
                          )),
                      ]),
                      const SizedBox(height: 16),

                      // ── Image picker ──
                      GestureDetector(
                        onTap: pickedImage != null
                            ? () => setState(() => pickedImage = null)
                            : pickImage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: pickedImage != null ? 180 : 80,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: pickedImage != null
                                  ? AppColors.primary.withOpacity(0.4)
                                  : AppColors.white20,
                            ),
                            color:
                                pickedImage != null ? null : AppColors.white10,
                          ),
                          child: pickedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Stack(children: [
                                    Positioned.fill(
                                        child: Image.file(pickedImage!,
                                            fit: BoxFit.cover)),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ]),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                      Icon(Icons.add_photo_alternate_rounded,
                                          color: AppColors.white50, size: 22),
                                      SizedBox(width: 8),
                                      Text('Add a photo',
                                          style: TextStyle(
                                              color: AppColors.white50,
                                              fontSize: 13)),
                                    ]),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Dining: ordered items ──
                      if (type == 'dining') ...[
                        const _SheetLabel(text: '🍜 What did you order?'),
                        const SizedBox(height: 8),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          child: TextField(
                            controller: orderedItemsCtrl,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'e.g. Matcha Bowl, Miso Soup...',
                              hintStyle: TextStyle(
                                  color: AppColors.white50, fontSize: 13),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Mood before ──
                      const _SheetLabel(text: '😶 Mood Before'),
                      const SizedBox(height: 8),
                      buildMoodChips(
                          moodBefore, (v) => setState(() => moodBefore = v)),
                      const SizedBox(height: 16),

                      // ── Mood after ──
                      const _SheetLabel(text: '✨ Mood After'),
                      const SizedBox(height: 8),
                      buildMoodChips(
                          moodAfter, (v) => setState(() => moodAfter = v),
                          isAfter: true),
                      const SizedBox(height: 16),

                      // ── Note ──
                      const _SheetLabel(text: '📝 Add a note'),
                      const SizedBox(height: 8),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        child: TextField(
                          controller: noteCtrl,
                          maxLines: 3,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText:
                                'Share how this experience made you feel...',
                            hintStyle: TextStyle(
                                color: AppColors.white50, fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Submit ──
                      NeuButton(
                        active: !isSubmitting,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        borderRadius: 16,
                        onTap: isSubmitting ? null : () => submitPost(),
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Share with Community',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ),
                ),
              ]),
            );
          });
        });
  }
}

class _PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback onLike, onSave;
  const _PostCard(
      {required this.post, required this.onLike, required this.onSave});
  bool get isDining => post.postType == PostType.dining;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      gradient: isDining
          ? LinearGradient(
              colors: [AppColors.primary.withOpacity(0.07), Colors.transparent])
          : null,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                      colors: [AppColors.deep, AppColors.emerald])),
              child: Center(
                  child: Text(post.avatar,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)))),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(post.user,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text('${post.handle} · ${post.time}',
                    style: const TextStyle(
                        color: AppColors.white50, fontSize: 11)),
              ])),
          PillBadge(
              label: isDining ? '🍽️ Dining Out' : '🍳 Recipe',
              bgColor: isDining
                  ? AppColors.primary.withOpacity(0.18)
                  : AppColors.emerald.withOpacity(0.18),
              textColor: isDining ? AppColors.accent : AppColors.mint),
        ]),
        const SizedBox(height: 12),
        if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: post.imageUrl!.startsWith('http')
                ? CachedNetworkImage(
                    imageUrl: post.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        _buildImagePlaceholder(loading: true),
                    errorWidget: (context, url, error) =>
                        _buildImagePlaceholder(),
                  )
                : Image.file(File(post.imageUrl!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildImagePlaceholder()),
          )
        else
          _buildImagePlaceholder(),
        const SizedBox(height: 12),
        Text(post.dish,
            style: GoogleFonts.playfairDisplay(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600)),
        if (isDining && post.moodBefore != null && post.moodAfter != null) ...[
          const SizedBox(height: 8),
          GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              backgroundColor: AppColors.white10,
              child: Row(children: [
                const Text('Mood',
                    style: TextStyle(color: AppColors.white50, fontSize: 10)),
                const SizedBox(width: 8),
                MoodArrow(before: post.moodBefore!, after: post.moodAfter!)
              ])),
        ],
        if (post.note != null && post.note!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('"${post.note}"',
              style: const TextStyle(
                  color: AppColors.white70,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  height: 1.5)),
        ],
        const SizedBox(height: 12),
        const Divider(color: AppColors.white10, height: 1),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
              child: _Btn(
                  icon: post.liked ? '❤️' : '🤍',
                  label: '${post.likes}',
                  onTap: onLike)),
          const SizedBox(width: 8),
          Expanded(
              child: _Btn(icon: '💬', label: '${post.comments}', onTap: () {})),
          const SizedBox(width: 8),
          _Btn(icon: post.saved ? '🔖' : '📌', onTap: onSave),
          const SizedBox(width: 8),
          _Btn(icon: '📤', onTap: () {}),
        ]),
      ]),
    );
  }

  Widget _buildImagePlaceholder({bool loading = false}) {
    return Container(
      height: 110,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: isDining
              ? [const Color(0x214FACB8), const Color(0x212D7D8E)]
              : [const Color(0x213DAA7A), const Color(0x214FACB8)],
        ),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white20,
                  strokeWidth: 2,
                ),
              )
            : Text(isDining ? '🏮' : '🍽️',
                style: const TextStyle(fontSize: 48)),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final String icon;
  final String? label;
  final VoidCallback onTap;
  const _Btn({required this.icon, this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
              color: AppColors.white10,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.white15)),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(icon, style: const TextStyle(fontSize: 14)),
                if (label != null) ...[
                  const SizedBox(width: 5),
                  Text(label!,
                      style: const TextStyle(
                          color: AppColors.white70, fontSize: 13))
                ],
              ]),
        ));
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(text,
          style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3)),
    );
  }
}
