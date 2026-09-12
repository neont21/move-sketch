import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermOfServicePage extends StatelessWidget {
  const TermOfServicePage({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: Icon(Icons.chevron_left),
          ),
          title: Text('이용약관'),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
          ),
        )
    );
  }
}
