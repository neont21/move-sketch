import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SimpleBinaryToggle extends StatefulWidget {
  final bool toggle;
  final ValueChanged<bool> onChanged;
  const SimpleBinaryToggle({
    super.key,
    required this.toggle,
    required this.onChanged,
  });

  @override
  State<SimpleBinaryToggle> createState() => _SimpleBinaryToggleState();
}

class _SimpleBinaryToggleState extends State<SimpleBinaryToggle> {
  int? _activePointerId;
  Offset? _pointerDownPosition;
  bool _isDragging = false;

  void _resetPointerState() {
    _activePointerId = null;
    _pointerDownPosition = null;
    _isDragging = false;
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        if (_activePointerId == null) {
          _activePointerId = event.pointer;
          _pointerDownPosition = event.position;
          _isDragging = false;
        }
      },
      onPointerMove: (event) {
        if (event.pointer == _activePointerId && _pointerDownPosition != null) {
          final double distance =
              (event.position - _pointerDownPosition!).distance;

          if (distance > kTouchSlop) {
            _isDragging = true;
          }
        }
      },
      onPointerUp: (event) {
        if (event.pointer == _activePointerId) {
          if (!_isDragging) {
            HapticFeedback.lightImpact();
            widget.onChanged(!widget.toggle);
          }
          _resetPointerState();
        }
      },
      onPointerCancel: (event) {
        if (event.pointer == _activePointerId) {
          _resetPointerState();
        }
      },
      child: AnimatedToggleSwitch<bool>.size(
        current: widget.toggle,
        values: const [false, true],
        onChanged: (value) {
          HapticFeedback.lightImpact();
          widget.onChanged(value);
        },
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
      ),
    );
  }
}
