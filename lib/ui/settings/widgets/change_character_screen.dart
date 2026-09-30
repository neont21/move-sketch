import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/assets.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/enums/character_type.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';

class ChangeCharacterScreen extends ConsumerStatefulWidget {
  const ChangeCharacterScreen({super.key});

  @override
  ConsumerState<ChangeCharacterScreen> createState() =>
      _ChangeCharacterScreenState();
}

class _ChangeCharacterScreenState extends ConsumerState<ChangeCharacterScreen> {
  final List<CharacterType> _characters = CharacterType.values;
  bool _isSaving = false;

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

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final currentUser = ref.watch(currentUserProvider);
    final currentCharacter =
        currentUser?.selectedCharacter ?? CharacterType.bear;

    return Scaffold(
      appBar: AppBar(title: Text('내 캐릭터')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('캐릭터를 변경하면 다음 세션부터 반영돼요.', style: textTheme.bodyMedium),
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
                  final bool isSelected = character == currentCharacter;

                  return GestureDetector(
                    onTap: _isSaving ? null : () => _handleSelect(character),
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
          ],
        ),
      ),
    );
  }
}
