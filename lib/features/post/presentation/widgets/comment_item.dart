import 'package:flutter/material.dart';
import 'package:travel_app/core/models/comment_model.dart';

class CommentItem extends StatelessWidget {
  final CommentModel comment;
  final VoidCallback? onDelete; // kendi yorumunsa silme için

  const CommentItem({
    super.key,
    required this.comment,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: (comment.photoUrl != null && comment.photoUrl!.isNotEmpty)
            ? NetworkImage(comment.photoUrl!)
            : null,
        child: (comment.photoUrl == null || comment.photoUrl!.isEmpty)
            ? const Icon(Icons.person)
            : null,
      ),
      title: Text(comment.username),
      subtitle: Text(comment.text),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete',
            )
          : null,
    );
  }
}
