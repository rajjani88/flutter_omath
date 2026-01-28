import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/true_false_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter_omath/widgets/game_bottom_bar.dart';
import 'package:flutter_omath/widgets/glass_icon_button.dart'; // Add this
import 'package:get/get.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/widgets/game_result_popup.dart';
import 'package:google_fonts/google_fonts.dart';

class TrueFalseGame extends StatefulWidget {
  const TrueFalseGame({super.key});

  @override
  State<TrueFalseGame> createState() => _TrueFalseGameState();
}

class _TrueFalseGameState extends State<TrueFalseGame> {
  // AdsController adsController = Get.find(); // Used inside controller mostly or for interstitial
  // InAppPurchaseController purchaseController = Get.find(); // Used locally for restart
  final SoundController soundController = Get.find<SoundController>();
  final AdsController adsController = Get.find();
  final InAppPurchaseController purchaseController = Get.find();

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TrueFalseGameController());

    return GameBackground(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const GlassBackButton(),
                    const SizedBox(width: 16),
                    Text(
                      "True or False",
                      style: GoogleFonts.fredoka(
                        fontSize: 24.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHUDChip("LEVEL", "${controller.level}",
                            GameColors.secondary),
                        const CoinDisplayWidget(),
                        _buildHUDChip(
                            "TIME", "${controller.timer}s", GameColors.danger),
                      ],
                    )),
              ),

              const SizedBox(height: 10),

              // Game Body or Game Over
              Expanded(
                child: Obx(() {
                  // if (controller.isGameOver.value) {
                  //   return _buildGameOver(controller);
                  // }

                  return Column(
                    children: [
                      const Spacer(flex: 1),
                      // Question Board
                      FadeInDown(
                        key: ValueKey(controller.question
                            .value), // Animate on new question? Maybe annoying if too slow.
                        // Let's keep animation only on init or use a subtle pulse.
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.symmetric(
                              vertical: 40, horizontal: 20),
                          decoration: BoxDecoration(
                            color: GameColors.panel,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.1), width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 10),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Text(
                            controller.question.value,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.nunito(
                              fontSize: 42.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Answer Buttons with Hint support
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Obx(() => Row(
                              children: [
                                Expanded(
                                  child: FadeInLeft(
                                    child: GameButton(
                                      text: "True",
                                      icon: Icons.check,
                                      // Highlight if hint active and True is correct
                                      color: (controller.showHint.value &&
                                              controller.isCorrectAnswer.value)
                                          ? Colors.green.shade300
                                          : GameColors.success,
                                      shadowColor: GameColors.successShadow,
                                      height: 80.h,
                                      fontSize: 24.sp,
                                      onTap: () => controller.onAnswer(true),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: FadeInRight(
                                    child: GameButton(
                                      text: "False",
                                      icon: Icons.close,
                                      // Highlight if hint active and False is correct
                                      color: (controller.showHint.value &&
                                              !controller.isCorrectAnswer.value)
                                          ? Colors.green.shade300
                                          : GameColors.danger,
                                      shadowColor: GameColors.dangerShadow,
                                      height: 80.h,
                                      fontSize: 24.sp,
                                      onTap: () => controller.onAnswer(false),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ),
                      // Power-Up Bar
                      GamePowerUpBar(
                        onHint: () => controller.useHint(),
                        onFreeze: () => controller.freezeTime(),
                        onSkip: () => controller.skipLevel(),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }),
              ),
            ],
          ),
          Obx(() {
            if (controller.isGameOver.value) {
              return Positioned.fill(
                child: GameResultPopup(
                  score: controller.score.value,
                  isTimeUp: true,
                  onRetry: () {
                    // Logic for retry
                    if (!purchaseController.isPro.value) {
                      adsController.showInterstitialAd();
                    }
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
              fontSize: 10.sp,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
