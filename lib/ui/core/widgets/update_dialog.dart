import 'package:flutter/material.dart';
import '../../../domain/models/app_version_policy.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../../utils/url_launcher_utils.dart';

class UpdateDialog extends StatelessWidget {
  final AppVersionPolicy policy;
  final bool isForceUpdate;

  const UpdateDialog({
    super.key,
    required this.policy,
    required this.isForceUpdate,
  });

  Future<void> _handleUpdate(BuildContext context) async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await UrlLauncherUtils.openStore();

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '스토어로 이동 중 오류가 발생했습니다.';
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

    return PopScope(
      canPop: !isForceUpdate,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(policy.title, style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '최신 버전: v${policy.latestVersion}',
              style: textTheme.labelMedium,
            ),
            const SizedBox(height: 16),
            if (policy.releaseNotes.isNotEmpty) ...[
              Text(
                '업데이트 내용',
                style: textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 180),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    policy.releaseNotes,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                if (!isForceUpdate) ...[
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        '다음에 하기',
                        style: textTheme.labelLarge?.copyWith(
                          color: colorScheme.tertiaryContainer,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _handleUpdate(context),
                      child: const Text('업데이트'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
