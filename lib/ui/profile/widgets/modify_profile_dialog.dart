import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/social/user.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../../core/widgets/dialog_action_buttons.dart';
import '../../core/widgets/labeled_text_form_field.dart';
import '../../core/widgets/user_avatar.dart';
import '../../feed/view_models/feed_viewmodel.dart';

class ModifyProfileDialog extends ConsumerStatefulWidget {
  final User user;

  const ModifyProfileDialog({super.key, required this.user});

  @override
  ConsumerState<ModifyProfileDialog> createState() =>
      _ModifyProfileDialogState();
}

class _ModifyProfileDialogState extends ConsumerState<ModifyProfileDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _nicknameController;
  late final TextEditingController _descriptionController;

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  bool _resetToDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nicknameController = TextEditingController(text: widget.user.nickname);
    _descriptionController = TextEditingController(
      text: widget.user.description ?? '',
    );
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _pickedImage = picked;
          _resetToDefault = false;
        });
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이미지를 불러오지 못했습니다. 다시 시도해 주세요.')),
      );
    }
  }

  List<ListTile> _buildBottomDialogSheet() {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return [
      ListTile(
        title: Row(
          children: [
            const Icon(Icons.image_outlined),
            const SizedBox(width: 12),
            Text('갤러리에서 선택', style: textTheme.bodyLarge),
          ],
        ),
        onTap: () {
          context.pop();
          _pickImage();
        },
      ),
      ListTile(
        title: Row(
          children: [
            const Icon(Icons.refresh),
            const SizedBox(width: 12),
            Text('기본 이미지로 설정', style: textTheme.bodyLarge),
          ],
        ),
        onTap: () {
          context.pop();
          setState(() {
            _pickedImage = null;
            _resetToDefault = true;
          });
        },
      ),
    ];
  }

  void _handleSave() async {
    if (_isSaving || !_formKey.currentState!.validate()) {
      return;
    }

    final trimmedNickname = _nicknameController.text.trim();
    final trimmedDescription = _descriptionController.text.trim();

    setState(() {
      _isSaving = true;
    });

    final userRepository = ref.read(userRepositoryProvider);
    final File? imageFileToUpload = _pickedImage != null
        ? File(_pickedImage!.path)
        : null;

    final result = await userRepository.updateUserProfile(
      nickname: trimmedNickname.isNotEmpty
          ? trimmedNickname
          : widget.user.nickname,
      description: trimmedDescription,
      imageUrl: _resetToDefault ? '' : null,
      imageFile: imageFileToUpload,
    );

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();
        ref.invalidate(feedViewModelProvider);

        if (!mounted) {
          return;
        }

        setState(() {
          _isSaving = false;
        });

        context.pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('프로필이 수정되었습니다.')));
      case Error(:final error):
        setState(() {
          _isSaving = false;
        });

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is AppException ? error.message : '프로필 수정 중 오류가 발생했습니다.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    Widget avatarWidget;
    if (_pickedImage != null) {
      avatarWidget = ClipOval(
        child: Image.file(
          File(_pickedImage!.path),
          width: 72,
          height: 72,
          fit: BoxFit.cover,
        ),
      );
    } else {
      avatarWidget = UserAvatar(
        username: widget.user.username,
        imageUrl: _resetToDefault ? null : widget.user.imageUrl,
        radius: 36,
      );
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('프로필 편집', style: textTheme.headlineSmall),
            Stack(
              children: [
                avatarWidget,
                Positioned(
                  top: 48,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: colorScheme.surface, width: 2),
                    ),
                    width: 24,
                    height: 24,
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _buildBottomDialogSheet(),
                              ),
                            );
                          },
                        );
                      },
                      icon: Icon(Icons.camera_alt_outlined),
                      iconSize: 14,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      style: IconButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Column(
              spacing: 20,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LabeledTextFormField(
                  labelText: '닉네임',
                  hintText: '닉네임은 10자 이내로 정해주세요',
                  controller: _nicknameController,
                  textInputAction: TextInputAction.next,
                  maxLength: 10,
                ),
                LabeledTextFormField(
                  labelText: '한 줄 소개',
                  hintText: '나에 대한 짧은 소개를 작성해 보아요',
                  controller: _descriptionController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) => _handleSave(),
                  maxLength: 30,
                ),
              ],
            ),
            DialogActionButtons(
              confirmText: _isSaving ? '저장 중...' : '저장',
              onConfirm: _isSaving ? () {} : _handleSave,
              onCancel: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
