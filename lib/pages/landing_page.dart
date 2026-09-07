import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Landing Page'),
        ElevatedButton(onPressed: () {
          context.go('/home');
        }, child: const Text('goto Home')),
      ],
    )));
  }
}
