import 'package:flutter/material.dart';

class DiagonalPainter extends CustomPainter {
  final Color _topLeftColor;
  final Color _bottomRightColor;

  DiagonalPainter({
    required this._topLeftColor,
    required this._bottomRightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final path = Path();

    paint.color = _topLeftColor;
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);

    path.reset();

    paint.color = _bottomRightColor;
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
