import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'theme.dart';
import 'app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ko', null);
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

