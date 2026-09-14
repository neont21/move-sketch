import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../widgets/labeled_text_form_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: Column(
              spacing: 12,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 40,
                        spreadRadius: -32,
                        color: colorScheme.tertiaryContainer,
                      ),
                    ],
                  ),
                  child: SvgPicture.asset('assets/brand/logo-mark.svg'),
                ),
                Text('가볍게 시작해 볼까요?', style: textTheme.displaySmall),
                Text(
                  '오늘의 조깅과 라이딩을 기록해요',
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: textTheme.bodyLarge?.fontSize,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () {
                    // TODO implement Google login
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.tertiaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.g_mobiledata,
                          size: textTheme.displayMedium?.fontSize,
                        ),
                        Text('Google로 계속하기'),
                      ],
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // TODO implement Apple login
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: colorScheme.surface,
                    foregroundColor: colorScheme.tertiaryContainer,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.apple,
                          size: textTheme.displayMedium?.fontSize,
                        ),
                        Text('Apple로 계속하기'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    spacing: 20,
                    children: [
                      Expanded(child: Divider()),
                      Text('혹은', style: textTheme.labelMedium),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
                LabeledTextFormField(labelText: '아이디', hintText: '아이디'),
                LabeledTextFormField(
                  inputType: TextInputType.visiblePassword,
                  labelText: '비밀번호',
                  hintText: '비밀번호',
                  showPassword: _showPassword,
                  toggleVisibility: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      // FIXME: only if login success
                      context.go('/home');
                    },
                    child: Text('로그인'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('아직 계정이 없나요?', style: textTheme.labelMedium),
                    GestureDetector(
                      onTap: () {
                        context.push('/auth/signup');
                      },
                      child: Text(
                        '회원가입',
                        style: textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textTheme.labelLarge?.color,
                        ),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    context.push('/auth/password');
                  },
                  child: Text('비밀번호를 잊으셨나요?', style: textTheme.labelMedium),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
