import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import '../../../domain/models/enums/activity_type.dart';
import '../../../routing/routes.dart';
import '../../../utils/exceptions.dart';
import '../../../utils/result.dart';
import '../../auth/view_models/auth_viewmodel.dart';
import '../view_models/session_start_viewmodel.dart';
import 'mission_card.dart';

class SessionStartScreen extends ConsumerWidget {
  const SessionStartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(sessionStartViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.go(Routes.home);
          },
          icon: Icon(Icons.chevron_left),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            spacing: 20,
            children: [
              AnimatedToggleSwitch<ActivityType>.size(
                current: state.activityType,
                values: ActivityType.values,
                onChanged: (type) {
                  ref
                      .read(sessionStartViewModelProvider.notifier)
                      .setActivityType(type);
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
                  return Center(
                    child: Text(
                      value.label,
                      style: textTheme.bodyLarge?.copyWith(
                        color: (value == state.activityType)
                            ? colorScheme.onPrimary
                            : colorScheme.tertiaryFixed,
                      ),
                    ),
                  );
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: state.missions.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        title: Text('오늘의 미션', style: textTheme.headlineSmall),
                        trailing: Text(
                          '최대 두 개까지 선택 가능 (${state.selectedMissionIds.length}/2)',
                          style: textTheme.bodySmall,
                        ),
                      );
                    }
                    final mission = state.missions[index - 1];
                    final bool isSelected = state.selectedMissionIds.contains(
                      mission.id,
                    );
                    return MissionCard(
                      mission: mission,
                      description: state.getMissionDescription(mission),
                      isSelected: isSelected,
                      onTap: () {
                        ref
                            .read(sessionStartViewModelProvider.notifier)
                            .toggleMission(mission.id);
                      },
                    );
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          final user = await ref.read(
                            authViewModelProvider.future,
                          );
                          if (user == null) {
                            return;
                          }

                          final result = await ref
                              .read(sessionStartViewModelProvider.notifier)
                              .startSession(user.uid);

                          if (!context.mounted) {
                            return;
                          }

                          switch (result) {
                            case Ok():
                              context.go(Routes.sessionTracking);
                            case Error(:final error):
                              final errorMessage = error is AppException
                                  ? error.message
                                  : '세션 시작 중 오류가 발생했습니다.';
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(errorMessage)),
                              );
                          }
                        },
                  child: state.isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text('${state.activityType.label} 시작'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
