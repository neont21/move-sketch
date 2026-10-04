import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/account_settings_viewmodel.dart';
import 'password_reauth_section.dart';
import 'provider_radio_selector.dart';
import 'social_reauth_section.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _passwordController;

  String? _selectedProviderId;
  bool _showPassword = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();

    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _passwordController.dispose();

    super.dispose();
  }

  void _handleDeleteWithPassword() async {
    FocusScope.of(context).unfocus();

    if (_isDeleting || !(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(authViewModelProvider.notifier)
        .deleteAccountWithPassword(
          currentPassword: _passwordController.text,
          username: user.username,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isDeleting = false;
    });

    switch (result) {
      case Ok():
        context.pop();
        context.go(Routes.login);
        messenger.showSnackBar(const SnackBar(content: Text('계정이 삭제되었습니다.')));
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : '계정 삭제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleDeleteWithGoogle() async {
    if (_isDeleting) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(authViewModelProvider.notifier)
        .deleteAccountWithGoogle(username: user.username);

    if (!mounted) {
      return;
    }

    setState(() {
      _isDeleting = false;
    });

    switch (result) {
      case Ok(value: true):
        context.pop();
        context.go(Routes.login);
        messenger.showSnackBar(const SnackBar(content: Text('계정이 삭제되었습니다.')));
      case Ok(value: false):
        break;
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : 'Google 재인증 및 계정 삭제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleDeleteWithApple() async {
    if (_isDeleting) {
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(authViewModelProvider.notifier)
        .deleteAccountWithApple(username: user.username);

    if (!mounted) {
      return;
    }

    setState(() {
      _isDeleting = false;
    });

    switch (result) {
      case Ok(value: true):
        context.pop();
        context.go(Routes.login);
        messenger.showSnackBar(const SnackBar(content: Text('계정이 삭제되었습니다.')));
      case Ok(value: false):
        break;
      case Error(:final error):
        final String errorMessage = error is AppException
            ? error.message
            : 'Apple 재인증 및 계정 삭제 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Widget _buildAuthSection({required String? selectedProviderId}) {
    return switch (selectedProviderId) {
      'password' => PasswordReauthSection(
        formKey: _formKey,
        passwordController: _passwordController,
        showPassword: _showPassword,
        isDeleting: _isDeleting,
        onToggleVisibility: () {
          setState(() {
            _showPassword = !_showPassword;
          });
        },
        onConfirm: _handleDeleteWithPassword,
      ),
      'google.com' => SocialReauthSection(
        providerName: 'Google',
        icon: Icons.g_mobiledata,
        iconSize: 28,
        isDeleting: _isDeleting,
        onConfirm: _handleDeleteWithGoogle,
      ),
      'apple.com' => SocialReauthSection(
        providerName: 'Apple',
        icon: Icons.apple,
        iconSize: 22,
        isDeleting: _isDeleting,
        onConfirm: _handleDeleteWithApple,
      ),
      _ => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final accountSettingsState = ref.watch(accountSettingsViewModelProvider);
    final List<String> availableProviders =
        accountSettingsState.linkedProviders;

    if (_selectedProviderId == null ||
        !availableProviders.contains(_selectedProviderId)) {
      if (availableProviders.isNotEmpty) {
        _selectedProviderId = availableProviders.first;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          spacing: 12,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '계정을 삭제할까요?',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
            Text(
              '지금까지 남긴 기록이 모두 지워지고 되돌릴 수 없어요.',
              style: textTheme.labelMedium,
            ),
            if (availableProviders.length > 1)
              ProviderRadioSelector(
                availableProviders: availableProviders,
                selectedProviderId: _selectedProviderId,
                isDeleting: _isDeleting,
                onChanged: (providerId) {
                  setState(() {
                    _selectedProviderId = providerId;
                  });
                },
              ),
            _buildAuthSection(selectedProviderId: _selectedProviderId),
          ],
        ),
      ),
    );
  }
}
