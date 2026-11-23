import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../utils/date_time_utils.dart';
import '../enums/inquiry_status.dart';
import 'app_device_info.dart';

/// 사용자가 접수한 1:1 인앱 문의 및 시스템 버그 제보 내역을 나타내는 불변 모델입니다.
@immutable
class Inquiry {
  /// 문의 고유 식별자.
  final String id;

  /// 문의를 접수한 사용자의 고유 식별자.
  final String? userId;

  /// 문의를 접수한 사용자의 이메일 주소.
  final String? userEmail;

  /// 문의 접수 당시의 클라이언트 기기 환경 메타데이터.
  final AppDeviceInfo deviceInfo;

  /// 문의 및 오류 제보 상세 본문 내용.
  final String content;

  /// 문의 내용 이해를 돕기 위해 첨부된 증빙 이미지 스토리지 URL 목록.
  final List<String> imageUrls;

  /// 관리자의 현재 문의 접수 및 처리 대응 상태.
  final InquiryStatus status;

  /// 관리자가 접수 내역에 남긴 내부 처리 메모.
  final String? adminNote;

  /// 최초 문의 접수 일시.
  final DateTime createdAt;

  /// 관리자에 의한 상태 변경 또는 처리 최종 수정 일시.
  final DateTime? updatedAt;

  const Inquiry({
    required this.id,
    required this.deviceInfo,
    required this.content,
    required this.createdAt,
    this.userId,
    this.userEmail,
    this.imageUrls = const [],
    this.status = InquiryStatus.unconfirmed,
    this.adminNote,
    this.updatedAt,
  });

  /// 사용자의 입력값으로부터 UUID v7 식별자와 현재 시각을 부여하여 신규 [Inquiry]를 생성합니다.
  ///
  /// 본문([content])은 공백을 제거([String.trim])하며, 첨부 이미지 목록([imageUrls])은
  /// 외부 변조를 차단하기 위해 [List.unmodifiable] 불변 리스트로 래핑됩니다.
  factory Inquiry.create({
    required AppDeviceInfo deviceInfo,
    required String content,
    String? userId,
    String? userEmail,
    List<String> imageUrls = const [],
  }) {
    return Inquiry(
      id: const Uuid().v7(),
      userId: userId,
      userEmail: userEmail,
      deviceInfo: deviceInfo,
      content: content.trim(),
      imageUrls: List.unmodifiable(imageUrls),
      status: InquiryStatus.unconfirmed,
      createdAt: DateTime.now(),
    );
  }

  factory Inquiry.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final dynamic rawImageUrls = map['imageUrls'];
    final List<String> parsedImageUrls = rawImageUrls is List
        ? rawImageUrls.whereType<String>().toList()
        : const <String>[];

    final AppDeviceInfo parsedDeviceInfo = AppDeviceInfo(
      deviceModel: map['deviceModel'] as String? ?? 'Unknown Model',
      osVersion: map['osVersion'] as String? ?? 'Unknown OS',
      appVersion: map['appVersion'] as String? ?? 'Unknown App Version',
    );

    return Inquiry(
      id: documentId ?? (map['id'] as String? ?? ''),
      userId: map['userId'] as String?,
      userEmail: map['userEmail'] as String?,
      deviceInfo: parsedDeviceInfo,
      content: map['content'] as String? ?? '',
      imageUrls: List.unmodifiable(parsedImageUrls),
      status: InquiryStatus.fromString(map['status'] as String?),
      adminNote: map['adminNote'] as String?,
      createdAt: parseDateTime(map['createdAt']).toLocal(),
      updatedAt: tryParseDateTime(map['updatedAt'])?.toLocal(),
    );
  }

  Inquiry copyWith({
    List<String>? imageUrls,
    InquiryStatus? status,
    String? adminNote,
    DateTime? updatedAt,
  }) {
    return Inquiry(
      id: id,
      userId: userId,
      userEmail: userEmail,
      deviceInfo: deviceInfo,
      content: content,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'deviceModel': deviceInfo.deviceModel,
      'osVersion': deviceInfo.osVersion,
      'appVersion': deviceInfo.appVersion,
      'content': content,
      'imageUrls': imageUrls,
      'status': status.name,
      'adminNote': adminNote,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Inquiry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          userEmail == other.userEmail &&
          deviceInfo == other.deviceInfo &&
          content == other.content &&
          listEquals(imageUrls, other.imageUrls) &&
          status == other.status &&
          adminNote == other.adminNote &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;
  @override
  int get hashCode => Object.hash(
    id,
    userId,
    userEmail,
    deviceInfo,
    content,
    Object.hashAll(imageUrls),
    status,
    adminNote,
    createdAt,
    updatedAt,
  );
}
