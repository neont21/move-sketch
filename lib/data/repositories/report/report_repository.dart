import '../../../domain/models/social/report.dart';
import '../../../utils/result.dart';

abstract interface class ReportRepository {
  /// 신고를 접수한다.
  Future<Result<void>> submitReport(Report report);
}