import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../widgets/mission_card.dart';
import '../models/mock_mission.dart';

class SessionStartPage extends StatefulWidget {
  const SessionStartPage({super.key});

  @override
  State<SessionStartPage> createState() => _SessionStartPageState();
}

class _SessionStartPageState extends State<SessionStartPage> {
  bool _isJogging = true;

  final List<MockMission> _joggingMissions = [
    MockMission(title: '거리', description: '최근 평균 3.2km', parts: '배경'),
    MockMission(title: '페이스', description: '최근 평균 7분 20초/km', parts: '표정'),
    MockMission(title: '지속 시간', description: '최근 평균 22분', parts: '의상'),
    MockMission(title: '경로 탐색', description: '최근 평균 새 도로 0.8km', parts: '소품'),
    MockMission(title: '인터벌', description: '최근 평균 2회 반복', parts: '이펙트'),
  ];

  final List<MockMission> _ridingMissions = [
    MockMission(title: '거리', description: '최근 평균 6.5km', parts: '배경'),
    MockMission(title: '속도', description: '최근 평균 18km/h', parts: '표정'),
    MockMission(title: '지속 시간', description: '최근 평균 25분', parts: '의상'),
    MockMission(title: '경로 탐색', description: '최근 평균 새 도로 1.4km', parts: '소품'),
    MockMission(title: '스프린트', description: '최근 평균 1.6회 반복', parts: '이펙트'),
  ];

  late List<MockMission> _currentMissions;
  final List<int> _selectedIndices = [];
  void _handleCardTapped(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        if (_selectedIndices.length >= 2) {
          _selectedIndices.removeAt(0);
        }
        _selectedIndices.add(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _currentMissions = _isJogging ? _joggingMissions : _ridingMissions;
  }

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go('/home');
          },
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('뒤로'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            spacing: 20,
            children: [
              AnimatedToggleSwitch<bool>.size(
                current: _isJogging,
                values: const [true, false],
                onChanged: (val) {
                  setState(() {
                    _isJogging = val;
                    _currentMissions = _isJogging
                        ? _joggingMissions
                        : _ridingMissions;
                  });
                },
                selectedIconScale: 1.0,
                height: 48,
                indicatorSize: const Size(120, 40),
                style: ToggleStyle(
                  backgroundColor: colorScheme.outline,
                  borderColor: colorScheme.outline,
                  indicatorColor: colorScheme.primary,
                  borderRadius: BorderRadius.circular(80),
                ),
                borderWidth: 4,
                iconBuilder: (value) {
                  final text = value ? '조깅' : '라이딩';
                  return Center(
                    child: Text(
                      text,
                      style: textTheme.bodyLarge?.copyWith(
                        color: (value == _isJogging)
                            ? colorScheme.onPrimary
                            : colorScheme.tertiaryFixed,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _currentMissions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: Text('오늘의 미션', style: textTheme.headlineSmall),
                        trailing: Text(
                          '최대 두 개까지 선택 가능 (${_selectedIndices.length}/2)',
                          style: textTheme.bodySmall,
                        ),
                      );
                    }
                    final mission = _currentMissions[index - 1];
                    final bool isSelected = _selectedIndices.contains(
                      index - 1,
                    );
                    return MissionCard(
                      mission: mission,
                      isSelected: isSelected,
                      onTap: () => _handleCardTapped(index - 1),
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/session-tracking');
                  },
                  child: Text(_isJogging ? '조깅 시작' : '라이딩 시작'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
