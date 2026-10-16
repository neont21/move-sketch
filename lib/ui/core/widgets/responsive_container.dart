import 'package:flutter/material.dart';

class ResponsiveContainer extends StatelessWidget {
  static const double defaultContentWidth = 840.0;
  static const double defaultTextWidth = 800.0;
  static const double defaultMediaFormWidth = 640.0;
  static const double defaultFormWidth = 560.0;

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = defaultContentWidth,
    this.padding,
    this.backgroundColor,
  });

  const ResponsiveContainer.form({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  }) : maxWidth = defaultFormWidth;

  const ResponsiveContainer.text({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  }) : maxWidth = defaultTextWidth;

  const ResponsiveContainer.mediaForm({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
  }) : maxWidth = defaultMediaFormWidth;

  @override
  Widget build(BuildContext context) {
    final Widget content = padding != null
        ? Padding(padding: padding!, child: child)
        : child;

    final Color effectiveBackgroundColor =
        backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: effectiveBackgroundColor,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: content,
        ),
      ),
    );
  }
}
