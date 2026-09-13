import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:move_sketch/widgets/sketch_card.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;
    ;
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
                    child: SvgPicture.asset('assets/brand/logo-mark.svg'),
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
              Divider(color: Colors.transparent, height: 20),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/auth/login');
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
