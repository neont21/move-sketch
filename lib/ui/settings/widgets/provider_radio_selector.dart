import 'package:flutter/material.dart';

class ProviderRadioSelector extends StatelessWidget {
  final List<String> availableProviders;
  final String? selectedProviderId;
  final bool isDeleting;
  final ValueChanged<String> onChanged;

  const ProviderRadioSelector({
    super.key,
    required this.availableProviders,
    required this.selectedProviderId,
    required this.isDeleting,
    required this.onChanged,
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
          '본인 확인에 사용할 수단을 선택해 주세요:',
          style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary),
        ),
        AbsorbPointer(
          absorbing: isDeleting,
          child: RadioGroup<String>(
            groupValue: selectedProviderId,
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final providerId in availableProviders)
                  _buildRadioTile(
                    providerId: providerId,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRadioTile({
    required String providerId,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final (String label, IconData icon, double iconSize) = switch (providerId) {
      'password' => ('비밀번호 입력', Icons.lock_outline, 20.0),
      'google.com' => ('Google 계정 인증', Icons.g_mobiledata, 26.0),
      'apple.com' => ('Apple 계정 인증', Icons.apple, 20.0),
      _ => (providerId, Icons.account_circle, 20.0),
    };

    return RadioListTile<String>(
      value: providerId,
      title: Text(label, style: textTheme.bodyMedium),
      secondary: Icon(
        icon,
        size: iconSize,
        color: selectedProviderId == providerId
            ? colorScheme.primary
            : colorScheme.outline,
      ),
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }
}
