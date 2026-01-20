import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/models/order_type.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
    controller.generateNumbers(8);
    controller.startTimer();
  }

  @override
  void dispose() {
    super.dispose();
    controller.disposeGame();
  }

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Stack(
        children: [
          Obx(
            () => controller.gameOver.value
                ? _buildGameOver()
                : SingleChildScrollView(
                    child: Column(
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
                              Expanded(
                                child: Text(
                                  "Arrange Numbers",
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.fredoka(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildHUDChip(
                                  "LEVEL",
                                  "${controller.currentLevel.value}",
                                  GameColors.secondary),
                              _buildHUDChip(
                                  "TIME",
                                  "${controller.remainingTime.value}s",
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
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.2)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Arrange in ",
                                  style: GoogleFonts.nunito(
                                      color: Colors.white70, fontSize: 16),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: controller.currentOrder.value ==
                                            OrderType.asc
                                        ? GameColors.success
                                        : GameColors.primary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    controller.currentOrder.value ==
                                            OrderType.asc
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
                                      color: Colors.white70, fontSize: 16),
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
                            children: controller.userSelection
                                .map((number) => Container(
                                      width: 65,
                                      height: 65,
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
                                          fontSize: 24,
                                        ),
                                      ),
                                    ))
                                .toList(),
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
                            children: controller.numberPool
                                .map((num) => FadeInUp(
                                      child: GameButton(
                                        text: num.toString(),
                                        width: 65,
                                        height: 65,
                                        fontSize: 24,
                                        color: GameColors.panel,
                                        shadowColor:
                                            Colors.black.withOpacity(0.3),
                                        onTap: () =>
                                            controller.selectNumber(num),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    Get.find<AdsController>().showRewardedAd();
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
              Text("Score: ${controller.currentLevel}",
                  style: GoogleFonts.nunito(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              GameButton(
                text: "Play Again",
                onTap: () {
                  controller.generateNumbers(8);
                  controller.startTimer();
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
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
