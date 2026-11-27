import '../../../domain/models/enums/report_status.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/result.dart';

/// 사용자·게시글·댓글 신고 접수 및 관리자 상태 관리를 추상화한 저장소 인터페이스입니다.
abstract interface class ReportRepository {
  /// 신고 내역([report])을 서버에 접수합니다.
  Future<Result<void>> submitReport(Report report);

  /// 접수된 신고 목록을 조회합니다. (관리자 전용, [statusFilter]로 상태 필터링 가능)
  Future<Result<List<Report>>> getReports({ReportStatus? statusFilter});

  /// 지정된 신고([reportId])의 처리 상태([status])를 갱신합니다. (관리자 전용)
  Future<Result<void>> updateReportStatus(String reportId, ReportStatus status);
}
