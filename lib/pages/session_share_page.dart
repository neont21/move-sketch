import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/sketch_card.dart';

class SessionSharePage extends StatefulWidget {
  final String _sessionId;
  final bool _edit;
  const SessionSharePage({
    super.key,
    required this._sessionId,
    this._edit = false,
  });

  @override
  State<SessionSharePage> createState() => _SessionSharePageState();
}

class _SessionSharePageState extends State<SessionSharePage> {
  int _selectedTag = 0;
  final List<String> _locationTags = ['동대문구 휘경동', '동대문구 전농동', '성동구 용답동'];

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
        title: Text(widget._edit ? '수정하기' : '피드에 올리기'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO implement save
              if (GoRouterState.of(context).uri.path.startsWith('/me')) {
                context.go('/me/post/${widget._sessionId}');
              } else {
                context.go('/feed/post/${widget._sessionId}');
              }
            },
            icon: Icon(Icons.check),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              spacing: 20,
              children: [
                SketchCard(
                  imageProvider: AssetImage('assets/sample_sketch.png'),
                ),
                Text(
                  '위치 태그 선택',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
                AnimatedToggleSwitch<int>.size(
                  current: _selectedTag,
                  values: const [0, 1, 2],
                  onChanged: (i) {
                    setState(() {
                      _selectedTag = i;
                    });
                  },
                  selectedIconScale: 1.0,
                  height: 40,
                  indicatorSize: const Size(80, 32),
                  style: ToggleStyle(
                    backgroundColor: colorScheme.outline,
                    borderColor: colorScheme.outline,
                    indicatorColor: colorScheme.primary,
                    borderRadius: BorderRadius.circular(80),
                  ),
                  borderWidth: 4,
                  iconBuilder: (value) {
                    switch (value) {
                      case 0:
                        return Center(
                          child: Text(
                            '출발지',
                            style: textTheme.bodyLarge?.copyWith(
                              color: (value == _selectedTag)
                                  ? colorScheme.onPrimary
                                  : colorScheme.tertiaryFixed,
                            ),
                          ),
                        );
                      case 1:
                        return Center(
                          child: Text(
                            '경유지',
                            style: textTheme.bodyLarge?.copyWith(
                              color: (value == _selectedTag)
                                  ? colorScheme.onPrimary
                                  : colorScheme.tertiaryFixed,
                            ),
                          ),
                        );
                      case 2:
                        return Center(
                          child: Text(
                            '도착지',
                            style: textTheme.bodyLarge?.copyWith(
                              color: (value == _selectedTag)
                                  ? colorScheme.onPrimary
                                  : colorScheme.tertiaryFixed,
                            ),
                          ),
                        );
                      default:
                        return Center(child: Text('error'));
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_pin, color: colorScheme.primary),
                          Text(
                            '${_locationTags[_selectedTag]} 인근',
                            style: textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.sunny, color: colorScheme.primary),
                          Text('맑음 25℃', style: textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ],
                ),
                TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 4,
                  minLines: 4,
                  maxLength: 60,
                  style: textTheme.bodyMedium,
                  decoration: InputDecoration(
                    hintText: '오늘의 한마디를 적어보세요. (선택)',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiaryContainer,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: colorScheme.outline,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    counterStyle: textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
