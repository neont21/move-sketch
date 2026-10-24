import 'package:flutter/foundation.dart';
import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/result.dart';

abstract interface class InquiryRepository {
  /// 인앱 제보를 접수한다.
  Future<Result<void>> submitInquiry(
    Inquiry inquiry, {
    List<Uint8List> imageBytesList = const [],
  });

  /// [관리] 접수된 제보 목록을 조회한다.
  Future<Result<List<Inquiry>>> getInquiries({InquiryStatus? statusFilter});

  /// [관리] 제보 대응 상태 및 내부 메모를 갱신한다.
  Future<Result<void>> updateInquiryStatus(
    String inquiryId,
    InquiryStatus status, {
    String? adminNote,
  });
}
