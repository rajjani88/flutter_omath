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
            'This game mode is free to play!\n\nJust watch a short ad to start playing or go Pro and never see ads again!',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Divider(),
          const SizedBox(height: 8),
          Text(
            '⚡ Go Pro: Unlimited fun, zero ads!',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close dialog
            onWatchAd();
          },
          child: Text('Continue with Ads'),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back(); // Close dialog
            onGoPro();
          },
          child: Text('Go Pro (No Ads Ever)'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
