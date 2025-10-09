import 'package:flutter/material.dart';
import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/home/widgets/post_card.dart';
import 'package:travel_app/features/post/presentation/pages/post_detail_page.dart';

class TappablePostCard extends StatelessWidget {
  final PostModel post;
  const TappablePostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PostDetailPage(post: post)),
        );
      },
      child: PostCard(post: post),
    );
  }
}
