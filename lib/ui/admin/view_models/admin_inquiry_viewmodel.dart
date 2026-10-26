import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

@immutable
final class AdminInquiryState {
  final List<Inquiry> inquiries;
  final InquiryStatus? statusFilter;
  final bool isProcessing;

  const AdminInquiryState({
    this.inquiries = const [],
    this.statusFilter,
    this.isProcessing = false,
  });

  AdminInquiryState copyWith({
    List<Inquiry>? inquiries,
    InquiryStatus? statusFilter,
    bool clearStatusFilter = false,
    bool? isProcessing,
  }) {
    return AdminInquiryState(
      inquiries: inquiries ?? this.inquiries,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}

final class AdminInquiryViewModel extends AsyncNotifier<AdminInquiryState> {
  @override
  Future<AdminInquiryState> build() async {
    final inquiryRepository = ref.read(inquiryRepositoryProvider);
    final result = await inquiryRepository.getInquiries();

    switch (result) {
      case Ok(:final value):
        return AdminInquiryState(inquiries: value);
      case Error(:final error):
        throw error;
    }
  }

  Future<Result<void>> refreshInquiries() async {
    final currentFilter = state.value?.statusFilter;

    final inquiryRepository = ref.read(inquiryRepositoryProvider);
    final result = await inquiryRepository.getInquiries(
      statusFilter: currentFilter,
    );

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          AdminInquiryState(inquiries: value, statusFilter: currentFilter),
        );
        return const Result.ok(null);
      case Error(:final error):
        return Result.error(error);
    }
  }

  Future<void> setStatusFilter(InquiryStatus? filter) async {
    state = const AsyncLoading();

    final inquiryRepository = ref.read(inquiryRepositoryProvider);
    final result = await inquiryRepository.getInquiries(statusFilter: filter);

    switch (result) {
      case Ok(:final value):
        state = AsyncData(
          AdminInquiryState(inquiries: value, statusFilter: filter),
        );
      case Error(:final error):
        state = AsyncError(error, StackTrace.current);
    }
  }

  Future<Result<void>> updateStatus(
    String inquiryId,
    InquiryStatus newStatus, {
    String? adminNote,
  }) async {
    final current = state.value;
    if (current == null) {
      return const Result.error(
        ValidationException('제보 목록이 로드되지 않아 상태를 갱신할 수 없습니다.'),
      );
    }
    state = AsyncData(current.copyWith(isProcessing: true));
    final repository = ref.read(inquiryRepositoryProvider);
    final result = await repository.updateInquiryStatus(
      inquiryId,
      newStatus,
      adminNote: adminNote,
    );

    switch (result) {
      case Ok():
        final updatedList = current.inquiries.map((inquiry) {
          if (inquiry.id == inquiryId) {
            return inquiry.copyWith(
              status: newStatus,
              adminNote: adminNote,
              updatedAt: DateTime.now(),
            );
          }

          return inquiry;
        }).toList();
        state = AsyncData(
          current.copyWith(inquiries: updatedList, isProcessing: false),
        );
      case Error():
        state = AsyncData(current.copyWith(isProcessing: false));
    }
    return result;
  }
}

final adminInquiryViewModelProvider =
    AsyncNotifierProvider.autoDispose<AdminInquiryViewModel, AdminInquiryState>(
      () {
        return AdminInquiryViewModel();
      },
    );
