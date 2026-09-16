
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