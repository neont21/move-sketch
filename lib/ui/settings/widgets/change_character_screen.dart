import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/assets.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../domain/models/social/social_onboarding_profile.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

class ChangeCharacterScreen extends ConsumerStatefulWidget {
  final SocialOnboardingProfile? onboardingProfile;

  const ChangeCharacterScreen({super.key, this.onboardingProfile});

  @override
  ConsumerState<ChangeCharacterScreen> createState() =>
      _ChangeCharacterScreenState();
}

class _ChangeCharacterScreenState extends ConsumerState<ChangeCharacterScreen> {
  final List<CharacterType> _characters = CharacterType.values;
  late CharacterType _selectedCharacter;
  bool _isSaving = false;

  bool get _isOnboarding => widget.onboardingProfile != null;

  @override
  void initState() {
    super.initState();

    _selectedCharacter = CharacterType.bear;
  }

  Future<void> _handleSelect(CharacterType selectedCharacter) async {
    if (_isSaving) {
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser?.selectedCharacter == selectedCharacter) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final userRepository = ref.read(userRepositoryProvider);
    final result = await userRepository.updateCharacter(selectedCharacter);

    if (!mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    switch (result) {
      case Ok():
        await ref.read(authViewModelProvider.notifier).refreshCurrentUser();

        if (!mounted) {
          return;
        }

        setState(() {
          _isSaving = false;
        });

        messenger.showSnackBar(
          SnackBar(content: Text('${selectedCharacter.label} 캐릭터로 변경되었습니다.')),
        );
      case Error(:final error):
        setState(() {
          _isSaving = false;
        });
        final errorMessage = error is AppException
            ? error.message
            : '캐릭터 변경 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleOnboarding() async {
    if (_isSaving) {
      return;
    }

    final onboardingProfile = widget.onboardingProfile;
    if (onboardingProfile == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(authViewModelProvider.notifier)
        .completeSocialSignUp(
          username: onboardingProfile.username,
          nickname: onboardingProfile.nickname,
          selectedCharacter: _selectedCharacter,
          imageFile: onboardingProfile.imageFile,
          profileImageUrl: onboardingProfile.socialPhotoUrl,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    switch (result) {
      case Ok():
        context.go(Routes.home);
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '프로필 설정 완료 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final currentUser = ref.watch(currentUserProvider);
    final CharacterType activeCharacter = _isOnboarding
        ? _selectedCharacter
        : (currentUser?.selectedCharacter ?? CharacterType.bear);

    return Scaffold(
      appBar: AppBar(title: Text(_isOnboarding ? '캐릭터 선택' : '내 캐릭터')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isOnboarding
                  ? '무브스케치와 함께 달릴 러닝 메이트를 골라주세요!'
                  : '캐릭터를 변경하면 다음 세션부터 반영돼요.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _characters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final character = _characters[index];
                  final bool isSelected = character == activeCharacter;

                  return GestureDetector(
                    onTap: () {
                      if (_isOnboarding) {
                        setState(() => _selectedCharacter = character);
                      } else {
                        _handleSelect(character);
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          spacing: 20,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image(
                                    image: AssetImage(
                                      character.defaultImagePath,
                                    ),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const Image(
                                      image: AssetImage(Assets.sampleSketch),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              character.label,
                              style: textTheme.bodyMedium?.copyWith(
                                color: isSelected
                                    ? colorScheme.primary
                                    : colorScheme.tertiaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isOnboarding) ...[
              const SizedBox(height: 16),
              SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleOnboarding,
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('시작하기'),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
