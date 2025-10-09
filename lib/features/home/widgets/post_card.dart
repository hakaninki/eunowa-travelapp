import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/features/home/widgets/post_card_components/location_info.dart';
import 'package:travel_app/features/home/widgets/post_card_components/post_actions_info.dart';
import 'package:travel_app/features/home/widgets/post_card_components/post_description.dart';
import 'package:travel_app/features/home/widgets/post_card_components/user_info.dart';
import 'package:travel_app/core/models/post_model.dart';

class PostCard extends StatelessWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20),
      child: Material(
        elevation: 3.0,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 Kullanıcı
              UserInfoRow(
                uid: post.uid,
                fallbackUsername: post.username,
              ),
              const SizedBox(height: 5),

              // 📍 Konum
              LocationInfoRow(location: post.location),
              const SizedBox(height: 5),

              // 🖼 Görsel (cached + skeleton)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.zero),
                child: CachedNetworkImage(
                  imageUrl: post.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => const AspectRatio(
                    aspectRatio: 4 / 3,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                  errorWidget: (context, url, error) => const AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Center(child: Icon(Icons.broken_image)),
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // ✍️ Açıklama
              PostDescription(description: post.description),
              const SizedBox(height: 10),

              // ❤️💬 Etkileşim ikonları
              PostActionsInfo(postId: post.id),
            ],
          ),
        ),
      ),
    );
  }
}
