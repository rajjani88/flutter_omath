import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter_omath/widgets/glass_icon_button.dart'; // Add this
import 'package:flutter_omath/widgets/game_bottom_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_omath/widgets/game_result_popup.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';

class ArrangeNumber extends StatefulWidget {
  const ArrangeNumber({super.key});

  @override
  State<ArrangeNumber> createState() => _ArrangeNumberState();
}

class _ArrangeNumberState extends State<ArrangeNumber> {
  final ArrangeNumberController controller = Get.find();
  final SoundController soundController = Get.find<SoundController>();

  @override
  void initState() {
    super.initState();
    controller.startGame();
  }

  @override
  void dispose() {
    controller.disposeGame();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Stack(
        children: [
          // 1. Game UI
          Obx(() => SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Custom Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const GlassBackButton(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              "Arrange Numbers",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.fredoka(
                                fontSize: 24.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Obx(() => GlassIconButton(
                                icon: (!soundController.isSfxOn.value)
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                onTap: () => soundController
                                    .toggleSfx(!soundController.isSfxOn.value),
                              )),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // HUD with Coins
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHUDChip("LEVEL", "${controller.level.value}",
                              GameColors.secondary),
                          const CoinDisplayWidget(),
                          _buildHUDChip("TIME", "${controller.timer.value}s",
                              GameColors.danger),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Instruction Panel
                    FadeInDown(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Arrange in ",
                              style: GoogleFonts.nunito(
                                  color: Colors.white70, fontSize: 16.sp),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                color: !controller.isDescending.value
                                    ? GameColors.success
                                    : GameColors.primary,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                !controller.isDescending.value
                                    ? "ASCENDING"
                                    : "DESCENDING",
                                style: GoogleFonts.fredoka(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              " order",
                              style: GoogleFonts.nunito(
                                  color: Colors.white70, fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Center slots (Filled Slots)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(
                            controller.questionNumbers.length, (index) {
                          // Get user selection if available
                          final number = index < controller.userSelection.length
                              ? controller.userSelection[index]
                              : null;

                          return GestureDetector(
                            onTap: number != null
                                ? () => controller.removeNumber(number)
                                : null,
                            child: Container(
                              width: 65.w,
                              height: 65.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: number != null
                                    ? GameColors.panel
                                    : Colors.black.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: number != null
                                        ? GameColors.secondary
                                        : Colors.white.withOpacity(0.3),
                                    width: 2),
                                boxShadow: number != null
                                    ? [
                                        BoxShadow(
                                          color: GameColors.secondary
                                              .withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Text(
                                number?.toString() ?? '',
                                style: GoogleFonts.fredoka(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24.sp,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Number buttons (Pool)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 12,
                        children: controller.questionNumbers
                            .asMap()
                            .entries
                            .map((entry) {
                          int num = entry.value;

                          // Check if used
                          bool isUsed = controller.userSelection.contains(num);
                          if (isUsed) return const SizedBox.shrink();

                          bool isHighlighted =
                              controller.hintIndex.value == num; // hintIndex

                          return FadeInUp(
                            child: GameButton(
                              text: num.toString(),
                              width: 65.w,
                              height: 65.w,
                              fontSize: 24.sp,
                              color: isHighlighted
                                  ? Colors.green.shade400
                                  : GameColors.panel,
                              shadowColor: Colors.black.withOpacity(0.3),
                              onTap: () => controller.selectNumber(num),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Power-Up Bar
                    GamePowerUpBar(
                      onHint: () => controller.useHint(),
                      onFreeze: () => controller.freezeTime(),
                      onSkip: () => controller.skipLevel(),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              )),

          // 2. Game Over Overlay
          Obx(() {
            if (controller.isGameOver.value) {
              return Positioned.fill(
                child: GameResultPopup(
                  score: controller.score.value,
                  isTimeUp: true,
                  onRetry: () {
                    controller.startGame();
                  },
                  onHome: () => Get.offAll(() => const HomeScreen()),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildHUDChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: GoogleFonts.fredoka(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
