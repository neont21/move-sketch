
import 'package:intl/intl.dart';

DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
  if (value == null) {
    return fallback ?? DateTime.now();
  }
  if (value is DateTime) {
    return value;
  }
  if (value.runtimeType.toString() == 'Timestamp' || value.runtimeType.toString() == '_Timestamp') {
    return (value as dynamic).toDate() as DateTime;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? (fallback ?? DateTime.now());
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  return fallback ?? DateTime.now();
}

DateTime? tryParseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  if (value.runtimeType.toString() == 'Timestamp' || value.runtimeType.toString() == '_Timestamp') {
    return (value as dynamic).toDate() as DateTime;
  }
  if (value is String) {
    return DateTime.tryParse(value);
  }
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  return null;
}

extension DateTimeFormatting on DateTime {
  String get formattedTime => DateFormat('HH:mm').format(this);
  String get formattedDateDot => DateFormat('yyyy.MM.dd').format(this);
  String get formattedDateWithDay =>
      DateFormat('yyyy-MM-dd (E)', 'ko').format(this);
  String get formattedFeedTime =>
      DateFormat('MM/dd (E) HH:mm', 'ko').format(this);
  String get formattedHeaderDate =>
      DateFormat('M월 d일 EEEE', 'ko').format(this);
  String get formattedYearMonth =>
      DateFormat('yyyy년 M월', 'ko').format(this);
}