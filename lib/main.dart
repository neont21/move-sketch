import 'package:flutter/material.dart';
import 'theme.dart';
import 'package:move_sketch/app_router.dart';

void main() {
  runApp(const MoveSketchApp());
}

class MoveSketchApp extends StatelessWidget {
  const MoveSketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      title: '무브스케치',
      theme: MoveSketchTheme.lightTheme,
    );
  }
}

