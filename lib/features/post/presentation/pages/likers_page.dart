import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';
import 'package:travel_app/features/user/services/user_service.dart'
    as u; // path seninkine göre düzelt
import 'package:travel_app/core/constants/app_colors.dart';

class LikersPage extends ConsumerStatefulWidget {
  final String postId;
  const LikersPage({super.key, required this.postId});

  @override
  ConsumerState<LikersPage> createState() => _LikersPageState();
}

class _LikersPageState extends ConsumerState<LikersPage> {
  bool _loading = false;
  bool _hasMore = true;
  final List<UserModel> _likers = [];

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    final likeSvc = ref.read(likeServiceProvider);
    final userSvc = u.UserService();

    final ids = await likeSvc.getLikerIds(postId: widget.postId, limit: 30);
    if (ids.isEmpty) {
      setState(() {
        _hasMore = false;
        _loading = false;
      });
      return;
    }

    final profiles = await userSvc.getUsersByIds(ids);

    setState(() {
      _likers.addAll(profiles);
      _loading = false;
      if (ids.length < 30) _hasMore = false;
    });
  }

  void _openProfile(String userId) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ProfilePage(userId: userId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked by'),
        backgroundColor: AppColors.appBarPeach,
      ),
      body: ListView.separated(
        itemCount: _likers.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == _likers.length) {
            if (!_hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No more')),
              );
            }
            _loadMore();
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final userItem = _likers[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage:
                  (userItem.photoUrl != null && userItem.photoUrl!.isNotEmpty)
                  ? NetworkImage(userItem.photoUrl!)
                  : null,
              child: (userItem.photoUrl == null || userItem.photoUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(userItem.username ?? 'user'),
            onTap: () => _openProfile(userItem.id),
          );
        },
      ),
    );
  }
}
