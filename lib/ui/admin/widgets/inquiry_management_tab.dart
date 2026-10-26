import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/date_time_utils.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../core/widgets/error_retry_view.dart';
import '../view_models/admin_inquiry_viewmodel.dart';
import 'inquiry_detail_dialog.dart';

class InquiryManagementTab extends ConsumerWidget {
  const InquiryManagementTab({super.key});

  Color _getStatusColor(InquiryStatus status, ColorScheme colorScheme) {
    return switch (status) {
      InquiryStatus.unconfirmed => colorScheme.error,
      InquiryStatus.reviewing => colorScheme.primary,
      InquiryStatus.inProgress => Colors.orange,
      InquiryStatus.resolved => Colors.teal,
      InquiryStatus.dismissed => colorScheme.tertiaryContainer,
    };
  }

  void _openDetailDialog(BuildContext context, Inquiry inquiry) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        constraints: const BoxConstraints(maxWidth: 680),
        child: InquiryDetailDialog(inquiry: inquiry),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    final inquiryState = ref.watch(adminInquiryViewModelProvider);

    return inquiryState.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: ErrorRetryView.fromError(
          error: error,
          defaultMessage: '제보 목록을 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(adminInquiryViewModelProvider),
        ),
      ),
      data: (state) {
        final inquiries = state.inquiries;
        final isProcessing = state.isProcessing;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '인앱 제보 관리 (${inquiries.length}건)',
                    style: textTheme.headlineSmall,
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colorScheme.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<InquiryStatus?>(
                            value: state.statusFilter,
                            hint: const Text('전체 보기'),
                            items: [
                              DropdownMenuItem<InquiryStatus?>(
                                value: null,
                                child: Text(
                                  '전체 상태',
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              ...InquiryStatus.values.map(
                                (status) => DropdownMenuItem<InquiryStatus?>(
                                  value: status,
                                  child: Text(
                                    status.label,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: isProcessing
                                ? null
                                : (filter) => ref
                                      .read(
                                        adminInquiryViewModelProvider.notifier,
                                      )
                                      .setStatusFilter(filter),
                          ),
                        ),
                      ),

                      IconButton(
                        tooltip: '새로고침',
                        icon: const Icon(Icons.refresh),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final result = await ref
                                    .read(
                                      adminInquiryViewModelProvider.notifier,
                                    )
                                    .refreshInquiries();

                                if (!context.mounted) {
                                  return;
                                }

                                switch (result) {
                                  case Ok():
                                    break;
                                  case Error(:final error):
                                    final message = error is AppException
                                        ? error.message
                                        : '제보 목록 새로고침 중 오류가 발생했습니다.';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(message),
                                        backgroundColor: colorScheme.error,
                                      ),
                                    );
                                }
                              },
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (inquiries.isEmpty)
                Container(
                  padding: const EdgeInsets.all(48),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.outline),
                  ),
                  child: Center(
                    child: Text(
                      '조건에 해당하는 제보 내역이 없습니다.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.tertiaryContainer,
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: inquiries.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final inquiry = inquiries[index];
                    final statusColor = _getStatusColor(
                      inquiry.status,
                      colorScheme,
                    );

                    return Card(
                      elevation: 0,
                      color: colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: colorScheme.outline),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openDetailDialog(context, inquiry),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 8,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(
                                        alpha: 0.12,
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: statusColor.withValues(
                                          alpha: 0.4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      inquiry.status.label,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${inquiry.createdAt.formattedDateDot} ${inquiry.createdAt.formattedTime}',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.tertiaryContainer,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (inquiry.imageUrls.isNotEmpty)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.image_outlined,
                                          size: 16,
                                          color: colorScheme.tertiaryContainer,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${inquiry.imageUrls.length}',
                                          style: textTheme.labelSmall?.copyWith(
                                            color:
                                                colorScheme.tertiaryContainer,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),

                              Text(
                                inquiry.content,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              Text(
                                '${inquiry.deviceInfo.deviceModel} · ${inquiry.deviceInfo.osVersion} · ${inquiry.userEmail ?? inquiry.userId ?? '비회원'}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.tertiaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}
