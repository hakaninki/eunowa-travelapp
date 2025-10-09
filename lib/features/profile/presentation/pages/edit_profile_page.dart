import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:travel_app/core/models/user_model.dart';
import 'package:travel_app/features/profile/providers/profile_stream_provider.dart';
import 'package:travel_app/features/profile/application/edit_profile_controller.dart';
import 'package:travel_app/core/constants/app_colors.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  final String uid; // kendi uid’in
  const EditProfilePage({super.key, required this.uid});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  File? _picked;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x != null) setState(() => _picked = File(x.path));
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userStreamProvider(widget.uid));
    final saving = ref.watch(editProfileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.appBarPeach,
        actions: [
          TextButton(
            onPressed: saving
                ? null
                : () async {
                    await ref.read(editProfileControllerProvider.notifier).submit(
                          username: _nameCtrl.text,
                          bio: _bioCtrl.text,
                          newPhotoFile: _picked,
                        );
                    if (mounted) Navigator.pop(context);
                  },
            child:  Text('Save', style: TextStyle(color: Colors.black,)),
          ),
        ],
      ),
      body: userAsync.when(
        data: (UserModel? u) {
          final user = u ??
              UserModel(
                id: FirebaseAuth.instance.currentUser!.uid,
                username: FirebaseAuth.instance.currentUser!.displayName,
                photoUrl: FirebaseAuth.instance.currentUser!.photoURL,
                bio: '',
              );

          // initial değerleri bir kez doldur
          _nameCtrl.text = _nameCtrl.text.isEmpty ? (user.username ?? '') : _nameCtrl.text;
          _bioCtrl.text = _bioCtrl.text.isEmpty ? (user.bio ?? '') : _bioCtrl.text;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: _picked != null
                          ? FileImage(_picked!)
                          : (user.photoUrl != null && user.photoUrl!.isNotEmpty)
                              ? NetworkImage(user.photoUrl!) as ImageProvider
                              : null,
                      child: (user.photoUrl == null || user.photoUrl!.isEmpty) && _picked == null
                          ? const Icon(Icons.person, size: 48)
                          : null,
                    ),
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: IconButton(
                        onPressed: _pick,
                        icon: const Icon(Icons.camera_alt),
                        color: Colors.black87,
                        style: IconButton.styleFrom(backgroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Username', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioCtrl,
                minLines: 2,
                maxLines: 5,
                decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              if (saving) const Center(child: CircularProgressIndicator()),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
