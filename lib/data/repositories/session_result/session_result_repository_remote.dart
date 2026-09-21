import 'dart:typed_data';
import 'package:firebase_core/firebase_core.dart';
import '../../../domain/models/session/session_result.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/session_result_service.dart';
import '../../services/remote/firestore/sketch_post_service.dart';
import '../../services/remote/storage_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'session_result_repository.dart';

final class SessionResultRepositoryRemote implements SessionResultRepository {
  final SessionResultService sessionResultService;
  final StorageService storageService;
  final SketchPostService sketchPostService;

  SessionResultRepositoryRemote({
    required this.sessionResultService,
    required this.storageService,
    required this.sketchPostService,
  });

  @override
  Future<Result<SessionResult>> saveResult({
    required SessionResult result,
    required Uint8List sketchBytes,
    required Uint8List routeBytes,
  }) async {
    try {
      final uploadedUrl = await Future.wait([
        storageService.uploadSketchImage(
          userId: result.userId,
          sessionId: result.id,
          bytes: sketchBytes,
        ),
        storageService.uploadRouteImage(
          userId: result.userId,
          sessionId: result.id,
          bytes: routeBytes,
        ),
      ]);

      final resultWithImages = result.copyWith(
        resultSketchImageUrl: () => uploadedUrl[0],
        routeImageUrl: () => uploadedUrl[1],
      );
      final savedResult = await sessionResultService.saveResult(
        resultWithImages,
      );

      return Result.ok(savedResult);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '세션 결과 저장 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('세션 결과 저장 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<SessionResult?>> getResultById(String sessionId) async {
    try {
      final result = await sessionResultService.getResultById(sessionId);
      return Result.ok(result);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '세션 결과 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('세션 결과 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<SessionResult?>> getLatestResult(String userId) async {
    try {
      final result = await sessionResultService.getLatestResult(userId);
      return Result.ok(result);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '세션 결과 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('세션 결과 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<List<SessionResult>>> getResultsByMonth({
    required String userId,
    required int year,
    required int month,
  }) async {
    if (month < 1 || month > 12) {
      return const Result.error(ValidationException('유효하지 않은 기간입니다.'));
    }
    try {
      final monthlyResults = await sessionResultService.getResultsByMonth(
        userId: userId,
        year: year,
        month: month,
      );
      return Result.ok(monthlyResults);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '세션 결과 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('세션 결과 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateSecretMemo({
    required String sessionId,
    required String secretMemo,
  }) async {
    try {
      await sessionResultService.updateSecretMemo(
        resultId: sessionId,
        secretMemo: secretMemo.trim(),
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '나만 보는 메모 저장 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('나만 보는 메모 저장 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateShareStatus({
    required String sessionId,
    required bool isShared,
  }) async {
    try {
      await sessionResultService.updateShareStatus(
        resultId: sessionId,
        isShared: isShared,
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '공유 상태 변경 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('공유 상태 변경 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> deleteResult(
    String sessionId, {
    bool deletePostIfShared = false,
  }) async {
    try {
      if (deletePostIfShared) {
        final existing = await sessionResultService.getResultById(sessionId);
        if (existing != null && existing.isShared) {
          await sketchPostService.deletePost(sessionId);
        }
      }
      await sessionResultService.deleteResult(sessionId);
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '세션 결과 삭제 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('세션 결과 삭제 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
