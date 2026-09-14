import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/dialog_action_buttons.dart';
import '../widgets/labeled_text_form_field.dart';
import '../models/mock_user.dart';

class ModifyProfileDialog extends StatefulWidget {
  const ModifyProfileDialog({super.key});

  @override
  State<ModifyProfileDialog> createState() => _ModifyProfileDialogState();
}

class _ModifyProfileDialogState extends State<ModifyProfileDialog> {
  final MockUser user = MockUser(
    id: '@daniil_a_np',
    name: '다닐루쉬카',
    description: '가댜가댜',
  );

  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  ImageProvider? _previewImage;

  Future<void> _pickImage() async {
    try {
      _pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (_pickedImage != null) {
        setState(() {
          _previewImage = FileImage(File(_pickedImage!.path));
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  List<ListTile> _buildBottomDialogSheet(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    List<ListTile> menuItems = [];

    menuItems.add(
      ListTile(
        title: Row(
          spacing: 12,
          children: [
            Icon(Icons.pets),
            Text('내 캐릭터로 설정', style: textTheme.bodyLarge),
          ],
        ),
        onTap: () {
          context.pop();
          // TODO implement
        },
      ),
    );
    menuItems.add(
      ListTile(
        title: Row(
          spacing: 12,
          children: [
            Icon(Icons.image_outlined),
            Text('갤러리에서 선택', style: textTheme.bodyLarge),
          ],
        ),
        onTap: () {
          context.pop();
          // TODO implement
          _pickImage();
        },
      ),
    );
    menuItems.add(
      ListTile(
        title: Row(
          spacing: 12,
          children: [
            Icon(Icons.refresh),
            Text('기본 이미지로 설정', style: textTheme.bodyLarge),
          ],
        ),
        onTap: () {
          context.pop();
          // TODO implement
        },
      ),
    );

    return menuItems;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('프로필 편집', style: textTheme.headlineSmall),
            Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundImage: _pickedImage != null
                      ? _previewImage
                      : user.imageURL != null
                      ? NetworkImage(user.imageURL!)
                      : AssetImage('assets/default_profile.png'),
                ),
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
                        // TODO 프로필 사진 변경
                        showModalBottomSheet(
                          context: context,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadiusGeometry.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          builder: (context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: _buildBottomDialogSheet(context),
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
                  initialValue: user.name,
                  maxLength: 10,
                ),
                LabeledTextFormField(
                  labelText: '한 줄 소개',
                  hintText: '나에 대한 짧은 소개를 작성해 보아요',
                  initialValue: user.description,
                  maxLength: 30,
                ),
              ],
            ),
            DialogActionButtons(
              confirmText: '저장',
              onConfirm: () {
                // TODO: form 내용 반영
                context.pop();
                // FIXME: 변동사항이 있을 경우에만
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('프로필이 수정되었습니다.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
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
