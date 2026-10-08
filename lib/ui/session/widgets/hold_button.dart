import 'package:flutter/material.dart';

class HoldButton extends StatefulWidget {
  final String title;
  final VoidCallback onActionTriggered;
  final VoidCallback? onEarlyRelease;

  const HoldButton({
    super.key,
    required this.title,
    required this.onActionTriggered,
    this.onEarlyRelease,
  });

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onActionTriggered();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) {
        if (!_animationController.isCompleted) {
          widget.onEarlyRelease?.call();
        }
        _animationController.reverse();
      },
      onTapCancel: () {
        if (!_animationController.isCompleted) {
          widget.onEarlyRelease?.call();
        }
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              IgnorePointer(
                child: ElevatedButton(
                  onPressed: () {},
                  clipBehavior: Clip.antiAlias,
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    padding: EdgeInsets.zero,
                  ),
                  child: const SizedBox.shrink(),
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(36),
                child: LinearProgressIndicator(
                  value: _animationController.value,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primaryContainer,
                  ),
                ),
              ),
              Center(
                child: Text(
                  widget.title,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
