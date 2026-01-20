import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/true_false_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:get/get.dart';
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
                    GameButton(
                      text: "",
                      icon: Icons.arrow_back_rounded,
                      width: 50,
                      height: 50,
                      color: Colors.white.withOpacity(0.2),
                      shadowColor: Colors.black.withOpacity(0.2),
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      "True or False",
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Obx(() => GameButton(
                          text: "",
                          icon: soundController.isMuted.value
                              ? Icons.volume_off
                              : Icons.volume_up,
                          width: 50,
                          height: 50,
                          color: Colors.white.withOpacity(0.2),
                          shadowColor: Colors.black.withOpacity(0.2),
                          onTap: () => soundController.toggleMute(),
                        )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // HUD
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHUDChip("LEVEL", "${controller.level}",
                            GameColors.secondary),
                        _buildHUDChip(
                            "SCORE", "${controller.score}", GameColors.primary),
                        _buildHUDChip(
                            "TIME", "${controller.timer}s", GameColors.danger),
                      ],
                    )),
              ),

              const SizedBox(height: 10),

              // Game Body or Game Over
              Expanded(
                child: Obx(() {
                  if (controller.isGameOver.value) {
                    return _buildGameOver(controller);
                  }

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
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Answer Buttons
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: FadeInLeft(
                                child: GameButton(
                                  text: "True",
                                  icon: Icons.check,
                                  color: GameColors.success,
                                  shadowColor: GameColors.successShadow,
                                  height: 80,
                                  fontSize: 24,
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
                                  color: GameColors.danger,
                                  shadowColor: GameColors.dangerShadow,
                                  height: 80,
                                  fontSize: 24,
                                  onTap: () => controller.onAnswer(false),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  );
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver(TrueFalseGameController controller) {
    // Show ad if appropriate (handled in original code build method start, but we do it here)
    // The view logic originally had this check in the build body.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Avoid calling setState during build if ad calls triggers it
      Get.find<AdsController>().showInterstitialAd();
    });

    return Center(
      child: FadeInUp(
        child: Container(
          margin: const EdgeInsets.all(30),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Time's Up!",
                  style: GoogleFonts.fredoka(
                      fontSize: 32, color: GameColors.danger)),
              const SizedBox(height: 20),
              Text("Score: ${controller.score}",
                  style: GoogleFonts.nunito(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              GameButton(
                text: "Play Again",
                onTap: () {
                  if (!purchaseController.isPro.value) {
                    adsController.showInterstitialAd();
                  }
                  controller.resetGame();
                },
                color: GameColors.success,
                shadowColor: GameColors.successShadow,
              ),
              const SizedBox(height: 16),
              GameButton(
                text: "Menu",
                onTap: () => Get.back(),
                color: GameColors.secondary,
                shadowColor: GameColors.secondaryShadow,
              ),
            ],
          ),
        ),
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
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
