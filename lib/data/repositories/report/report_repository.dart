import '../../../domain/models/enums/report_status.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/result.dart';

abstract interface class ReportRepository {
  /// 신고를 접수한다.
  Future<Result<void>> submitReport(Report report);

  /// [관리] 접수된 신고 목록을 조회한다.
  Future<Result<List<Report>>> getReports({ReportStatus? statusFilter});

  /// [관리] 신고 처리 상태를 갱신한다.
  Future<Result<void>> updateReportStatus(String reportId, ReportStatus status);
}