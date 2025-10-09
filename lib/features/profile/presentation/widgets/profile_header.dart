// lib/features/profile/presentation/widgets/profile_header.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/chat/pages/chat_page.dart';
import 'package:travel_app/features/user/application/follow_controller.dart';
import 'package:travel_app/features/user/widgets/follow_button.dart';
import 'package:travel_app/features/user/pages/followers_page.dart';
import 'package:travel_app/features/user/pages/following_page.dart';
import 'package:travel_app/features/profile/providers/profile_stream_provider.dart';

class ProfileHeader extends ConsumerWidget {
  final UserModel user;
  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isOwnProfile = (currentUid != null && currentUid == user.id);

    final followersCount = ref.watch(followersCountStreamProvider(user.id));
    final followingCount = ref.watch(followingCountStreamProvider(user.id));
    final postsAsync = ref.watch(userPostsStreamProvider(user.id));
    final postsCount = postsAsync.whenData((list) => list.length);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;

        // basit breakpoint'ler
        final isNarrow = w < 360;
        final isMedium = w >= 360 && w < 520;

        // dinamik ölçüler
        final avatarRadius = isNarrow ? 44.0 : (isMedium ? 52.0 : 58.0);
        final nameSize = isNarrow ? 18.0 : 20.0;
        final numberSize = isNarrow ? 16.0 : 18.0;
        final labelSize = isNarrow ? 12.0 : 13.0;
        final bioMaxWidth =
            isNarrow ? (w - 32) : (avatarRadius * 2.2); // bio avatar altında

        Widget statBox(AsyncValue<int> count, String label, {VoidCallback? onTap}) {
          return Expanded(
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    count.when(
                      data: (v) => FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$v',
                          maxLines: 1,
                          overflow: TextOverflow.fade,
                          style: TextStyle(
                            fontSize: numberSize,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                      loading: () => const SizedBox(
                        width: 20, height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      error: (_, __) => FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '0',
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: numberSize,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: labelSize,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final bioText =
            (user.bio?.trim().isNotEmpty == true) ? user.bio!.trim() : 'No bio yet';

        // SOL BLOK: avatar + bio (bio avatarın altında, responsive genişlik)
        Widget leftBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: avatarRadius,
              backgroundImage: (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: (user.photoUrl == null || user.photoUrl!.isEmpty)
                  ? Icon(Icons.person, size: avatarRadius)
                  : null,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bioMaxWidth),
              child: Text(
                bioText,
                textAlign: TextAlign.center,
                maxLines: isNarrow ? 3 : 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          ],
        );

        // SAĞ BLOK: username + stats + buttons
        Widget rightBlock = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.username ?? 'user_${user.id.substring(0, 6)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: nameSize, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                statBox(postsCount, 'Posts'),
                statBox(
                  followersCount,
                  'Followers',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FollowersPage(userId: user.id),
                      ),
                    );
                  },
                ),
                statBox(
                  followingCount,
                  'Following',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => FollowingPage(userId: user.id),
                      ),
                    );
                  },
                ),
              ],
            ),
            if (!isOwnProfile) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    Expanded(child: FollowButton(targetUid: user.id)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatPage(otherUid: user.id),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Message'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );

        // DİZİLİM: dar ekranda dikey (avatar üstte), genişte yatay
        final content = isNarrow
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  leftBlock,
                  const SizedBox(height: 12),
                  rightBlock,
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  leftBlock,
                  const SizedBox(width: 20),
                  Expanded(child: rightBlock),
                ],
              );

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 16, 8, 8),
          child: content,
        );
      },
    );
  }
}
