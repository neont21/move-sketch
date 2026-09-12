import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChangeCharacterPage extends StatefulWidget {
  const ChangeCharacterPage({super.key});

  @override
  State<ChangeCharacterPage> createState() => _ChangeCharacterPageState();
}

class _ChangeCharacterPageState extends State<ChangeCharacterPage> {
  final List<String> _characters = ['곰', '판다', '고양이', '강아지', '토끼', '카피바라'];
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('내 캐릭터'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('캐릭터를 변경하면 다음 세션부터 반영되요.', style: textTheme.bodyMedium),
            Divider(color: Colors.transparent),
            Expanded(
              child: GridView.builder(
                itemCount: _characters.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 5,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selected = index;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '캐릭터 변경 완료: ${_characters[_selected]}',
                          ),
                          duration: Duration(seconds: 3),
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
                                  // child: Image(
                                  //   image: AssetImage(
                                  //     'assets/character/${_characters[index]}.png',
                                  //   ),
                                  //   fit: BoxFit.cover,
                                  // ),
                                  child: Image(
                                    image: AssetImage(
                                      'assets/default_profile.png',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              _characters[index],
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
