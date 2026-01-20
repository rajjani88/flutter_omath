import 'package:flutter/material.dart';

// NEW: 3D Icon with Gradient and Shadow
class GameIcon3D extends StatelessWidget {
  final Color color;
  final IconData icon;

  const GameIcon3D({super.key, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    // Darken color for gradient
    final HSLColor hsl = HSLColor.fromColor(color);
    final Color darkerColor =
        hsl.withLightness((hsl.lightness - 0.2).clamp(0.0, 1.0)).toColor();

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [color, darkerColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          // Deep colored shadow for 3D effect
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 25,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
          // Inner highlight
          BoxShadow(
            color: Colors.white.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 2),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 40,
        color: Colors.white,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}
