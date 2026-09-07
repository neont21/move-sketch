import 'package:flutter/material.dart';
import 'theme.dart';

void main() {
  runApp(const MoveSketchApp());
}

class MoveSketchApp extends StatelessWidget {
  const MoveSketchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '무브스케치',
      theme: MoveSketchTheme.lightTheme,
      home: const Scaffold(),
    );
  }
}

