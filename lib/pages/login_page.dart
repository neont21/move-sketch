import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: Column(
              spacing: 12,
              children: [
                Container(
                  width: 100, height: 100,
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(blurRadius: 40, spreadRadius: -32, color: colorScheme.tertiaryContainer)],
                    ),
                    child: SvgPicture.asset('assets/brand/logo-mark.svg')),
                Text('가볍게 시작해 볼까요?', style: textTheme.displaySmall),
                Text(
                  '오늘의 조깅과 라이딩을 기록해요',
                  style: textTheme.labelMedium?.copyWith(
                    fontSize: textTheme.bodyLarge?.fontSize,
                  ),
                ),
                Divider(color: Colors.transparent,),
                OutlinedButton(
                  onPressed: () {
                    // TODO implement Google login
                  },
                  style: ElevatedButton.styleFrom(
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
                  style: ElevatedButton.styleFrom(
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
                      Text('혹은', style: textTheme.labelMedium,),
                      Expanded(child: Divider()),
                    ],
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: '이메일',
                    labelStyle: textTheme.labelLarge,
                    hintText: '이메일',
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
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: '비밀번호',
                    labelStyle: textTheme.labelLarge,
                    hintText: '비밀번호',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiaryContainer,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                      icon: Icon(
                        _showPassword ? Icons.visibility : Icons.visibility_off,
                        color: colorScheme.tertiaryContainer,
                      ),
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
                  ),
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
                Divider(color: Colors.transparent,),
                Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('아직 계정이 없나요?', style: textTheme.labelMedium,),
                    GestureDetector(
                      onTap: () {
                        context.go('/auth/signup');
                      },
                      child: Text('회원가입', style: textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: textTheme.labelLarge?.color,
                      ),),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    context.go('/auth/password');
                  },
                  child: Text('비밀번호를 잊으셨나요?', style: textTheme.labelMedium
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
