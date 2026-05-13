// lib/screens/comments_screen.dart
// ══════════════════════════════════════════════════════════════
//  MindfulMeals — Comments Screen
//  Loads:  GET  /v1/posts/:id/comments
//  Posts:  POST /v1/posts/:id/comments  { body, parent_id? }
//  Pushed from CommunityScreen's post comment button
//  Supports one level of reply threading
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_widgets.dart';
import '../services/api_service.dart';

// ── Simple comment data class ─────────────────────────────────
class _Comment {
  final String  id;
  final String  body;
  final String? parentId;
  final String  createdAt;
  final String  userName;
  final String  userHandle;
  final String? avatarUrl;

  _Comment({
    required this.id,
    required this.body,
    this.parentId,
    required this.createdAt,
    required this.userName,
    required this.userHandle,
    this.avatarUrl,
  });

  factory _Comment.fromJson(Map<String, dynamic> j) {
    final user = j['users'] as Map<String, dynamic>? ?? {};
    return _Comment(
      id:          j['id']        as String? ?? '',
      body:        j['body']      as String? ?? '',
      parentId:    j['parent_id'] as String?,
      createdAt:   j['created_at'] as String? ?? '',
      userName:    user['name']   as String? ?? 'User',
      userHandle:  user['handle'] as String? ?? 'user',
      avatarUrl:   user['avatar_url'] as String?,
    );
  }

  String get initials => userName.split(' ')
      .where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();

  String get timeAgo {
    if (createdAt.isEmpty) return '';
    try {
      final diff = DateTime.now().difference(DateTime.parse(createdAt));
      if (diff.inSeconds < 60)  return 'just now';
      if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
      if (diff.inHours   < 24)  return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (_) { return ''; }
  }
}

// ══════════════════════════════════════════════════════════════
class CommentsScreen extends ConsumerStatefulWidget {
  final String postId;
  final String postDish;   // title of the post (shown in header)

  const CommentsScreen({
    super.key,
    required this.postId,
    required this.postDish,
  });

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _textController = TextEditingController();
  final _inputFocus     = FocusNode();
  final _scrollCtrl     = ScrollController();

