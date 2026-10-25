import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/dependencies.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../../utils/url_launcher_utils.dart';
import '../../../utils/validators.dart';
import '../../core/widgets/responsive_container.dart';
import '../view_models/inquiry_viewmodel.dart';
import 'inquiry_device_info_section.dart';
import 'inquiry_image_picker_section.dart';

class InquiryReportScreen extends ConsumerStatefulWidget {
  const InquiryReportScreen({super.key});

  @override
  ConsumerState<InquiryReportScreen> createState() =>
      _InquiryReportScreenState();
}

class _InquiryReportScreenState extends ConsumerState<InquiryReportScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _contentController;

  @override
  void initState() {
    super.initState();

    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();

    super.dispose();
  }

  Future<void> _handlePickImage() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(inquiryViewModelProvider.notifier)
        .pickImage();

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        break;
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '이미지를 불러오는 중 오류가 발생했습니다.';
        messenger.showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: colorScheme.error,
          ),
        );
    }
  }

  Future<void> _handleOpenInquiryEmail() async {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    try {
      final effectiveDeviceInfo =
          ref.read(inquiryViewModelProvider).deviceInfo ??
          await ref.read(deviceInfoServiceProvider).getDeviceInfo();
      final result = await UrlLauncherUtils.openInquiryEmail(
        deviceInfo: effectiveDeviceInfo,
      );

      if (!mounted) {
        return;
      }

      switch (result) {
        case Ok():
          break;
        case Error(:final error):
          final errorMessage = error is AppException
              ? error.message
              : '메일 앱을 실행할 수 없습니다.';
          messenger.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: colorScheme.error,
            ),
          );
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(
        SnackBar(
          content: const Text('기기 정보를 불러오지 못해 메일 앱을 열 수 없습니다.'),
          backgroundColor: colorScheme.error,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final messenger = ScaffoldMessenger.of(context);

    final result = await ref
        .read(inquiryViewModelProvider.notifier)
        .submitInquiry(content: _contentController.text);

    if (!mounted) {
      return;
    }

    switch (result) {
      case Ok():
        messenger.showSnackBar(
          const SnackBar(content: Text('제보가 접수되었습니다. 소중한 의견 감사합니다.')),
        );
        context.pop();
      case Error(:final error):
        final errorMessage = error is AppException
            ? error.message
            : '제보 접수 중 오류가 발생했습니다.';
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

    final inquiryState = ref.watch(inquiryViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('문의 및 버그 제보')),
      body: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: ResponsiveContainer.form(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 20,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '인앱 제보는 시스템 개선을 위한 참고 자료로 수집되며 개별 답변이 발송되지 않습니다.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.tertiaryFixed,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(height: 1, color: colorScheme.outline),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: _handleOpenInquiryEmail,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.mail_outline,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '개별 답변이 필요하신가요? 이메일로 문의하기',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: colorScheme.primary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 16,
                                    color: colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    InquiryDeviceInfoSection(
                      deviceInfo: inquiryState.deviceInfo,
                      isLoading: inquiryState.isLoadingDeviceInfo,
                    ),
                    TextFormField(
                      controller: _contentController,
                      enabled: !inquiryState.isSubmitting,
                      minLines: 5,
                      maxLines: 8,
                      maxLength: 1000,
                      textInputAction: TextInputAction.newline,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: Validators.validateInquiryContent,
                      decoration: const InputDecoration(
                        labelText: '제보 내용',
                        hintText: '겪으신 문제나 개선 의견을 구체적으로 작성해 주세요 (최소 10자 이상)',
                        alignLabelWithHint: true,
                      ),
                    ),
                    InquiryImagePickerSection(
                      images: inquiryState.attachedImages,
                      maxImageCount: InquiryViewModel.maxImageCount,
                      canAddMoreImages: inquiryState.canAddMoreImages,
                      isSubmitting: inquiryState.isSubmitting,
                      onPickImage: _handlePickImage,
                      onRemoveImage: (index) => ref
                          .read(inquiryViewModelProvider.notifier)
                          .removeImage(index),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed:
                            (inquiryState.isSubmitting ||
                                inquiryState.isLoadingDeviceInfo)
                            ? null
                            : _handleSubmit,
                        child: inquiryState.isSubmitting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('제보 제출하기'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
