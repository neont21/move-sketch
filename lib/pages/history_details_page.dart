import 'package:flutter/material.dart';

class HistoryDetailsPage extends StatelessWidget {
  final String sessionId;
  const HistoryDetailsPage({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context) {
    return Placeholder(
      child: Center(child: Text('History Details: $sessionId')),
    );
  }
}