  List<_Comment> _comments  = [];
  bool   _loading  = true;
  bool   _sending  = false;
  String? _replyToId;       // parentId when replying
  String? _replyToHandle;   // shown in the "Replying to @..." banner

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _textController.dispose();
    _inputFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getComments(widget.postId);
      final raw = (data['comments'] as List?) ?? [];
      setState(() {
        _comments = raw.map((c) => _Comment.fromJson(c as Map<String, dynamic>)).toList();
        _loading  = false;
      });
    } catch (_) {
      setState(() { _comments = []; _loading = false; });
    }
  }

  Future<void> _sendComment() async {
    final body = _textController.text.trim();
    if (body.isEmpty || _sending) return;

    setState(() => _sending = true);
    _textController.clear();

    // Optimistic update — add locally immediately
    final optimistic = _Comment(
      id:          'temp-${DateTime.now().millisecondsSinceEpoch}',
      body:        body,
      parentId:    _replyToId,
      createdAt:   DateTime.now().toIso8601String(),
      userName:    'You',
      userHandle:  'you',
    );
    setState(() {
      _comments.add(optimistic);
      _replyToId     = null;
      _replyToHandle = null;
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    try {
      await ApiService.addComment(
        widget.postId, body,
        parentId: optimistic.parentId,
      );
      // Refresh to get server-assigned IDs & accurate data
      await _loadComments();
    } catch (_) {
      // Keep optimistic comment visible even on failure
    }
    setState(() => _sending = false);
  }

  void _startReply(_Comment comment) {
    setState(() {
      _replyToId     = comment.id;
      _replyToHandle = comment.userHandle;
    });
    _inputFocus.requestFocus();
  }

  void _cancelReply() {
    setState(() { _replyToId = null; _replyToHandle = null; });
    _inputFocus.unfocus();
  }

  // ── Build ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(gradient: AppColors.backgroundGradient)),
        const AmbientBlob(alignment: Alignment(-0.8, -0.6), color: AppColors.primary, size: 200),
        SafeArea(
          child: Column(children: [
            _buildHeader(),
            Expanded(child: _buildCommentList()),
            if (_replyToHandle != null) _buildReplyBanner(),
            _buildInputBar(),
          ]),
        ),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(children: [
        NeuButton(
          onTap: () => Navigator.pop(context),
          borderRadius: 12, width: 40, height: 40, padding: EdgeInsets.zero,
          child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Comments',
                style: GoogleFonts.playfairDisplay(
                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
            Text(widget.postDish,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.white50, fontSize: 11)),
          ]),
        ),
        if (!_loading)
          PillBadge(
            label: '${_comments.length}',
            bgColor: AppColors.primary.withOpacity(0.2),
            textColor: AppColors.accent,
          ),
      ]),
    );
  }

  // ── Comment list ──────────────────────────────────────────────
  Widget _buildCommentList() {
    if (_loading) return _buildSkeleton();

    if (_comments.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('💬', style: TextStyle(fontSize: 44)),
          const SizedBox(height: 12),
          const Text('No comments yet',
              style: TextStyle(color: Colors.white, fontSize: 16,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Be the first to share your thoughts!',
              style: TextStyle(color: AppColors.white50, fontSize: 12)),
        ]),
      );
    }

    // Build threaded view: top-level first, replies after their parent
    final topLevel = _comments.where((c) => c.parentId == null).toList();
    final repliesFor = <String, List<_Comment>>{};
    for (final c in _comments.where((c) => c.parentId != null)) {
      repliesFor.putIfAbsent(c.parentId!, () => []).add(c);
    }

    final items = <Widget>[];
    for (final comment in topLevel) {
      items.add(_CommentTile(
        comment: comment,
        isReply: false,
        onReply: () => _startReply(comment),
      ));
      // Replies to this comment
      final replies = repliesFor[comment.id] ?? [];
      for (final reply in replies) {
        items.add(_CommentTile(
          comment: reply,
          isReply: true,
          onReply: () => _startReply(comment), // reply goes to parent
        ));
      }
    }

    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: items.length,
      itemBuilder: (_, i) => items[i],
    );
  }

  // ── Skeleton ──────────────────────────────────────────────────
  Widget _buildSkeleton() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, __) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SkeletonLoader(width: 36, height: 36, borderRadius: 18),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkeletonLoader(width: 110, height: 11, borderRadius: 5),
          const SizedBox(height: 6),
          SkeletonLoader(width: double.infinity, height: 13, borderRadius: 6),
          const SizedBox(height: 4),
          SkeletonLoader(width: 160, height: 13, borderRadius: 6),
        ])),
      ]),
    );
  }

  // ── Reply banner ──────────────────────────────────────────────
  Widget _buildReplyBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        border: Border(
          top:    BorderSide(color: AppColors.primary.withOpacity(0.3), width: 0.5),
          bottom: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 0.5),
        ),
      ),
      child: Row(children: [
        const Icon(Icons.reply_rounded, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text('Replying to @$_replyToHandle',
              style: const TextStyle(color: AppColors.accent, fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ),
        GestureDetector(
          onTap: _cancelReply,
          child: const Icon(Icons.close_rounded, color: AppColors.white50, size: 16),
        ),
      ]),
    );
  }

  // ── Input bar ─────────────────────────────────────────────────
  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 10, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      decoration: BoxDecoration(
        color: const Color(0xEB080F18),
        border: Border(top: BorderSide(color: AppColors.white15, width: 0.5)),
      ),
      child: Row(children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextField(
              controller: _textController,
              focusNode:  _inputFocus,
              maxLines:   3,
              minLines:   1,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: _replyToHandle != null
                    ? 'Reply to @$_replyToHandle…'
                    : 'Add a comment…',
                hintStyle: const TextStyle(color: AppColors.white50, fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _sendComment,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40, height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.deep]),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(
                  color: Color(0x664FACB8), blurRadius: 10)],
            ),
            child: _sending
                ? const Center(child: SizedBox(width: 18, height: 18,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2)))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 18),
          ),
        ),
      ]),
    );
  }
}

// ── Single comment tile ───────────────────────────────────────
class _CommentTile extends StatelessWidget {
  final _Comment   comment;
  final bool       isReply;
  final VoidCallback onReply;

  const _CommentTile({
    required this.comment,
    required this.isReply,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: isReply ? 40 : 0, top: 6, bottom: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Reply indent line
        if (isReply)
          Container(
            width: 2, height: 36,
            margin: const EdgeInsets.only(right: 8, top: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.4),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        // Avatar
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
                colors: [AppColors.deep, AppColors.emerald]),
          ),
          child: Center(
            child: Text(comment.initials,
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 12)),
          ),
        ),
        const SizedBox(width: 10),
        // Content
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Name + time
              Row(children: [
                Expanded(
                  child: Text(comment.userName,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                Text(comment.timeAgo,
                    style: const TextStyle(color: AppColors.white50, fontSize: 10)),
              ]),
              Text('@${comment.userHandle}',
                  style: const TextStyle(color: AppColors.white50, fontSize: 10)),
              const SizedBox(height: 6),
              // Body
              Text(comment.body,
                  style: const TextStyle(color: Color(0xD9FFFFFF),
                      fontSize: 13, height: 1.45)),
              const SizedBox(height: 6),
              // Reply button
              GestureDetector(
                onTap: onReply,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.reply_rounded, color: AppColors.primary, size: 14),
                  const SizedBox(width: 4),
                  const Text('Reply',
                      style: TextStyle(color: AppColors.primary,
                          fontSize: 11, fontWeight: FontWeight.w500)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
