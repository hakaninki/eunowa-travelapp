import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:travel_app/core/models/post_model.dart';
import 'package:travel_app/features/post/application/add_post_state.dart';
import 'package:travel_app/features/post/presentation/widgets/image_picker_field.dart';
import 'package:travel_app/features/post/presentation/widgets/description_field.dart';
import 'package:travel_app/features/post/presentation/widgets/location_field.dart';
import 'package:travel_app/features/main/providers/nav_provider.dart';
import 'package:travel_app/features/post/application/add_post_controller.dart';
import 'package:travel_app/core/constants/app_colors.dart';
class AddPostPage extends ConsumerStatefulWidget {
  final PostModel? initialPost;
  const AddPostPage({super.key, this.initialPost});

  @override
  ConsumerState<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends ConsumerState<AddPostPage> {
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    // 🔧 Provider'ı lifecycle içinde DEĞİL, first frame'den sonra değiştir.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final p = widget.initialPost;
      if (p != null && !_hydrated) {
        ref.read(addPostControllerProvider.notifier).hydrateFrom(p);
        setState(() => _hydrated = true);
      }
    });
  }

  @override
  void dispose() {
    // Form state bulaşmasın
    ref.read(addPostControllerProvider.notifier).reset();
    super.dispose();
  }

  Future<void> _pick(WidgetRef ref) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked != null) {
      ref.read(addPostControllerProvider.notifier).setImage(File(picked.path));
    }
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final controller = ref.read(addPostControllerProvider.notifier);
    final ok = widget.initialPost == null
        ? await controller.submit()
        : await controller.submitEdit(widget.initialPost!);

    final st = ref.read(addPostControllerProvider);
    if (!mounted) return;

    if (ok) {
      if (widget.initialPost == null) {
        ref.read(navIndexProvider.notifier).state = 0;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Posted ✅')));
      } else {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Post updated ✅')));
      }
    } else if (st.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(st.error!)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final AddPostState st = ref.watch(addPostControllerProvider);

    final isEdit = widget.initialPost != null;
    final canPublish = !st.isLoading &&
        (isEdit
            ? st.description.trim().isNotEmpty
            : (st.image != null && st.description.trim().isNotEmpty));

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Post' : 'New Post'),
        backgroundColor: AppColors.appBarPeach,
        actions: [
          TextButton(
            onPressed: canPublish ? () => _submit(context, ref) : null,
            child: Text(isEdit ? 'Save' : 'Publish',
                style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Edit modunda resmi şimdilik değiştirmiyoruz
          if (!isEdit)
            ImagePickerField(
              image: st.image,
              onPick: () => _pick(ref),
              onClear: () =>
                  ref.read(addPostControllerProvider.notifier).setImage(null),
            ),
          if (!isEdit) const SizedBox(height: 16),
          DescriptionField(
            initial: st.description,
            onChanged: (v) =>
                ref.read(addPostControllerProvider.notifier).setDescription(v),
          ),
          const SizedBox(height: 12),
          LocationField(
            initial: st.location,
            onChanged: (v) =>
                ref.read(addPostControllerProvider.notifier).setLocation(v),
            onPlaceSelected:
                ({required String label, double? lat, double? lng}) {
              ref.read(addPostControllerProvider.notifier).setLocation(label);
              ref.read(addPostControllerProvider.notifier).setLatLng(lat, lng);
            },
          ),
          const SizedBox(height: 24),
          if (st.isLoading) const Center(child: CircularProgressIndicator()),
          if (st.error != null) ...[
            const SizedBox(height: 12),
            Text(
              st.error!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
