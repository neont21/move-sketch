import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: Icon(Icons.chevron_left),
        ),
        title: Text('비밀번호 재설정'),
      ),
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
                labelStyle: textTheme.labelLarge,
                hintText: 'user@example.com',
                hintStyle: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.tertiaryContainer,
                ),
                filled: true,
                fillColor: colorScheme.surface,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(40),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: colorScheme.outline),
                  borderRadius: BorderRadius.circular(40),
                ),
                counterStyle: textTheme.labelSmall,
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                } ,
                child: Text('재설정 링크 받기'),
              ),
            ),
            Text('소셜 로그인으로 가입하셨다면 비밀번호가 없으니 소셜 로그인 버튼을 이용해 주세요.', style: textTheme.labelMedium,),
          ],
        ),
      ),
    );
  }
}
