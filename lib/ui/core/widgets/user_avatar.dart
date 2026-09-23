import 'dart:math';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String username;
  final String? imageUrl;
  final double radius;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    required this.username,
    this.imageUrl,
    this.radius = 20,
    this.onTap,
  });

  static int _deterministicHash(String text) {
    var hash = 0x811c9dc5;
    for (var i = 0; i < text.length; i++) {
      hash ^= text.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash;
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = ClipOval(
        child: Image.network(
          imageUrl!,
          width: diameter,
          height: diameter,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _buildPawAvatar(diameter),
        ),
      );
    } else {
      avatar = _buildPawAvatar(diameter);
    }

    if (onTap != null) {
      avatar = GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildPawAvatar(double diameter) {
    final seed = _deterministicHash(username.isEmpty ? 'guest' : username);
    final random = Random(seed);

    final hue1 = random.nextDouble() * 360.0;
    final hue2 = (hue1 + 35.0 + random.nextDouble() * 45.0) % 360.0;
    final color1 = HSLColor.fromAHSL(1.0, hue1, 0.55, 0.82).toColor();
    final color2 = HSLColor.fromAHSL(1.0, hue2, 0.65, 0.72).toColor();

    final gradAngle = random.nextDouble() * pi * 2;

    final rotation = (random.nextDouble() - 0.5) * 0.7;
    final scale = 0.90 + random.nextDouble() * 0.15;

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment(cos(gradAngle), sin(gradAngle)),
          end: Alignment(-cos(gradAngle), -sin(gradAngle)),
          colors: [color1, color2],
        ),
      ),
      child: Center(
        child: Transform.rotate(
          angle: rotation,
          child: Transform.scale(
            scale: scale,
            child: Icon(
              Icons.pets,
              size: diameter * 0.52,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ),
      ),
    );
  }
}