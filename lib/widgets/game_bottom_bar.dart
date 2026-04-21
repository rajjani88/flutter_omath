import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/power_up_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable coin display for game HUDs
class CoinDisplayWidget extends StatelessWidget {
  const CoinDisplayWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyController = Get.find<CurrencyController>();
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 4.h),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("🪙", style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 6.w),
              Text(
                "${currencyController.coinBalance.value}",
                style: GoogleFonts.fredoka(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ));
  }
}

/// Reusable bottom bar with power-ups for all games
/// Usage: GameBottomBar(onHint: () => controller.useHint(), ...)
class GameBottomBar extends StatelessWidget {
  final VoidCallback onHint;
  final VoidCallback onFreeze;
  final VoidCallback onSkip;
  final VoidCallback? onSolve;
  final VoidCallback? onAddLife;
  final bool showFreeze; // Some games don't have timers
  final bool showhint;
  final bool showSolve;
  final bool showAddLife;

  const GameBottomBar({
    super.key,
    required this.onHint,
    required this.onFreeze,
    required this.onSkip,
    this.onSolve,
    this.onAddLife,
    this.showFreeze = true,
    this.showhint = false,
    this.showSolve = false,
    this.showAddLife = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Hint
          if (showhint)
            PowerUpButton(
              icon: Icons.lightbulb,
              label: "Hint",
              cost: kHintCost,
              color: Colors.orange,
              description: "Reveal the correct answer!",
              onActivate: onHint,
            ),
          // Freeze Time (optional)
          if (showFreeze)
            PowerUpButton(
              icon: Icons.ac_unit,
              label: "Freeze",
              cost: kFreezeCost,
              color: Colors.cyan,
              description: "Stop the timer for 10 seconds!",
              onActivate: onFreeze,
            ),
          // Skip Level
          PowerUpButton(
            icon: Icons.skip_next,
            label: "Skip",
            cost: kSkipCost,
            color: GameColors.secondary,
            description: "Skip to the next level!",
            onActivate: onSkip,
          ),
          // Solve Level (Watch Ad)
          if (showSolve && onSolve != null)
            PowerUpButton(
              icon: Icons.auto_fix_high,
              label: "Solve",
              cost: 0, // This will be free via ad in the RewardChoiceDialog logic
              color: Colors.purple,
              description: "Automatically solve this level!",
              onActivate: onSolve!,
            ),
          // Add Life (Watch Ad)
          if (showAddLife && onAddLife != null)
            PowerUpButton(
              icon: Icons.favorite,
              label: "Life",
              cost: 0,
              color: Colors.redAccent,
              description: "Earn 1 life. Max you can get 2!",
              onActivate: onAddLife!,
            ),
        ],
      ),
    );
  }
}

// Keep old name for backward compatibility
typedef GamePowerUpBar = GameBottomBar;
