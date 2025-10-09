import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/user/services/user_service.dart';
import 'package:travel_app/features/profile/pages/profile_page.dart';

class FollowersPage extends ConsumerStatefulWidget {
  final String userId; // profil sahibinin uid'i
  const FollowersPage({super.key, required this.userId});

  @override
  ConsumerState<FollowersPage> createState() => _FollowersPageState();
}

class _FollowersPageState extends ConsumerState<FollowersPage> {
  final _users = <UserModel>[];
  bool _loading = false;
  bool _hasMore = true;
  DocumentSnapshot? _last;

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    Query<Map<String, dynamic>> q = FirebaseFirestore.instance
        .collection(AppCollections.users)
        .doc(widget.userId)
        .collection(AppCollections.followers)
        .orderBy('createdAt', descending: true)
        .limit(30);

    if (_last != null) q = q.startAfterDocument(_last!);

    final snap = await q.get();
    if (snap.docs.isEmpty) {
      setState(() {
        _hasMore = false;
        _loading = false;
      });
      return;
    }

    _last = snap.docs.last;
    final ids = snap.docs.map((d) => d.id).toList();
    final profiles = await UserService().getUsersByIds(ids);

    setState(() {
      _users.addAll(profiles);
      _loading = false;
      if (snap.docs.length < 30) _hasMore = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Followers')),
      body: ListView.separated(
        itemCount: _users.length + 1,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          if (index == _users.length) {
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

          final u = _users[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: (u.photoUrl != null && u.photoUrl!.isNotEmpty)
                  ? NetworkImage(u.photoUrl!)
                  : null,
              child: (u.photoUrl == null || u.photoUrl!.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(u.username ?? 'user_${u.id.substring(0, 6)}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => ProfilePage(userId: u.id)),
              );
            },
          );
        },
      ),
    );
  }
}
