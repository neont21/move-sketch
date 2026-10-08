import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/dependencies.dart';
import '../../../domain/models/notice.dart';
import '../../../utils/result.dart';

class NoticeDetailViewModel extends AsyncNotifier<Notice> {
  final String noticeId;

  NoticeDetailViewModel(this.noticeId);

  @override
  Future<Notice> build() async {
    final noticeRepository = ref.watch(noticeRepositoryProvider);
    final result = await noticeRepository.getNoticeById(noticeId);

    return switch (result) {
      Ok(:final value) => value,
      Error(:final error) => throw error,
    };
  }
}

final noticeDetailViewModelProvider = AsyncNotifierProvider.autoDispose
    .family<NoticeDetailViewModel, Notice, String>(
      (noticeId) => NoticeDetailViewModel(noticeId),
    );
