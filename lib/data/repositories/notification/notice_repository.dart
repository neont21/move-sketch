import '../../../domain/models/notice.dart';
import '../../../utils/result.dart';

abstract interface class NoticeRepository {
  /// 특정 공지사항을 조회한다. (알림 화면)
  Future<Result<Notice>> getNoticeById(String noticeId);
}