import 'package:flutter/material.dart';
import 'simulation_item.dart';

class VersionSimulationCard extends StatelessWidget {
  final int latestBuildNumber;
  final int minRequiredBuildNumber;

  const VersionSimulationCard({
    super.key,
    required this.latestBuildNumber,
    required this.minRequiredBuildNumber,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final bool isForceUpdateAll =
        minRequiredBuildNumber > 0 &&
        latestBuildNumber > 0 &&
        minRequiredBuildNumber == latestBuildNumber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isForceUpdateAll
              ? colorScheme.error.withValues(alpha: 0.5)
              : colorScheme.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 18,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                '동작 방식 실시간 시뮬레이션',
                style: textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SimulationItem(
            badgeText: '강제 업데이트',
            badgeColor: colorScheme.error,
            conditionText: '빌드 < $minRequiredBuildNumber',
            descriptionText: '앱 사용 전면 차단 (스토어 이동 필수)',
          ),
          const SizedBox(height: 8),
          SimulationItem(
            badgeText: '권장 업데이트',
            badgeColor: colorScheme.tertiary,
            conditionText:
            '$minRequiredBuildNumber ≤ 빌드 < $latestBuildNumber',
            descriptionText: '업데이트 다이얼로그 노출 ("다음에 하기" 가능)',
          ),
          const SizedBox(height: 8),
          SimulationItem(
            badgeText: '최신 버전',
            badgeColor: colorScheme.primary,
            conditionText: '빌드 ≥ $latestBuildNumber',
            descriptionText: '팝업 없이 앱 홈으로 즉시 진입',
          ),
          if (isForceUpdateAll) ...[
            const SizedBox(height: 12),
            Text(
              '현재 설정은 최신 버전 미만의 모든 구버전 사용자에게 즉시 강제 업데이트가 적용됩니다.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
