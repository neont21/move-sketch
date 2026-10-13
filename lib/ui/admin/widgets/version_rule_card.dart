import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'version_simulation_card.dart';

class VersionRuleCard extends StatelessWidget {
  final TextEditingController latestVersionController;
  final TextEditingController latestBuildNumberController;
  final TextEditingController minRequiredVersionController;
  final TextEditingController minRequiredBuildNumberController;
  final VoidCallback onValuesChanged;

  const VersionRuleCard({
    super.key,
    required this.latestVersionController,
    required this.latestBuildNumberController,
    required this.minRequiredVersionController,
    required this.minRequiredBuildNumberController,
    required this.onValuesChanged,
  });

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final int parsedLatestBuild =
        int.tryParse(latestBuildNumberController.text.trim()) ?? 1;
    final int parsedMinRequiredBuild =
        int.tryParse(minRequiredBuildNumberController.text.trim()) ?? 1;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.verified_outlined,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '버전 및 빌드 번호 설정',
                  style: textTheme.bodyLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: latestVersionController,
                    decoration: const InputDecoration(
                      labelText: '최신 버전명 *',
                      hintText: '1.0.0',
                      helperText: '스토어에 배포된 최신 버전',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '최신 버전명을 입력해 주세요.';
                      }
                      if (!RegExp(r'^\d+\.\d+\.\d+').hasMatch(value.trim())) {
                        return 'x.y.z 형식이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: latestBuildNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => onValuesChanged(),
                    decoration: const InputDecoration(
                      labelText: '최신 빌드 번호 *',
                      hintText: '1',
                      helperText: '정수형 빌드 번호',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '필수 항목입니다.';
                      }
                      final number = int.tryParse(value.trim());
                      if (number == null || number <= 0) {
                        return '1 이상의 정수여야 합니다.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: minRequiredVersionController,
                    decoration: const InputDecoration(
                      labelText: '최소 요구 버전명 *',
                      hintText: '1.0.0',
                      helperText: '강제 업데이트 기준 버전',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '최소 요구 버전명을 입력해 주세요.';
                      }
                      if (!RegExp(r'^\d+\.\d+\.\d+').hasMatch(value.trim())) {
                        return 'x.y.z 형식이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: minRequiredBuildNumberController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) => onValuesChanged(),
                    decoration: const InputDecoration(
                      labelText: '최소 요구 빌드 번호 *',
                      hintText: '1',
                      helperText: '강제 업데이트 기준 빌드',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '필수 항목입니다.';
                      }
                      final number = int.tryParse(value.trim());
                      if (number == null || number <= 0) {
                        return '1 이상의 정수여야 합니다.';
                      }
                      final latest = int.tryParse(
                        latestBuildNumberController.text.trim(),
                      );
                      if (latest != null && number > latest) {
                        return '최신 빌드($latest) 이하 값이어야 합니다.';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            VersionSimulationCard(
              latestBuildNumber: parsedLatestBuild,
              minRequiredBuildNumber: parsedMinRequiredBuild,
            ),
          ],
        ),
      ),
    );
  }
}
