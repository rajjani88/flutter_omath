import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:get/get.dart';

class GlassBackButton extends StatelessWidget {
  final VoidCallback? onTap;

  const GlassBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        try {
          Get.find<SoundController>().playClick();
        } catch (e) {
          // Ignore sound error
        }
        if (onTap != null) {
          onTap!();
        } else {
          Get.back();
        }
      },
      child: Container(
        width: 45, // Fixed square size
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12), // rounded square
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new,
          color: Colors.white,
          size: 20, // Smaller icon to fit nicely
        ),
      ),
    );
  }
}
