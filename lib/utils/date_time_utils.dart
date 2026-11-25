import 'package:intl/intl.dart';

/// 다양한 타입의 날짜 입력([value])을 [DateTime]으로 파싱하여 반환합니다.
///
/// Firestore `Timestamp`(패키지 의존성을 피하기 위한 덕 타이핑 검사), ISO-8601 문자열,
/// 밀리초 정수(Epoch ms)를 지원하며, 파싱에 실패하거나 `null`이면 [fallback] 또는 현재 시각을 반환합니다.
DateTime parseDateTime(dynamic value, {DateTime? fallback}) {
  if (value == null) {
    return fallback ?? DateTime.now();
  }
  if (value is DateTime) {
    return value;
  }
  if (value.runtimeType.toString() == 'Timestamp' ||
      value.runtimeType.toString() == '_Timestamp') {
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

/// 다양한 타입의 날짜 입력([value])을 [DateTime]으로 안전하게 파싱하며, 실패 시 `null`을 반환합니다.
DateTime? tryParseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;

  if (value.runtimeType.toString() == 'Timestamp' ||
      value.runtimeType.toString() == '_Timestamp') {
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

/// UI 및 파일명 표기에 사용되는 표준 날짜/시간 문자열 포맷을 제공하는 확장입니다.
extension DateTimeFormatting on DateTime {
  /// 24시간제 시:분 형식 문자열.
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// 점(.)으로 구분된 연.월.일 형식 문자열.
  String get formattedDateDot => DateFormat('yyyy.MM.dd').format(this);

  /// 하이픈(-)과 한국어 요일이 포함된 날짜 문자열.
  String get formattedDateWithDay =>
      DateFormat('yyyy-MM-dd (E)', 'ko').format(this);

  /// 피드 카드에 표시할 월/일, 요일 및 시각 문자열.
  String get formattedFeedTime =>
      DateFormat('MM/dd (E) HH:mm', 'ko').format(this);

  /// 섹션 헤더에 표시할 월, 일 및 전체 요일명 문자열.
  String get formattedHeaderDate => DateFormat('M월 d일 EEEE', 'ko').format(this);

  /// 달력 및 월별 통계 헤더용 연월 문자열.
  String get formattedYearMonth => DateFormat('yyyy년 M월', 'ko').format(this);

  /// 파일 이름 충돌 방지를 위한 타임스탬프 접미사 문자열.
  String get formattedFileTimestamp =>
      DateFormat('yyyyMMdd_HHmmss').format(this);
}
