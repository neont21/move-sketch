import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../domain/models/social/social_auth_result.dart';
import '../../../domain/models/social/social_onboarding_profile.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../../utils/validators.dart';
import '../../core/widgets/labeled_text_form_field.dart';
import '../view_models/auth_viewmodel.dart';

class SocialOnboardingScreen extends ConsumerStatefulWidget {
  final SocialAuthNeedsOnboarding  initialData;

  const SocialOnboardingScreen({super.key, required this.initialData});

  @override
  ConsumerState<SocialOnboardingScreen> createState() =>
      _SocialOnboardingScreenState();
}

class _SocialOnboardingScreenState
    extends ConsumerState<SocialOnboardingScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _nicknameController;

  File? _selectedImageFile;
  bool _isPhotoRemoved = false;
  bool _isCheckingUsername = false;
  String? _usernameServerValidationError;

  @override
  void initState() {
    super.initState();

    _usernameController = TextEditingController();
    _nicknameController = TextEditingController(
      text: widget.initialData.defaultNickname ?? ''
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _nicknameController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _selectedImageFile = File(picked.path);
        _isPhotoRemoved = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImageFile = null;
      _isPhotoRemoved = true;
    });
  }

  void _showImageOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (bottomSheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('앨범에서 사진 선택'),
              onTap: () {
                bottomSheetContext.pop();
                _pickImage();
              },
            ),
            if (_selectedImageFile != null ||
                (!_isPhotoRemoved && widget.initialData.defaultPhotoUrl != null))
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('기본 이미지로 변경'),
                onTap: () {
                  bottomSheetContext.pop();
                  _removePhoto();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _usernameServerValidationError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final String username = _usernameController.text.trim().toLowerCase();

    setState(() {
      _isCheckingUsername = true;
    });

    final result = await ref
        .read(authViewModelProvider.notifier)
        .isUsernameAvailable(username);

    if (!mounted) {
      return;
    }

    setState(() {
      _isCheckingUsername = false;
    });

    switch (result) {
      case Ok(:final value):
        if (!value) {
          setState(() {
            _usernameServerValidationError = '이미 사용 중인 아이디입니다.';
          });

          _formKey.currentState?.validate();
          return;
        }

        final profileData = SocialOnboardingProfile(
          username: username,
          nickname: _nicknameController.text.trim(),
          imageFile: _selectedImageFile,
          socialPhotoUrl: _isPhotoRemoved
              ? null
              : widget.initialData.defaultPhotoUrl,
        );

        context.push(Routes.onboardingCharacter, extra: profileData);
      case Error(:final error):
        final ColorScheme colorScheme = Theme.of(context).colorScheme;
        final String errorMessage = error is AppException
            ? error.message
            : '아이디 확인 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Widget _buildAvatarPreview() {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    if (_selectedImageFile != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: FileImage(_selectedImageFile!),
      );
    }
    if (!_isPhotoRemoved && widget.initialData.defaultPhotoUrl != null) {
      return CircleAvatar(
        radius: 48,
        backgroundImage: NetworkImage(widget.initialData.defaultPhotoUrl!),
      );
    }
    return CircleAvatar(
      radius: 48,
      backgroundColor: colorScheme.surfaceContainer,
      child: Icon(Icons.person, size: 48, color: colorScheme.tertiaryContainer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) {
          await ref.read(authViewModelProvider.notifier).signOut();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('프로필 설정')),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAvatarPreview(),
                      GestureDetector(
                        onTap: _showImageOptions,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: colorScheme.primary,
                          child: Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('프로필 사진은 나중에도 변경할 수 있어요', style: textTheme.labelSmall),
                  const SizedBox(height: 24),
                  LabeledTextFormField(
                    controller: _usernameController,
                    labelText: '아이디',
                    hintText: '영문 소문자, 숫자, 밑줄 3~20자',
                    inputType: TextInputType.text,
                    validator: (value) {
                      if (_usernameServerValidationError != null) {
                        return _usernameServerValidationError;
                      }
                      return Validators.validateUsername(value);
                    },
                    onChanged: (_) {
                      if (_usernameServerValidationError != null) {
                        setState(() {
                          _usernameServerValidationError = null;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  LabeledTextFormField(
                    controller: _nicknameController,
                    labelText: '닉네임',
                    hintText: '10글자 이내로 작성',
                    inputType: TextInputType.text,
                    validator: Validators.validateNickname,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isCheckingUsername ? null : _handleSubmit,
                      child: _isCheckingUsername
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('다음'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
