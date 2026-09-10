import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/sketch_card.dart';
import '../widgets/path_tracker_view.dart';
import '../widgets/result_stats_view.dart';

class SessionResultPage extends StatelessWidget {
  final String _sessionId;
  const SessionResultPage({super.key, required this._sessionId});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              spacing: 20,
              children: [
                // 제목
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
                    // IconButton(
                    //   onPressed: () {},
                    //   icon: Icon(Icons.download),
                    //   color: colorScheme.tertiaryContainer,
                    //   style: IconButton.styleFrom(
                    //     backgroundColor: colorScheme.outline,
                    //   ),
                    // ),
                  ],
                ),
                // 사진
                SketchCard(
                  imageProvider: AssetImage('assets/sample_sketch.png'),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Icon(Icons.download),
                  label: Text('이미지 내려받기', style: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer,
                    foregroundColor: colorScheme.tertiaryContainer,
                  ),
                ),
                // 경로
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
                // 미션 요약
                // 세션 요약
                ResultStatsView(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(20),
        child:
            // 버튼
            Row(
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
                        context.go('/session-result/$_sessionId/share');
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
