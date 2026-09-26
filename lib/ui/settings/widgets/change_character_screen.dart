import 'package:flutter/material.dart';

import '../../../config/assets.dart';
import '../../../domain/models/enums/character_type.dart';

class ChangeCharacterScreen extends StatefulWidget {
  const ChangeCharacterScreen({super.key});

  @override
  State<ChangeCharacterScreen> createState() => _ChangeCharacterScreenState();
}

class _ChangeCharacterScreenState extends State<ChangeCharacterScreen> {
  final List<CharacterType> _characters = CharacterType.values;
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('내 캐릭터')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('캐릭터를 변경하면 다음 세션부터 반영되요.', style: textTheme.bodyMedium),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: _characters.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5,
                ),
                itemBuilder: (context, index) {
                  final character = _characters[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selected = index;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('캐릭터 변경 완료: ${character.label}'),
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(20),
                        side: BorderSide(
                          color: _selected == index
                              ? colorScheme.primary
                              : colorScheme.outline,
                          width: _selected == index ? 2 : 1,
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
                                color: _selected == index
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
