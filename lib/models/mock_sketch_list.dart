import 'mock_sketch.dart';
import 'mock_user.dart';

class MockSketchList {
  List<MockSketch> sketches;

  MockSketchList({required this.sketches});

  factory MockSketchList.byUser(String userId) {
    return MockSketchList(
      sketches: [
        MockSketch(
          sketchId: 'test8',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트8',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test7',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트7',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test6',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트6',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test5',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트5',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test4',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트4',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test3',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트3',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test2',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트2',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
        MockSketch(
          sketchId: 'test1',
          author: MockUser(id: userId, name: '테스트'),
          createdAt: DateTime.now(),
          isJogging: true,
          text: '테스트1',
          location: '동대문구 휘경동',
          weather: '맑음',
          cheeredUser: [],
        ),
      ],
    );
  }
}
