import 'package:flutter/material.dart';

class BlinkingDurationText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final bool isBlinking;

  const BlinkingDurationText({
    super.key,
    required this.text,
    this.style,
    required this.isBlinking,
  });

  @override
  State<BlinkingDurationText> createState() => _BlinkingDurationTextState();
}

class _BlinkingDurationTextState extends State<BlinkingDurationText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.25).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isBlinking) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant BlinkingDurationText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isBlinking != oldWidget.isBlinking) {
      if (widget.isBlinking) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.value = 0.0;
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBlinking) {
      return Text(widget.text, style: widget.style);
    }

    return FadeTransition(
      opacity: _opacityAnimation,
      child: Text(widget.text, style: widget.style),
    );
  }
}
