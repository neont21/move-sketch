import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../../utils/date_time_utils.dart';
import '../enums/inquiry_status.dart';
import 'app_device_info.dart';

@immutable
class Inquiry {
  final String id;
  final String? userId;
  final String? userEmail;
  final AppDeviceInfo deviceInfo;
  final String content;
  final List<String> imageUrls;
  final InquiryStatus status;
  final String? adminNote;
  final DateTime createdAt;
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
      imageUrls: imageUrls,
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
}
