import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../domain/models/app_version_policy.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/system_alert_dialog.dart';
import '../view_models/admin_viewmodel.dart';
import 'version_dialog_content_card.dart';
import 'version_rule_card.dart';

class AppVersionTab extends ConsumerStatefulWidget {
  const AppVersionTab({super.key});

  @override
  ConsumerState<AppVersionTab> createState() => _AppVersionTabState();
}

class _AppVersionTabState extends ConsumerState<AppVersionTab> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _latestVersionController;
  late final TextEditingController _latestBuildNumberController;
  late final TextEditingController _minRequiredVersionController;
  late final TextEditingController _minRequiredBuildNumberController;
  late final TextEditingController _titleController;
  late final TextEditingController _releaseNotesController;
  late final TextEditingController _androidStoreUrlController;
  late final TextEditingController _iosStoreUrlController;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    final AppVersionPolicy? currentPolicy = ref
        .read(adminViewModelProvider)
        .value
        ?.versionPolicy;

    _latestVersionController = TextEditingController(
      text: currentPolicy?.latestVersion ?? '1.0.0',
    );

    _latestBuildNumberController = TextEditingController(
      text: currentPolicy != null
          ? currentPolicy.latestBuildNumber.toString()
          : '1',
    );
    _minRequiredVersionController = TextEditingController(
      text: currentPolicy?.minRequiredVersion ?? '1.0.0',
    );
    _minRequiredBuildNumberController = TextEditingController(
      text: currentPolicy != null
          ? currentPolicy.minRequiredBuildNumber.toString()
          : '1',
    );
    _titleController = TextEditingController(
      text: currentPolicy?.title ?? '새로운 버전이 출시되었습니다!',
    );
    _releaseNotesController = TextEditingController(
      text: currentPolicy?.releaseNotes ?? '',
    );
    _androidStoreUrlController = TextEditingController(
      text: currentPolicy?.androidStoreUrl ?? '',
    );
    _iosStoreUrlController = TextEditingController(
      text: currentPolicy?.iosStoreUrl ?? '',
    );
  }

  @override
  void dispose() {
    _latestVersionController.dispose();
    _latestBuildNumberController.dispose();
    _minRequiredVersionController.dispose();
    _minRequiredBuildNumberController.dispose();
    _titleController.dispose();
    _releaseNotesController.dispose();
    _androidStoreUrlController.dispose();
    _iosStoreUrlController.dispose();

    super.dispose();
  }

  void _populateFields(AppVersionPolicy policy) {
    setState(() {
      _latestVersionController.text = policy.latestVersion;
      _latestBuildNumberController.text = policy.latestBuildNumber.toString();
      _minRequiredVersionController.text = policy.minRequiredVersion;
      _minRequiredBuildNumberController.text = policy.minRequiredBuildNumber
          .toString();
      _titleController.text = policy.title;
      _releaseNotesController.text = policy.releaseNotes;
      _androidStoreUrlController.text = policy.androidStoreUrl ?? '';
      _iosStoreUrlController.text = policy.iosStoreUrl ?? '';
    });
  }

  void _handleReset() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(adminViewModelProvider.notifier)
        .refreshVersionPolicy();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        final policy = ref.read(adminViewModelProvider).value?.versionPolicy;

        if (policy != null) {
          _populateFields(policy);
          messenger.showSnackBar(
            const SnackBar(content: Text('원격에 저장된 최신 정책으로 되돌렸습니다.')),
          );
        } else {
          _populateDefaults();
          messenger.showSnackBar(
            const SnackBar(content: Text('기본 권장 설정값으로 초기화했습니다.')),
          );
        }
      case Error(:final error):
        final message = error is AppException
            ? error.message
            : '원격 정책을 불러오는 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  Future<void> _populateDefaults() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _latestVersionController.text = packageInfo.version;
      _latestBuildNumberController.text = packageInfo.buildNumber;
    } catch (_) {
      _latestVersionController.text = '1.0.0';
      _latestBuildNumberController.text = '1';
    }
    _minRequiredVersionController.text = '1.0.0';
    _minRequiredBuildNumberController.text = '1';
    _titleController.text = '새로운 버전이 출시되었습니다!';
    _releaseNotesController.text = '';
    _androidStoreUrlController.text = '';
    _iosStoreUrlController.text = '';
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) {
      return;
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Dialog(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SystemAlertDialog(
            title: '앱 버전 정책을 저장할까요?',
            description:
                '저장 즉시 운영 중인 모든 클라이언트 앱에 해당 버전 정책이 반영됩니다.\n계속 진행하시겠습니까?',
            confirmText: '저장',
            onConfirm: () => dialogContext.pop(true),
          ),
        ),
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final String latestVersion = _latestVersionController.text.trim();
    final int latestBuildNumber = int.parse(
      _latestBuildNumberController.text.trim(),
    );
    final String minRequiredVersion = _minRequiredVersionController.text.trim();
    final int minRequiredBuildNumber = int.parse(
      _minRequiredBuildNumberController.text.trim(),
    );

    final String title = _titleController.text.trim();
    final String releaseNotes = _releaseNotesController.text.trim();
    final String androidStoreUrl = _androidStoreUrlController.text.trim();
    final String iosStoreUrl = _iosStoreUrlController.text.trim();

    final AppVersionPolicy updatedPolicy = AppVersionPolicy(
      latestVersion: latestVersion,
      latestBuildNumber: latestBuildNumber,
      minRequiredVersion: minRequiredVersion,
      minRequiredBuildNumber: minRequiredBuildNumber,
      title: title,
      releaseNotes: releaseNotes,
      androidStoreUrl: androidStoreUrl.isEmpty ? null : androidStoreUrl,
      iosStoreUrl: iosStoreUrl.isEmpty ? null : iosStoreUrl,
    );

    final result = await ref
        .read(adminViewModelProvider.notifier)
        .saveVersionPolicy(updatedPolicy);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSubmitting = false;
    });

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          const SnackBar(content: Text('앱 버전 정책이 성공적으로 저장되었습니다.')),
        );
      case Error(:final error):
        final String message = error is AppException
            ? error.message
            : '버전 정책 저장 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(content: Text(message), backgroundColor: colorScheme.error),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    ref.listen<AsyncValue<AdminState>>(adminViewModelProvider, (
      previous,
      next,
    ) {
      final prevPolicy = previous?.value?.versionPolicy;
      final nextPolicy = next.value?.versionPolicy;
      if (prevPolicy != nextPolicy && nextPolicy != null) {
        _populateFields(nextPolicy);
      }
    });

    final AdminState adminState = ref
        .watch(adminViewModelProvider)
        .requireValue;
    final bool isProcessing = adminState.isProcessing || _isSubmitting;
    final bool hasRemotePolicy = adminState.versionPolicy != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('원격 앱 버전 정책 관리', style: textTheme.headlineSmall),
                Row(
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.restart_alt, size: 18),
                      label: const Text('되돌리기'),
                      onPressed: isProcessing ? null : _handleReset,
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      icon: isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(Icons.save_outlined, size: 18),
                      label: const Text('정책 저장'),
                      onPressed: isProcessing ? null : _handleSubmit,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!hasRemotePolicy)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '현재 Firestore에 등록된 버전 정책이 없습니다. 기본값을 확인 후 [정책 저장]을 눌러 최초 정책을 생성해 주세요.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            LayoutBuilder(
              builder: (context, constraints) {
                final bool isWide = constraints.maxWidth >= 840;

                final Widget versionRuleCard = VersionRuleCard(
                  latestVersionController: _latestVersionController,
                  latestBuildNumberController: _latestBuildNumberController,
                  minRequiredVersionController: _minRequiredVersionController,
                  minRequiredBuildNumberController:
                      _minRequiredBuildNumberController,
                  onValuesChanged: () => setState(() {}),
                );

                final Widget dialogContentCard = VersionDialogContentCard(
                  titleController: _titleController,
                  androidStoreUrlController: _androidStoreUrlController,
                  iosStoreUrlController: _iosStoreUrlController,
                  releaseNotesController: _releaseNotesController,
                );

                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: versionRuleCard),
                      const SizedBox(width: 24),
                      Expanded(child: dialogContentCard),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    versionRuleCard,
                    const SizedBox(height: 20),
                    dialogContentCard,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
