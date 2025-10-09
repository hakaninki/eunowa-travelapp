import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/comment_model.dart';
import 'package:travel_app/features/post/application/comment_controller.dart';
import 'package:travel_app/features/post/providers/comment_stream_provider.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';
import 'package:travel_app/core/constants/app_colors.dart';

class CommentsPage extends ConsumerStatefulWidget {
  final String postId;
  const CommentsPage({super.key, required this.postId});

  @override
  ConsumerState<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends ConsumerState<CommentsPage> {
  final _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await ref
          .read(commentControllerProvider)
          .add(postId: widget.postId, text: text);
      _controller.clear();
      FocusScope.of(context).unfocus();
    } catch (e) {
      // ignore: avoid_print
      print('add comment error: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to add comment')));
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _openProfile(String userId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProfilePage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsStreamProvider(widget.postId));
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        backgroundColor: AppColors.appBarPeach,
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (List<CommentModel> comments) {
                if (comments.isEmpty) {
                  return const Center(child: Text('No comments yet'));
                }
                return ListView.separated(
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final c = comments[i];
                    return ListTile(
                      leading: GestureDetector(
                        onTap: () => _openProfile(c.userId),
                        child: CircleAvatar(
                          backgroundImage:
                              (c.photoUrl != null && c.photoUrl!.isNotEmpty)
                              ? NetworkImage(c.photoUrl!)
                              : null,
                          child: (c.photoUrl == null || c.photoUrl!.isEmpty)
                              ? const Icon(Icons.person)
                              : null,
                        ),
                      ),
                      title: GestureDetector(
                        onTap: () => _openProfile(c.userId),
                        child: Text(c.username),
                      ),
                      subtitle: Text(c.text),
                      trailing: (currentUid != null && currentUid == c.userId)
                          ? IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(commentControllerProvider)
                                      .delete(
                                        postId: widget.postId,
                                        commentId: c.id,
                                      );
                                } catch (e) {
                                  // ignore: avoid_print
                                  print('delete comment error: $e');
                                }
                              },
                            )
                          : null,
                      onTap: () => _openProfile(c.userId),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _sending
                      ? const SizedBox(
                          width: 32,
                          height: 32,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send),
                          onPressed: _send,
                          tooltip: 'Send',
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
