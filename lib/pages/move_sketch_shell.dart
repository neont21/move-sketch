import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MoveSketchShell extends StatelessWidget {
  final StatefulNavigationShell _navigationShell;
  const MoveSketchShell({super.key, required this._navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _navigationShell.currentIndex,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: '피드',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: '기록',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_circle_outlined),
            selectedIcon: Icon(Icons.account_circle),
            label: '나',
          ),
        ],
        onDestinationSelected: (index) {
          _navigationShell.goBranch(
            index,
            initialLocation: index == _navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}
