import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/sketch_card.dart';
import '../widgets/weekly_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String _formattedDate;

  @override
  void initState() {
    super.initState();

    _formattedDate = DateFormat('M월 d일 EEEE', 'ko').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 12,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(_formattedDate, style: textTheme.bodySmall),
                      Text('오늘도 가볍게\n움직여 볼까요?', style: textTheme.displaySmall),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.go('/me');
                    },
                    child: CircleAvatar(
                      radius: 36,
                      backgroundImage: const AssetImage(
                        'assets/default_profile.png',
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 8.0,
                children: [
                  Icon(Icons.sunny, color: colorScheme.primary),
                  Text('서울 맑음 18℃ · 움직이기 좋아요', style: textTheme.bodySmall),
                ],
              ),
              Expanded(
                child: Transform.rotate(
                  angle: 0.05,
                  child: SketchCard(
                    imageProvider: AssetImage('assets/sample_sketch.png'),
                    caption: '첫 장을 기다리는 중',
                    isHome: true,
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/session-start');
                  },
                  child: Text('세션 시작하기'),
                ),
              ),
              WeeklyIndicator(isDone: List.filled(7, false)),
            ],
          ),
        ),
      ),
    );
  }
}
