import 'package:flutter/material.dart';

class CheerButton extends StatelessWidget {
  final bool isMyPost;
  final bool isCheered;
  final int cheerCount;
  final bool isLoading;
  final VoidCallback onToggle;
  final VoidCallback onTapCount;

  const CheerButton({
    super.key,
    required this.isMyPost,
    required this.isCheered,
    required this.cheerCount,
    required this.isLoading,
    required this.onToggle,
    required this.onTapCount,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton(
      onPressed: isLoading ? null : (isMyPost ? onTapCount : onToggle),
      style: ElevatedButton.styleFrom(
        side: BorderSide(color: colorScheme.outline),
        backgroundColor: isCheered
            ? colorScheme.primary
            : colorScheme.surfaceContainer,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: isCheered
                      ? colorScheme.onPrimary
                      : colorScheme.tertiaryContainer,
                ),
              )
            else
              Icon(
                Icons.star_outline_rounded,
                color: isCheered
                    ? colorScheme.onPrimary
                    : colorScheme.tertiaryContainer,
                size: 28,
              ),
            Text(
              isMyPost
                  ? '응원 $cheerCount명'
                  : isCheered
                  ? '응원했어요 $cheerCount'
                  : '응원하기 $cheerCount',
              style: textTheme.headlineSmall?.copyWith(
                color: isCheered
                    ? colorScheme.onPrimary
                    : colorScheme.tertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
