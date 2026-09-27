import 'package:firebase_core/firebase_core.dart';
import '../../../domain/models/social/report.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/report_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'report_repository.dart';

final class ReportRepositoryRemote implements ReportRepository {
  final ReportService reportService;

  ReportRepositoryRemote({required this.reportService});

  @override
  Future<Result<void>> submitReport(Report report) async {
    try {
      await reportService.submitReport(report);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '신고 접수 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('신고 접수 중 오류가 발생했습니다.', cause: e));
    }
  }
}
