import 'package:flutter/material.dart';

class SessionSharePage extends StatelessWidget {
  final String sessionId;
  const SessionSharePage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Center(child: Text('Share: $sessionId')));
  }
}
