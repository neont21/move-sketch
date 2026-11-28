import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/dependencies.dart';
import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';

/// 관리자 문의·제보 탭의 목록, 상태 필터 및 처리 중 여부를 보관하는 불변 상태 모델입니다.
@immutable
final class AdminInquiryState {
  /// 조회된 문의·제보 목록.
  final List<Inquiry> inquiries;

  /// 현재 적용 중인 처리 상태 필터.
  final InquiryStatus? statusFilter;

  /// 상태 변경 등 비동기 작업 진행 중 여부.
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

/// 관리자 콘솔에서 접수된 인앱 문의·제보를 조회하고 처리 상태를 갱신하는 ViewModel입니다.
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

  /// 현재 선택된 필터([AdminInquiryState.statusFilter]) 기준으로 제보 목록을 다시 조회합니다.
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

  /// 제보 상태 필터([filter])를 변경하고 해당 조건으로 목록을 재조회합니다.
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

  /// 지정된 제보([inquiryId])의 처리 상태([newStatus])와 관리자 메모([adminNote])를 갱신합니다.
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

/// [AdminInquiryViewModel] 상태를 제공하는 자동 해제 [AsyncNotifierProvider].
final adminInquiryViewModelProvider =
    AsyncNotifierProvider.autoDispose<AdminInquiryViewModel, AdminInquiryState>(
      () {
        return AdminInquiryViewModel();
      },
    );
