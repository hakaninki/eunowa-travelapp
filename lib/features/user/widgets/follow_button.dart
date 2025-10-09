import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/user/application/follow_controller.dart';

class FollowButton extends ConsumerWidget {
  final String targetUid; // profil sahibinin uid'i
  const FollowButton({super.key, required this.targetUid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    // Kendi profilinde buton gösterme
    if (currentUid != null && currentUid == targetUid) {
      return const SizedBox.shrink();
    }

    final isFollowingAsync = ref.watch(isFollowingStreamProvider(targetUid));
    final toggle = ref.watch(followToggleProvider(targetUid));

    return isFollowingAsync.when(
      data: (isFollowing) => ElevatedButton(
        onPressed: () async {
          try {
            await toggle();
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed: $e')),
              );
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.grey.shade300 : const Color(0xFFF09245),
          foregroundColor: isFollowing ? Colors.black87 : Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(isFollowing ? 'Following' : 'Follow'),
      ),
      loading: () => const SizedBox(
        width: 80, height: 36, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
      error: (e, _) => Text('Err: $e', style: const TextStyle(color: Colors.red)),
    );
  }
}

