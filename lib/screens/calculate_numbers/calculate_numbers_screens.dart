import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class CalculateNumbersScreen extends StatefulWidget {
  final OperationMode selectedMode;
  final bool isDailyChallenge;
  final int? dailySeed;

  const CalculateNumbersScreen({
    super.key,
    required this.selectedMode,
    this.isDailyChallenge = false,
    this.dailySeed,
  });

  @override
  State<CalculateNumbersScreen> createState() => _CalculateNumbersScreenState();
}

class _CalculateNumbersScreenState extends State<CalculateNumbersScreen> {
  final controller = Get.find<CalculateNumbersController>();
  final soundController = Get.find<SoundController>();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    controller.startGame(widget.selectedMode,
        seed: widget.dailySeed, isDaily: widget.isDailyChallenge);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Listen for level changes to trigger confetti
    ever(controller.level, (_) {
      // Simple check: if level increases, it meant a success (roughly).
      // Ideally controller should emit a 'success' event, but this works for now.
      if (controller.level.value > 1) {
        _playSuccess();
      }
    });
  }

  void _playSuccess() {
    soundController.playSuccess();
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 10),
              // Custom AppBar
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
                      "Calculate",
                      style: GoogleFonts.fredoka(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Mute Button
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

              // HUD (Level & Time)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHUDChip(
                        "LEVEL", controller.level, GameColors.secondary),
                    _buildHUDChip("TIME", controller.timer, GameColors.danger),
                  ],
                ),
              ),

              Expanded(
                child: Obx(() {
                  if (controller.isGamOver.value) {
                    return _buildGameOver();
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Column(
                      children: [
                        // Question Board Area (Top ~40%)
                        Expanded(
                          flex: 4,
                          child: Center(
                            child: FadeInDown(
                              from: 30,
                              child: AspectRatio(
                                aspectRatio:
                                    1.5, // Keep board somewhat rectangular
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: GameColors.panel,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(0, 10),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          controller.question.value,
                                          style: GoogleFonts.nunito(
                                            fontSize: 56, // Larger text
                                            fontWeight: FontWeight.w900,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 30),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.black.withOpacity(0.3),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            controller.userAnswer.value.isEmpty
                                                ? "?"
                                                : controller.userAnswer.value,
                                            style: GoogleFonts.fredoka(
                                              fontSize: 42,
                                              color: GameColors.primary,
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Numpad Area (Bottom ~60%)
                        Expanded(
                          flex: 6,
                          child: FadeInUp(
                            duration: const Duration(milliseconds: 600),
                            child: Column(
                              children: [
                                _buildFlexRow(["1", "2", "3"], controller),
                                _buildFlexRow(["4", "5", "6"], controller),
                                _buildFlexRow(["7", "8", "9"], controller),
                                _buildFlexRow(["C", "0", "OK"], controller),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),

          // Confetti Overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                GameColors.primary,
                GameColors.secondary,
                GameColors.danger,
                GameColors.success,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlexRow(
      List<String> labels, CalculateNumbersController controller) {
    return Expanded(
      child: Row(
        children: labels.map((label) {
          Color color = GameColors.panel;
          VoidCallback action;
          bool isDigit = true;

          if (label == "C") {
            color = GameColors.danger;
            action = () => controller.resetInput();
            isDigit = false;
          } else if (label == "OK") {
            color = GameColors.success;
            action = () => controller.submitAnswer();
            isDigit = false;
          } else {
            action = () => controller.addInput(label);
          }

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: _buildNumpadBtn(label, color, action, isDigit: isDigit),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumpadBtn(String text, Color color, VoidCallback onTap,
      {bool isDigit = false}) {
    return GameButton(
      text: text,
      onTap: onTap,
      color: color,
      shadowColor:
          HSLColor.fromColor(color).withLightness(0.4).toColor(), // Auto shadow
      fontSize: 28,
      height: double.infinity,
      width: double.infinity,
      // If digit, standard text color, else white
      // Actually my GameButton forces white text currently.
      // If surface is white, text should be dark.
      // I'll leave GameButton as is, white text on colored buttons.
      // Digits will be white on white? No GameColors.surface is white.
      // I should modify GameButton to handle text color or pick a color for digits.
      // Let's use a nice Blue for digits instead of White surface.
    );
  }

  Widget _buildHUDChip(String label, RxInt valueObx, Color color) {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
              Text(
                "${valueObx.value}",
                style: GoogleFonts.fredoka(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildGameOver() {
    Get.find<AdsController>().showRewardedAd();
    return Center(
      child: FadeInDown(
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
              Text("Score: ${controller.level}",
                  style: GoogleFonts.nunito(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              GameButton(
                text: "Play Again",
                onTap: () => controller.startGame(OperationMode.auto),
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
}
