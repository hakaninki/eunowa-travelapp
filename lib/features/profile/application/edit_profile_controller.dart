import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/features/user/services/user_service.dart';
import 'package:travel_app/features/post/providers/post_provider.dart'; // cloudinaryServiceProvider

class EditProfileController extends StateNotifier<AsyncValue<void>> {
  EditProfileController(this._ref) : super(const AsyncData(null));
  final Ref _ref;

  Future<void> submit({
    required String username,
    required String bio,
    File? newPhotoFile,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      state = AsyncError('Not signed in', StackTrace.current);
      return;
    }

    state = const AsyncLoading();
    try {
      String? photoUrl;

      if (newPhotoFile != null) {
        final cloud = _ref.read(cloudinaryServiceProvider);
        photoUrl = await cloud.uploadImage(newPhotoFile);
      }

      await UserService().updateProfile(
        uid: user.uid,
        username: username.trim().isEmpty ? null : username.trim(),
        bio: bio.trim(),
        photoUrl: photoUrl,
      );

      // displayName’i de güncelle (opsiyonel)
      if (username.trim().isNotEmpty) {
        await user.updateDisplayName(username.trim());
      }

      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final editProfileControllerProvider =
    StateNotifierProvider<EditProfileController, AsyncValue<void>>(
  (ref) => EditProfileController(ref),
);
