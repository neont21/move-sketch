import 'package:flutter/material.dart';

class SessionResultPage extends StatelessWidget {
  final String sessionId;
  const SessionResultPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Center(child: Text('Session Result: $sessionId')));
  }
}
