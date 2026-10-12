import '../../../domain/models/notice.dart';
import '../../../utils/result.dart';

abstract interface class NoticeRepository {
  /// 특정 공지사항을 조회한다. (알림 화면)
  Future<Result<Notice>> getNoticeById(String noticeId);

  /// [관리] 모든 공지사항 목록을 최신순으로 조회한다.
  Future<Result<List<Notice>>> getAllNotices();

  /// [관리] 새로운 공지사항을 등록한다.
  Future<Result<void>> createNotice(Notice notice);

  /// [관리] 기존 공지사항을 수정한다.
  Future<Result<void>> updateNotice(Notice notice);

  /// [관리] 공지사항을 삭제한다.
  Future<Result<void>> deleteNotice(String noticeId);
}