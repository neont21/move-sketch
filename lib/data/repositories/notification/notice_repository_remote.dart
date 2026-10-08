import 'package:firebase_core/firebase_core.dart';
import '../../../domain/models/notice.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/notice_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'notice_repository.dart';

class NoticeRepositoryRemote implements NoticeRepository {
  final NoticeService noticeService;

  NoticeRepositoryRemote({required this.noticeService});

  @override
  Future<Result<Notice>> getNoticeById(String noticeId) async {
    try {
      final notice = await noticeService.getNoticeById(noticeId);
      if (notice == null) {
        return const Result.error(DatabaseException('공지사항을 찾을 수 없습니다.'));
      }

      return Result.ok(notice);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '공지사항 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(DatabaseException('공지사항 조회 중 오류가 발생했습니다.', cause: e));
    }
  }
}
