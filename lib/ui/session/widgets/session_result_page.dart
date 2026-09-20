import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'path_tracker_view.dart';
import 'sketch_card.dart';
import 'result_stats_view.dart';

class SessionResultPage extends StatelessWidget {
  final String sessionId;
  const SessionResultPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        Text('조깅 · 17:12–17:44', style: textTheme.bodySmall),
                        Text('오늘도 수고했어요', style: textTheme.displaySmall),
                      ],
                    ),
                  ],
                ),
                SketchCard(
                  imageProvider: AssetImage('assets/sample_sketch.png'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download),
                  label: Text(
                    '이미지 내려받기',
                    style: textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer,
                    foregroundColor: colorScheme.tertiaryContainer,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        '이동 경로',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: 0.9,
                  child: PathTrackerView(),
                ),
                ResultStatsView(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          spacing: 20,
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.outline,
                  ),
                  child: Text(
                    '홈으로',
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.tertiaryContainer,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/session-result/$sessionId/share');
                  },
                  child: Text('기록하기'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
