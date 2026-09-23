import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('개인정보 처리방침')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(),
      ),
    );
  }
}
