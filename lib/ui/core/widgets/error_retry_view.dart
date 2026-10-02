import 'package:flutter/material.dart';
import '../../../utils/exceptions.dart';

class ErrorRetryView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;
  final String retryButtonText;

  const ErrorRetryView({
    super.key,
    required this.errorMessage,
    this.onRetry,
    this.retryButtonText = '다시 시도',
  });

  factory ErrorRetryView.fromError({
    Key? key,
    required Object error,
    VoidCallback? onRetry,
    String defaultMessage = '데이터를 불러오는 중 오류가 발생했습니다.',
    String retryButtonText = '다시 시도',
  }) {
    final String message = error is AppException
        ? error.message
        : defaultMessage;

    final bool isNotFound = error is NotFoundException;

    return ErrorRetryView(
      key: key,
      errorMessage: message,
      onRetry: isNotFound ? null : onRetry,
      retryButtonText: retryButtonText,
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage,
              style: textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: onRetry,
                child: Text(retryButtonText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
