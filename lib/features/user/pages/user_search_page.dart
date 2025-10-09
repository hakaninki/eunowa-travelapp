import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/features/user/providers/user_search_provider.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';

class UserSearchPage extends ConsumerWidget {
  const UserSearchPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = ref.watch(userSearchQueryProvider);
    final resultsAsync = ref.watch(userSearchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search users',
            border: InputBorder.none,
          ),
          onChanged: (v) => ref.read(userSearchQueryProvider.notifier).state = v,
        ),
      ),
      body: resultsAsync.when(
        data: (users) {
          if (q.trim().length < 2) {
            return const Center(child: Text('Type at least 2 characters'));
          }
          if (users.isEmpty) {
            return const Center(child: Text('No users found'));
          }
          return ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (ctx, i) {
              final u = users[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      (u.photoUrl != null && u.photoUrl!.isNotEmpty)
                          ? NetworkImage(u.photoUrl!)
                          : null,
                  child: (u.photoUrl == null || u.photoUrl!.isEmpty)
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Text(u.username ?? 'user_${u.id.substring(0,6)}',
                    overflow: TextOverflow.ellipsis),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProfilePage(userId: u.id)),
                  );
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
