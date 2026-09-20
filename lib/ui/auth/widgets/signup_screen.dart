import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routing/routes.dart';
import '../../core/widgets/labeled_text_form_field.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _showPassword = false;
  bool _showCheckPassword = false;
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text('계정 만들기')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            spacing: 20,
            mainAxisSize: MainAxisSize.min,
            children: [
              LabeledTextFormField(
                labelText: '닉네임',
                hintText: '친구에게 보일 이름을 10자 이내로 입력해 주세요',
                maxLength: 10,
              ),
              LabeledTextFormField(
                labelText: '아이디',
                hintText: '로그인에 사용할 아이디를 입력해 주세요',
              ),
              LabeledTextFormField(
                inputType: TextInputType.emailAddress,
                labelText: '이메일',
                hintText: '계정 인증에 사용할 이메일을 입력해 주세요',
              ),
              LabeledTextFormField(
                inputType: TextInputType.visiblePassword,
                labelText: '비밀번호',
                hintText: '영문과 숫자를 섞어 8자 이상 입력해 주세요',
                showPassword: _showPassword,
                toggleVisibility: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
              LabeledTextFormField(
                inputType: TextInputType.visiblePassword,
                labelText: '비밀번호 확인',
                hintText: '비밀번호를 다시 입력해 주세요',
                showPassword: _showCheckPassword,
                toggleVisibility: () {
                  setState(() {
                    _showCheckPassword = !_showCheckPassword;
                  });
                },
              ),
              Row(
                children: [
                  Checkbox(
                    value: _agree,
                    onChanged: (newValue) {
                      setState(() {
                        _agree = newValue ?? !_agree;
                      });
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      context.push(Routes.tos);
                    },
                    child: Text(
                      '이용약관',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('과 ', style: textTheme.labelMedium),
                  GestureDetector(
                    onTap: () {
                      context.push(Routes.privacy);
                    },
                    child: Text(
                      '개인정보 처리 방침',
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('에 동의해요', style: textTheme.labelMedium),
                  Text('(필수)', style: textTheme.labelMedium),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _agree
                      ? () {
                          // FIXME: only if signup complete
                          context.go(Routes.signupComplete);
                        }
                      : null,
                  child: Text('가입하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
