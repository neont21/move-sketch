import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/material.dart';

class SimpleBinaryToggle extends StatelessWidget {
  final bool _toggle;
  final Function(bool) _onChanged;
  const SimpleBinaryToggle({
    super.key,
    required this._toggle,
    required this._onChanged,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedToggleSwitch<bool>.size(
      current: _toggle,
      values: const [false, true],
      onChanged: _onChanged,
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
