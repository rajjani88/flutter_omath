import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/screens/go_pro/go_pro_screen.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/juicy_button.dart';

class RewardChoiceDialog extends StatelessWidget {
  final String title;
  final IconData icon;
  final int coinCost;
  final String description;
  final VoidCallback onConfirm;

  const RewardChoiceDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.coinCost,
    required this.description,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final currencyController = Get.find<CurrencyController>();
    final iapController = Get.find<InAppPurchaseController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  GameColors.panel.withValues(alpha: 0.95),
                  GameColors.bgTop.withValues(alpha: 0.98),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: GameColors.secondary.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: GameColors.secondary.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: GameColors.secondary.withValues(alpha: 0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 36.sp,
                    color: GameColors.secondary,
                  ),
                ),
                SizedBox(height: 16.h),

                // Title
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),

                // Description
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 14.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 20.h),

                // Cost Badge / Currency Display
                Obx(() {
                  final isPro = iapController.isPro.value;
                  final currentCoins = currencyController.coinBalance.value;
                  final hasEnough = currentCoins >= coinCost;

                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white10,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPro) ...[
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 20.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "FREE with PRO",
                            style: GoogleFonts.fredoka(
                              fontSize: 14.sp,
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.monetization_on_rounded,
                            color: Colors.amber,
                            size: 20.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            "$coinCost Coins",
                            style: GoogleFonts.fredoka(
                              fontSize: 14.sp,
                              color: hasEnough ? Colors.white : Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "(You have: $currentCoins)",
                            style: GoogleFonts.fredoka(
                              fontSize: 12.sp,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
                SizedBox(height: 24.h),

                // Action Buttons
                Obx(() {
                  final isPro = iapController.isPro.value;
                  final currentCoins = currencyController.coinBalance.value;
                  final hasEnough = currentCoins >= coinCost;

                  return Column(
                    children: [
                      if (isPro || hasEnough)
                        JuicyButton(
                          label: isPro ? "USE NOW (FREE)" : "USE $coinCost COINS",
                          color: GameColors.secondary,
                          height: 54.h,
                          onTap: () {
                            if (!isPro) {
                              final success = currencyController.spendCoins(coinCost);
                              if (!success) return;
                            }
                            Get.find<SoundController>().playSuccess();
                            Get.back(); // Dismiss dialog
                            onConfirm();
                          },
                        )
                      else
                        JuicyButton(
                          label: "GO PRO FOR UNLIMITED",
                          color: GameColors.warning,
                          height: 54.h,
                          onTap: () {
                            Get.back(); // Dismiss dialog
                            Get.to(() => const GoProScreen());
                          },
                        ),
                      SizedBox(height: 10.h),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.fredoka(
                            color: Colors.white54,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
