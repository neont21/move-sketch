import 'package:flutter/foundation.dart';

import '../../../domain/models/enums/inquiry_status.dart';
import '../../../domain/models/system/inquiry.dart';
import '../../../utils/result.dart';

/// 인앱 문의 및 버그 제보의 접수와 관리자 상태 처리를 추상화한 저장소 인터페이스입니다.
abstract interface class InquiryRepository {
  /// 첨부 이미지([imageBytesList])와 함께 인앱 문의/제보([inquiry])를 접수합니다.
  Future<Result<void>> submitInquiry(
    Inquiry inquiry, {
    List<Uint8List> imageBytesList = const [],
  });

  /// 접수된 문의/제보 목록을 조회합니다. (관리자 전용, [statusFilter]로 상태 필터링 가능)
  Future<Result<List<Inquiry>>> getInquiries({InquiryStatus? statusFilter});

  /// 지정된 제보([inquiryId])의 대응 상태([status]) 및 내부 메모([adminNote])를 갱신합니다. (관리자 전용)
  Future<Result<void>> updateInquiryStatus(
    String inquiryId,
    InquiryStatus status, {
    String? adminNote,
  });
}
