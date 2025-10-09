// lib/features/post/presentation/pages/post_detail_page.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/home/widgets/post_card.dart';
import 'package:travel_app/features/post/presentation/pages/add_post_page.dart';
import 'package:travel_app/features/post/presentation/widgets/comments_section.dart';
import 'package:travel_app/features/post/presentation/widgets/comment_input_bar.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/app_colors.dart';

class PostDetailPage extends ConsumerWidget {
  final PostModel post;
  const PostDetailPage({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = FirebaseAuth.instance.currentUser;
    final isOwner = me != null && me.uid == post.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: AppColors.appBarPeach,
        actions: [
          if (isOwner)
            PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'edit') {
                  // Edit mode: AddPostPage with initialPost
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => AddPostPage(initialPost: post),
                  ));
                } else if (val == 'delete') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete Post'),
                      content: const Text('Are you sure you want to delete this post?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    await ref.read(postServiceProvider).deletePost(post.id);
                    if (context.mounted) {
                      Navigator.of(context).pop(); // detail’den çık
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Post deleted')),
                      );
                    }
                  }
                }
              },
              itemBuilder: (ctx) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // İçerik: scrollable
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  PostCard(post: post),
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('Comments',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 8),
                  CommentsSection(post: post),
                  const SizedBox(height: 80), // alttaki input için boşluk
                ],
              ),
            ),
            // Alt input bar (sabit)
            CommentInputBar(postId: post.id),
          ],
        ),
      ),
    );
  }
}
