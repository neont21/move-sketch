import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';

class SignupCompletePage extends StatelessWidget {
  const SignupCompletePage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            spacing: 20,
            children: [
              Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  color: colorScheme.primary,
                  size: 32,
                ),
              ),
              Text('계정이 만들어졌어요', style: textTheme.displaySmall),
              Text(
                '방금 보낸 메일에서 인증 링크를 눌러 주시면\n로그인하실 수 있어요.',
                style: textTheme.labelMedium,
                textAlign: TextAlign.center,
              ),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.outline,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Text('user@example.com', style: textTheme.labelLarge),
              ),
              Spacer(),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(Routes.login);
                  },
                  child: Text('로그인 하러 가기'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.surfaceContainer
                  ),
                  child: Text('인증 메일 다시 보내기', style: textTheme.labelLarge,),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
