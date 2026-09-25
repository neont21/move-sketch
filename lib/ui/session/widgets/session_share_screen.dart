import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/domain/models/enums/character_type.dart';
import 'package:move_sketch/ui/session/view_models/session_share_viewmodel.dart';
import 'package:move_sketch/utils/exceptions.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../routing/routes.dart';
import '../../../utils/result.dart';
import 'sketch_card.dart';

class SessionShareScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionShareScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionShareScreen> createState() => _SessionShareScreenState();
}

class _SessionShareScreenState extends ConsumerState<SessionShareScreen> {
  late final TextEditingController _captionController;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();

    _captionController = TextEditingController();
  }

  @override
  void dispose() {
    _captionController.dispose();

    super.dispose();
  }

  Future<void> _handleSave() async {
    final state = ref
        .read(sessionShareViewModelProvider(widget.sessionId))
        .value;
    if (state == null || state.isPublishing) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    final result = await ref
        .read(sessionShareViewModelProvider(widget.sessionId).notifier)
        .publishPost();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        if (state.isEdit && context.canPop()) {
          context.pop();
        } else {
          context.go(Routes.feedPost(widget.sessionId));
        }
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '피드 공유에 실패했습니다. 다시 시도해 주세요.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  ImageProvider _resolveSketchImage({
    SessionResult? result,
    String? existingUrl,
    required CharacterType character,
  }) {
    final url = result?.resultSketchImageUrl ?? existingUrl;
    if (url != null && url.isNotEmpty) {
      return NetworkImage(url);
    }
    return AssetImage(character.defaultImagePath);
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<SessionShareState>>(
      sessionShareViewModelProvider(widget.sessionId),
          (prev, next) {
        next.whenData((data) {
          if (!_isControllerInitialized && data.caption.isNotEmpty) {
            _captionController.text = data.caption;
            _isControllerInitialized = true;
          }
        });
      },
    );

    final shareState = ref.watch(
      sessionShareViewModelProvider(widget.sessionId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text((shareState.value?.isEdit ?? false) ? '수정하기' : '피드에 올리기'),
        actions: [
          shareState.maybeWhen(
            data: (state) => state.isPublishing
                ? const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : IconButton(
                    onPressed: _handleSave,
                    icon: const Icon(Icons.check),
                  ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: shareState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              error is AppException ? error.message : '데이터를 불러오는 중 오류가 발생했습니다.',
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (state) {
          final imageProvider = _resolveSketchImage(
            result: state.sessionResult,
            existingUrl: state.existingPost?.sketchUrl,
            character: state.character,
          );
          final rawTag = state.locationTags.length > state.locationIndex
              ? state.locationTags[state.locationIndex]
              : '알 수 없는 위치';
          final locationDisplayText = rawTag == '알 수 없는 위치'
              ? rawTag
              : '$rawTag 인근';
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Center(
                child: Column(
                  spacing: 20,
                  children: [
                    SketchCard(imageProvider: imageProvider),
                    Text(
                      '위치 태그 선택',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.secondary,
                      ),
                    ),
                    AnimatedToggleSwitch<int>.size(
                      current: state.locationIndex,
                      values: const [0, 1, 2],
                      onChanged: (i) {
                        ref
                            .read(
                              sessionShareViewModelProvider(
                                widget.sessionId,
                              ).notifier,
                            )
                            .selectTag(i);
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
                        final label = switch (value) {
                          0 => '출발지',
                          1 => '경유지',
                          2 => '도착지',
                          _ => '위치',
                        };
                        return Center(
                          child: Text(
                            label,
                            style: textTheme.bodyLarge?.copyWith(
                              color: (value == state.locationIndex)
                                  ? colorScheme.onPrimary
                                  : colorScheme.tertiaryFixed,
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
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
                              Icon(
                                Icons.location_pin,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                locationDisplayText,
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        if (state.weatherInfo != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
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
                                Image.network(
                                  state.weatherInfo!.iconUrl,
                                  width: 20,
                                  height: 20,
                                  errorBuilder: (_, _, _) => Icon(
                                    Icons.wb_sunny,
                                    size: 20,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(state.weatherInfo!.shortSummary, style: textTheme.bodyMedium),
                              ],
                            ),
                          ),
                      ],
                    ),
                    TextField(
                      controller: _captionController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      minLines: 4,
                      maxLength: 60,
                      style: textTheme.bodyMedium,
                      onChanged: (text) {
                        ref
                            .read(
                              sessionShareViewModelProvider(
                                widget.sessionId,
                              ).notifier,
                            )
                            .updateCaption(text);
                      },
                      decoration: const InputDecoration(
                        hintText: '오늘의 한마디를 적어보세요. (선택)',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
