import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ModifyPasswordPage extends StatefulWidget {
  const ModifyPasswordPage({super.key});

  @override
  State<ModifyPasswordPage> createState() => _ModifyPasswordPageState();
}

class _ModifyPasswordPageState extends State<ModifyPasswordPage> {
  bool _showPassword = false;
  bool _showNewPassword = false;
  bool _showCheckPassword = false;

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
          icon: Icon(Icons.chevron_left, color: colorScheme.tertiary),
        ),
        title: Text('비밀번호 변경'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Form(
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  keyboardType: TextInputType.visiblePassword,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: '기존 비밀번호',
                    labelStyle: textTheme.labelLarge,
                    hintText: '기존 비밀번호',
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
                  obscureText: !_showNewPassword,
                  decoration: InputDecoration(
                    labelText: '새 비밀번호',
                    labelStyle: textTheme.labelLarge,
                    hintText: '새 비밀번호',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiaryContainer,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showNewPassword = !_showNewPassword;
                        });
                      },
                      icon: Icon(
                        _showNewPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: colorScheme.tertiaryContainer,
                      ),
                    ),
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
                  obscureText: !_showCheckPassword,
                  decoration: InputDecoration(
                    labelText: '새 비밀번호 확인',
                    labelStyle: textTheme.labelLarge,
                    hintText: '새 비밀번호 확인',
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.tertiaryContainer,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _showCheckPassword = !_showCheckPassword;
                        });
                      },
                      icon: Icon(
                        _showCheckPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: colorScheme.tertiaryContainer,
                      ),
                    ),
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
                Text(
                  '영문과 숫자를 섞어 8자 이상으로 정해 주세요.',
                  style: textTheme.labelMedium,
                ),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('비밀번호가 변경되었습니다.'),
                          duration: Duration(seconds: 3),
                        ),
                      );
                      context.go('/auth/login');
                    },
                    child: Text('비밀번호 변경'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
