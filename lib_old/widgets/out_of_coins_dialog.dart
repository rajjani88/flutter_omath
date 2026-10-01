import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/screens/go_pro/go_pro_screen.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void showOutOfCoinsPaywallDialog({
  required String powerUpName,
  required int requiredCoins,
  required int currentCoins,
}) {
  Get.dialog(
    Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: GameColors.panel.withOpacity(0.85),
              borderRadius: BorderRadius.circular(28.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Crown / Coin Header Icon
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.amber.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.amberAccent,
                    size: 40.sp,
                  ),
                ),
                SizedBox(height: 18.h),

                // Title
                Text(
                  "Out of Coins!",
                  style: GoogleFonts.fredoka(
                    fontSize: 24.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),

                // Description
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: "Using "),
                      TextSpan(
                        text: powerUpName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: " costs "),
                      TextSpan(
                        text: "$requiredCoins 🪙",
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: ".\nYou currently have only "),
                      TextSpan(
                        text: "$currentCoins 🪙",
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const TextSpan(text: "."),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // High-Converting Benefit box
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Text("👑", style: TextStyle(fontSize: 22)),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          "Go Pro to get Unlimited Free Helpers, 2x Coins & ad-free focus!",
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            color: Colors.amberAccent.shade100,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Action CTA
                GameButton(
                  text: "GET FREE POWER-UPS",
                  color: GameColors.success,
                  shadowColor: GameColors.successShadow,
                  fontSize: 16.sp,
                  height: 52.h,
                  onTap: () {
                    Get.back(); // close dialog
                    Get.to(() => const GoProScreen());
                  },
                ),
                SizedBox(height: 10.h),

                // Cancel button
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    "Maybe Later",
                    style: GoogleFonts.fredoka(
                      color: Colors.white38,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    barrierDismissible: true,
  );
}
