import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/features/home/widgets/search_bar.dart';
import 'package:travel_app/features/chat/pages/chat_list_page.dart';
import 'package:travel_app/features/chat/providers/chat_providers.dart';
import 'package:travel_app/core/constants/app_colors.dart';

class HomeSliverAppBar extends ConsumerWidget {
  const HomeSliverAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = ref.watch(unreadTotalProvider);
    final unread = unreadAsync.maybeWhen(data: (v) => v, orElse: () => 0);

    return SliverAppBar(
      backgroundColor: AppColors.appBarPeach,
      expandedHeight: 120, // arka plan görseli sadece appbar alanında
      floating: true,
      snap: true,
      pinned: true,
      centerTitle: false,
      titleSpacing: 12,
      flexibleSpace: FlexibleSpaceBar(
        background: Image.asset(
          "images/splash5.png",
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
      // Solda EUNOWA, ortada kompakt arama
      title: Row(
        children: const [
          Text("EUNOWA", style: TextStyle(color: Colors.black)),
          SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 36,
              child: ExploreBarCompact(),
            ),
          ),
        ],
      ),
      // Sağda mesajlar ikonu + unread rozeti
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Badge( // Flutter 3.7+; daha eski sürümde Stack ile mini rozet yapabilirsiniz.
            isLabelVisible: unread > 0,
            label: Text('$unread'),
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChatListPage()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    CupertinoIcons.chat_bubble_2_fill,
                    size: 22,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
