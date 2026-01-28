import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:get/get.dart';

class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size; // Container size
  final double iconSize;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 45,
    this.iconSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          Get.find<SoundController>().playClick();
        } catch (_) {}
        onTap();
      },
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }
}
