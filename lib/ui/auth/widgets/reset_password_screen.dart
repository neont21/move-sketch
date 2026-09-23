import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('비밀번호 재설정')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('가입할 때 쓴 이메일로 재설정 링크를 보내 드려요.'),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: '이메일',
                hintText: 'user@example.com',
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(onPressed: () {}, child: Text('재설정 링크 받기')),
            ),
            Text(
              '소셜 로그인으로 가입하셨다면 비밀번호가 없으니 소셜 로그인 버튼을 이용해 주세요.',
              style: textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}
