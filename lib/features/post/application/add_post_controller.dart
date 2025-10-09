import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:travel_app/core/constants/app_collection.dart';
import 'package:travel_app/features/post/application/add_post_state.dart';
import 'package:travel_app/features/post/providers/post_provider.dart';
import 'package:travel_app/core/models/post_model.dart';

class AddPostController extends StateNotifier<AddPostState> {
  AddPostController(this._ref) : super(const AddPostState.initial());

  final Ref _ref;

  // ------- setters -------
  void setImage(File? img) => state = state.copyWith(image: img, error: '');
  void setDescription(String v) => state = state.copyWith(description: v, error: '');
  void setLocation(String v) => state = state.copyWith(location: v, error: '');
  void setLatLng(double? lat, double? lng) =>
      state = state.copyWith(lat: lat, lng: lng, error: '');

  /// ✅ dışarıdan formu sıfırlamak için
  void reset() => state = const AddPostState.initial();

  /// ✅ Edit modunda formu bir post ile doldur
  void hydrateFrom(PostModel p) {
    state = state.copyWith(
      description: p.description,
      location: p.location,
      lat: p.lat,
      lng: p.lng,
      error: '',
    );
  }

  // ------- submit (create) -------
  Future<bool> submit() async {
    if (state.image == null) {
      state = state.copyWith(error: 'Please select an image');
      return false;
    }
    if (state.description.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a description');
      return false;
    }

    try {
      state = state.copyWith(isLoading: true, error: '');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        state = state.copyWith(isLoading: false, error: 'Not signed in');
        return false;
      }

      String username = user.displayName ?? (user.email ?? 'user');
      try {
        final snap = await FirebaseFirestore.instance
            .collection(AppCollections.users)
            .doc(user.uid)
            .get();
        final m = snap.data();
        if (m != null && (m['username'] is String) && (m['username'] as String).trim().isNotEmpty) {
          username = (m['username'] as String).trim();
        }
      } catch (_) {/* ignore */ }

      final postService = _ref.read(postServiceProvider);

      await postService.createPost(
        imageFile: state.image!,
        uid: user.uid,
        username: username,
        description: state.description.trim(),
        location: state.location.trim(),
        lat: state.lat,
        lng: state.lng,
      );

      state = const AddPostState.initial();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to post: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// ------- submit (edit) -------
  Future<bool> submitEdit(PostModel post) async {
    if (state.description.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a description');
      return false;
    }
    try {
      state = state.copyWith(isLoading: true, error: '');
      final postService = _ref.read(postServiceProvider);

      await postService.updatePost(
        postId: post.id,
        description: state.description.trim(),
        location: state.location.trim(),
        lat: state.lat,
        lng: state.lng,
      );

      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to update: $e');
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

// Riverpod provider
final addPostControllerProvider =
    StateNotifierProvider<AddPostController, AddPostState>((ref) {
  return AddPostController(ref);
});
