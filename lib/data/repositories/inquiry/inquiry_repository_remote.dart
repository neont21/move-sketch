import 'dart:typed_data';

import 'package:firebase_core/firebase_core.dart';

import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../services/remote/firestore/inquiry_service.dart';
import '../../services/remote/storage_service.dart';
import '../common/firebase_exception_mapper.dart';
import 'inquiry_repository.dart';

final class InquiryRepositoryRemote implements InquiryRepository {
  final InquiryService inquiryService;
  final StorageService storageService;

  InquiryRepositoryRemote({
    required this.inquiryService,
    required this.storageService,
  });

  @override
  Future<Result<void>> submitInquiry(
    Inquiry inquiry, {
    List<Uint8List> imageBytesList = const [],
  }) async {
    try {
      final List<String> uploadedImageUrls = [];

      for (int index = 0; index < imageBytesList.length; index++) {
        final String imageUrl = await storageService.uploadInquiryImage(
          inquiryId: inquiry.id,
          imageIndex: index,
          bytes: imageBytesList[index],
        );

        uploadedImageUrls.add(imageUrl);
      }

      final inquiryToSave = inquiry.copyWith(imageUrls: uploadedImageUrls);
      await inquiryService.createInquiry(inquiryToSave);

      return const Result.ok(null);
    } on FirebaseException catch (exception) {
      return Result.error(
        exception.toAppException(defaultMessage: '문의/제보 접수 중 오류가 발생했습니다.'),
      );
    } catch (exception) {
      return Result.error(
        DatabaseException('문의/제보 접수 중 오류가 발생했습니다.', cause: exception),
      );
    }
  }

  @override
  Future<Result<List<Inquiry>>> getInquiries({
    InquiryStatus? statusFilter,
  }) async {
    try {
      final inquiries = await inquiryService.getInquiries(
        statusFilter: statusFilter,
      );
      return Result.ok(inquiries);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '문의/제보 목록 조회 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('문의/제보 목록 조회 중 오류가 발생했습니다.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> updateInquiryStatus(
    String inquiryId,
    InquiryStatus status, {
    String? adminNote,
  }) async {
    try {
      await inquiryService.updateInquiryStatus(
        inquiryId,
        status,
        adminNote: adminNote,
      );
      return const Result.ok(null);
    } on FirebaseException catch (e) {
      return Result.error(
        e.toAppException(defaultMessage: '문의/제보 상태 갱신 중 오류가 발생했습니다.'),
      );
    } catch (e) {
      return Result.error(
        DatabaseException('문의/제보 상태 갱신 중 오류가 발생했습니다.', cause: e),
      );
    }
  }
}
