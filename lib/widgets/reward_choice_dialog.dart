import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/glass_card.dart';
import 'package:flutter_omath/widgets/juicy_button.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final adsController = Get.find<AdsController>();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: GlassCard(
        borderRadius: 30.r,
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 48.sp),
            ),
            SizedBox(height: 20.h),

            // Title
            Text(
              "Use $title",
              style: GoogleFonts.fredoka(
                fontSize: 24.sp,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              description,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),

            // Choice Buttons
            Row(
              children: [
                // Spend Coins Option
                if (coinCost > 0) ...[
                  Expanded(
                    child: JuicyButton(
                      label: "$coinCost",
                      icon: Icons.monetization_on,
                      color: Colors.amber.shade700,
                      height: 50.h,
                      onTap: () {
                        if (currencyController.spendCoins(coinCost)) {
                          Get.back();
                          onConfirm();
                        } else {
                          Get.snackbar(
                            "⚠️ Not Enough Coins",
                            "You need more coins or watch an ad!",
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                // Watch Ad Option
                Expanded(
                  child: JuicyButton(
                    label: "FREE",
                    icon: Icons.play_circle_fill,
                    color: GameColors.success,
                    height: 50.h,
                    onTap: () {
                      Get.back();
                      adsController.showRewardedAd(
                        onRewardGranted: onConfirm,
                      );
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => Get.back(),
              child: Text(
                "Cancel",
                style: GoogleFonts.nunito(color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
