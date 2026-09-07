import 'package:flutter/material.dart';

class UserProfilePage extends StatelessWidget {
  final String userId;
  const UserProfilePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Placeholder(child: Center(child: Text('Profile: $userId')));
  }
}
