import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../config/assets.dart';
import '../../../routing/routes.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FIXME sample images
              Row(
                children: [
                  SizedBox(
                    height: 80,
                    width: 80,
                    child: SvgPicture.asset(Assets.logoMark),
                  ),
                  Text('무브스케치', style: textTheme.displayLarge),
                ],
              ),
              Text(
                '가볍게 움직이고 그림 한 장으로 남겨요',
                style: textTheme.labelMedium?.copyWith(
                  fontSize: textTheme.labelLarge?.fontSize,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(Routes.login);
                  },
                  child: Text('시작하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
