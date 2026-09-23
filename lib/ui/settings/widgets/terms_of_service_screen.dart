import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('이용약관')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(),
      ),
    );
  }
}
