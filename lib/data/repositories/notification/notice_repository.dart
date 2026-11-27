import '../../../domain/models/system/notice.dart';
import '../../../utils/result.dart';

/// 시스템 공지사항 조회 및 관리자 등록·수정·삭제를 추상화한 저장소 인터페이스입니다.
abstract interface class NoticeRepository {
  /// 지정된 공지사항([noticeId])의 상세 정보를 조회합니다. (알림 화면)
  Future<Result<Notice>> getNoticeById(String noticeId);

  /// 등록된 모든 공지사항 목록을 최신순으로 조회합니다. (관리자 전용)
  Future<Result<List<Notice>>> getAllNotices();

  /// 새로운 공지사항([notice])을 등록합니다. (관리자 전용)
  Future<Result<void>> createNotice(Notice notice);

  /// 기존 공지사항([notice])의 내용을 수정합니다. (관리자 전용)
  Future<Result<void>> updateNotice(Notice notice);

  /// 지정된 공지사항([noticeId])을 삭제합니다. (관리자 전용)
  Future<Result<void>> deleteNotice(String noticeId);
}
