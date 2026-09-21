import 'package:flutter/foundation.dart';
import '../../../utils/date_time_utils.dart';

@immutable
class WeatherInfo {
  final String condition;
  final double temperature;
  final String iconCode;
  final String cityName;
  final DateTime observedAt;

  const WeatherInfo({
    required this.condition,
    required this.temperature,
    required this.iconCode,
    required this.cityName,
    required this.observedAt,
  });

  String get iconUrl => 'https://openweathermap.org/img/wn/$iconCode@2x.png';

  String get shortSummary => '$condition ${temperature.round()}℃';

  String get summaryWithCity => '$cityName $condition ${temperature.round()}℃';

  String get recommendation {
    if (condition.contains('뇌우') ||
        condition.contains('번개') ||
        condition.contains('천둥')) {
      return '낙뢰 주의 · 실내 활동 추천';
    }
    if (condition.contains('눈')) {
      return '눈길 미끄럼 주의';
    }
    if (condition.contains('비') || condition.contains('소나기')) {
      return '빗길 미끄럼 주의';
    }
    if (condition.contains('안개')) {
      return '안개 주의 · 시야 확보';
    }
    if (temperature >= 33.0) {
      return '폭염 주의 · 야외 활동 자제';
    }
    if (temperature >= 28.0) {
      return '무더위 · 수분 보충';
    }
    if (temperature <= -5.0) {
      return '한파 주의 · 방한 철저';
    }
    if (temperature <= 5.0) {
      return '쌀쌀함 · 준비운동 필수';
    }
    if (temperature >= 12.0 && temperature <= 22.0) {
      return '달리기 딱 좋은 날!';
    }
    return '움직이기 좋아요';
  }

  factory WeatherInfo.fromOpenWeatherMap(Map<String, dynamic> json) {
    final weatherList = (json['weather'] as List<dynamic>?) ?? [];
    final weatherMap = weatherList.isNotEmpty
        ? (weatherList.first as Map<String, dynamic>?) ?? {}
        : <String, dynamic>{};
    final mainMap = (json['main'] as Map<String, dynamic>?) ?? {};
    final dtSec = json['dt'] as int?;
    final observedAt = dtSec != null
        ? DateTime.fromMillisecondsSinceEpoch(
            dtSec * 1000,
            isUtc: true,
          ).toLocal()
        : DateTime.now();
    return WeatherInfo(
      condition:
          (weatherMap['description'] as String?) ??
          (weatherMap['main'] as String?) ??
          '맑음',
      temperature: ((mainMap['temp'] as num?) ?? 20.0).toDouble(),
      iconCode: (weatherMap['icon'] as String?) ?? '01d',
      cityName: (json['name'] as String?) ?? '',
      observedAt: observedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'condition': condition,
      'temperature': temperature,
      'iconCode': iconCode,
      'cityName': cityName,
      'observedAt': observedAt.toUtc().toIso8601String(),
    };
  }

  factory WeatherInfo.fromMap(Map<String, dynamic> map) {
    return WeatherInfo(
      condition: map['condition'] as String? ?? '맑음',
      temperature: ((map['temperature'] as num?) ?? 20.0).toDouble(),
      iconCode: map['iconCode'] as String? ?? '01d',
      cityName: map['cityName'] as String? ?? '',
      observedAt: parseDateTime(map['observedAt'] ?? map['dateTime']).toLocal(),
    );
  }

  WeatherInfo copyWith({
    String? condition,
    double? temperature,
    String? iconCode,
    String? cityName,
    DateTime? observedAt,
  }) {
    return WeatherInfo(
      condition: condition ?? this.condition,
      temperature: temperature ?? this.temperature,
      iconCode: iconCode ?? this.iconCode,
      cityName: cityName ?? this.cityName,
      observedAt: observedAt ?? this.observedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherInfo &&
          runtimeType == other.runtimeType &&
          condition == other.condition &&
          temperature == other.temperature &&
          iconCode == other.iconCode &&
          cityName == other.cityName &&
          observedAt == other.observedAt;

  @override
  int get hashCode =>
      Object.hash(condition, temperature, iconCode, cityName, observedAt);
}
