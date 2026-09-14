import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class SimpleBinaryToggle extends StatelessWidget {
  final bool toggle;
  final ValueChanged<bool> onChanged;
  const SimpleBinaryToggle({
    super.key,
    required this.toggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedToggleSwitch<bool>.size(
      current: toggle,
      values: const [false, true],
      onChanged: onChanged,
      selectedIconScale: 1.0,
      height: 28,
      indicatorSize: const Size(20, 20),
      style: ToggleStyle(
        backgroundColor: colorScheme.outline,
        borderColor: colorScheme.outline,
        indicatorColor: colorScheme.primary,
        borderRadius: BorderRadius.circular(80),
      ),
      styleBuilder: (value) => ToggleStyle(
        indicatorColor: value
            ? colorScheme.primary
            : colorScheme.tertiaryContainer,
      ),
      borderWidth: 4,
    );
  }
}
