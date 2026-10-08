import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../../utils/url_launcher_utils.dart';
import '../../core/widgets/error_retry_view.dart';
import '../view_models/notice_detail_viewmodel.dart';

class NoticeDetailScreen extends ConsumerWidget {
  final String noticeId;

  const NoticeDetailScreen({super.key, required this.noticeId});

  Future<void> _handleActionUrl(BuildContext context, String url) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final result = await UrlLauncherUtils.openExternalUrl(url);
    if (!context.mounted) {
      return;
    }

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '링크를 여는 중 오류가 발생했습니다.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final noticeState = ref.watch(noticeDetailViewModelProvider(noticeId));

    return Scaffold(
      appBar: AppBar(title: const Text('공지사항')),
      body: noticeState.when(
        error: (error, _) => ErrorRetryView.fromError(
          error: error,
          onRetry: () =>
              ref.invalidate(noticeDetailViewModelProvider(noticeId)),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        data: (state) {
          final ColorScheme colorScheme = Theme.of(context).colorScheme;
          final TextTheme textTheme = Theme.of(context).textTheme;

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.isImportant)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '중요',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  state.title,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  state.createdAt.formattedDateDot,
                  style: textTheme.labelMedium,
                ),
                const Divider(height: 32),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      state.content,
                      style: textTheme.bodyMedium?.copyWith(height: 1.6),
                    ),
                  ),
                ),
                if (state.actionUrl != null && state.actionUrl!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleActionUrl(
                        context,
                        state.actionUrl!,
                      ),
                      child: Text(state.actionButtonText ?? '자세히 보기'),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
