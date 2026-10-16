import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

import '../../../config/assets.dart';

class MoveSketchShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MoveSketchShell({super.key, required this.navigationShell});

  static const _navItems = [
    if (!kIsWeb)
      (icon: Icons.home_outlined, selectedIcon: Icons.home, label: '홈'),
    (icon: Icons.groups_outlined, selectedIcon: Icons.groups, label: '피드'),
    (icon: Icons.history_outlined, selectedIcon: Icons.history, label: '기록'),
    (
      icon: Icons.account_circle_outlined,
      selectedIcon: Icons.account_circle,
      label: '나',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 768;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: navigationShell.currentIndex,
                  onDestinationSelected: (index) {
                    navigationShell.goBranch(
                      index,
                      initialLocation: index == navigationShell.currentIndex,
                    );
                  },
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SvgPicture.asset(
                      Assets.logoMark,
                      width: 36,
                      height: 36,
                    ),
                  ),
                  destinations: [
                    for (final item in _navItems)
                      NavigationRailDestination(
                        icon: Icon(item.icon),
                        selectedIcon: Icon(item.selectedIcon),
                        label: Text(item.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1, thickness: 1),
                Expanded(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 840),
                      child: navigationShell,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: navigationShell,
          bottomNavigationBar: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            destinations: [
              for (final item in _navItems)
                NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
            ],
            onDestinationSelected: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        );
      },
    );
  }
}
