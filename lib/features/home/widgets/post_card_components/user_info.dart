import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/user/providers/user_provider.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';

class UserInfoRow extends ConsumerWidget {
  final String uid;
  final String fallbackUsername; // post'tan gelen username

  const UserInfoRow({
    super.key,
    required this.uid,
    required this.fallbackUsername,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(uid));

    return userAsync.when(
      data: (user) {
        final username = user?.username ?? fallbackUsername;
        final photoUrl = user?.photoUrl;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(userId: uid),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                      ? NetworkImage(photoUrl)
                      : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                const SizedBox(width: 10),
                Text(
                  username,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          children: [
            CircleAvatar(radius: 25, backgroundColor: Colors.grey),
            SizedBox(width: 10),
            Text("Loading..."),
          ],
        ),
      ),
      error: (_, __) => const SizedBox(),
    );
  }
}
