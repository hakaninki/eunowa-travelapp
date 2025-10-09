import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/core/models/post_model.dart';

/// Basit sayfalı durum
@immutable
class PagedPostsState {
  final List<PostModel> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool isLoading;
  final bool hasMore;
  final Object? error;

  const PagedPostsState({
    this.items = const [],
    this.lastDoc,
    this.isLoading = false,
    this.hasMore = true,
    this.error,
  });

  PagedPostsState copyWith({
    List<PostModel>? items,
    DocumentSnapshot<Map<String, dynamic>>? lastDoc,
    bool? isLoading,
    bool? hasMore,
    Object? error,
  }) {
    return PagedPostsState(
      items: items ?? this.items,
      lastDoc: lastDoc ?? this.lastDoc,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class PagedPostsNotifier extends StateNotifier<PagedPostsState> {
  PagedPostsNotifier() : super(const PagedPostsState());

  static const int _pageSize = 12;
  final _db = FirebaseFirestore.instance;

  /// İlk sayfa
  Future<void> fetchFirstPage() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final query = _db
          .collection(AppCollections.posts) // "posts"
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      final snap = await query.get();
      final docs = snap.docs;

      final items = docs.map(_toPostModel).toList();
      state = state.copyWith(
        items: items,
        lastDoc: docs.isNotEmpty ? docs.last : null,
        hasMore: docs.length == _pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  /// Sonraki sayfa
  Future<void> fetchNextPage() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      Query<Map<String, dynamic>> query = _db
          .collection(AppCollections.posts)
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      final startAfter = state.lastDoc;
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snap = await query.get();
      final docs = snap.docs;
      final newItems = docs.map(_toPostModel).toList();

      state = state.copyWith(
        items: [...state.items, ...newItems],
        lastDoc: docs.isNotEmpty ? docs.last : state.lastDoc,
        hasMore: docs.length == _pageSize,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> refresh() async {
    state = const PagedPostsState();
    await fetchFirstPage();
  }

  /// Senin PostModel.fromMap yapına uygun mapping:
  PostModel _toPostModel(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = Map<String, dynamic>.from(doc.data());
    // PostModel.fromMap 'id' bekliyor, doc.id'yi enjekte ediyoruz:
    data['id'] = doc.id;
    return PostModel.fromMap(data);
  }
}

final pagedPostsProvider =
    StateNotifierProvider<PagedPostsNotifier, PagedPostsState>(
  (ref) => PagedPostsNotifier(),
);
