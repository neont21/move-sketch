import 'package:flutter/material.dart';

class SocialReauthSection extends StatelessWidget {
  final String providerName;
  final IconData icon;
  final double iconSize;
  final bool isDeleting;
  final VoidCallback onConfirm;

  const SocialReauthSection({
    super.key,
    required this.providerName,
    required this.icon,
    required this.iconSize,
    required this.isDeleting,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '안전을 위해 $providerName 계정 본인 인증이 필요해요.\n인증 완료 시 계정과 모든 기록이 즉시 삭제됩니다.',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isDeleting ? null : onConfirm,
            icon: Icon(icon, size: iconSize, color: colorScheme.error),
            label: Text(
              isDeleting ? '삭제 중...' : '$providerName 인증 후 삭제',
              style: textTheme.labelLarge?.copyWith(color: colorScheme.error),
            ),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.error),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
