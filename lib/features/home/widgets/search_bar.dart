import 'package:flutter/material.dart';
import 'package:travel_app/features/user/pages/user_search_page.dart';

class ExploreBar extends StatelessWidget {
  const ExploreBar({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: () => _openSearch(context),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "Search users",
                    style: TextStyle(
                      color: Color.fromARGB(143, 160, 84, 84),
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.travel_explore_outlined,
                  color: Color.fromARGB(143, 160, 84, 84),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// AppBar içine sığan kompakt versiyon
class ExploreBarCompact extends StatelessWidget {
  const ExploreBarCompact({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserSearchPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(18),
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openSearch(context),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.search, size: 18, color: Colors.black54),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Search users",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
