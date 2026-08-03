import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showUnlockGameModeDialog({
  required VoidCallback onWatchAd,
  required VoidCallback onGoPro,
}) {
  Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Unlock Game Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Unlock all premium game modes, unlimited power-ups, and daily challenges with MathWize Pro!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Text(
            '⚡ Go Pro: Unlimited Fun & Pure Focus!',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close dialog
            onGoPro();
          },
          child: const Text('Unlock MathWize Pro'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
