import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/mock_sketch.dart';
import '../../../domain/models/mock_user.dart';
import '../../../routing/routes.dart';
import 'feed_post_card.dart';

class FeedPage extends StatelessWidget {
  FeedPage({super.key});

  final List<MockSketch> _sampleData = [
    MockSketch(
      sketchId: 'test1',
      author: MockUser(id: '@edenjint3927', name: '후이'),
      createdAt: DateTime.now(),
      isJogging: false,
      location: '동대문구 휘경동',
      weather: '맑음',
      text: '뇨이 만나러 가는 길에 중랑천 따릉이~~',
      cheeredUser: [],
      comments: [],
    ),
    MockSketch(
      sketchId: 'test2',
      author: MockUser(id: '@daniil_a_np', name: '다닐루쉬카'),
      createdAt: DateTime(2026, 9, 1, 13, 42),
      isJogging: true,
      location: '동대문구 전농동',
      weather: '흐림',
      text: '생각보다 많이 걸었다...',
      cheeredUser: [],
      comments: [],
    ),
    MockSketch(
      sketchId: 'test3',
      author: MockUser(id: '@user_name', name: '테스트'),
      createdAt: DateTime(2026, 8, 1, 12, 00),
      isJogging: true,
      location: '임의의 장소',
      weather: '날씨',
      text: '60자 이내의 코멘트는 경우에 따라서 상당히 길어지기도 합니다. 그래서 다음 줄로 내려가는 경우도 발생하죠.',
      cheeredUser: [],
      comments: [],
    ),
    MockSketch(
      sketchId: 'test4',
      author: MockUser(id: '@user_name', name: '테스트'),
      createdAt: DateTime(2026, 8, 1, 12, 00),
      isJogging: true,
      location: '임의의 장소',
      weather: '날씨',
      text: '60자 이내의 코멘트',
      cheeredUser: [],
      comments: [],
    ),
    MockSketch(
      sketchId: 'test5',
      author: MockUser(id: '@user_name', name: '테스트'),
      createdAt: DateTime(2026, 8, 1, 12, 00),
      isJogging: true,
      location: '임의의 장소',
      weather: '날씨',
      text: '60자 이내의 코멘트',
      cheeredUser: [],
      comments: [],
    ),
    MockSketch(
      sketchId: 'test6',
      author: MockUser(id: '@user_name', name: '테스트'),
      createdAt: DateTime(2026, 8, 1, 12, 00),
      isJogging: true,
      location: '임의의 장소',
      weather: '날씨',
      text: '60자 이내의 코멘트',
      cheeredUser: [],
      comments: [],
    ),
    MockSketch(
      sketchId: 'test7',
      author: MockUser(id: '@user_name', name: '테스트'),
      createdAt: DateTime(2026, 8, 1, 12, 00),
      isJogging: true,
      location: '임의의 장소',
      weather: '날씨',
      text: '60자 이내의 코멘트',
      cheeredUser: [],
      comments: [],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('피드'),
        actions: [
          IconButton(
            onPressed: () {
              context.go(Routes.feedNotifications);
            },
            icon: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: _sampleData.length, // test
          itemBuilder: (context, index) {
            return FeedPost(sketch: _sampleData[index]);
          },
        ),
      ),
    );
  }
}
