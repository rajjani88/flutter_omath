import 'package:animate_do/animate_do.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter_omath/widgets/power_up_button.dart';
import 'package:flutter_omath/widgets/glass_icon_button.dart'; // Add this
import 'package:get/get.dart';
import 'package:flutter_omath/widgets/game_result_popup.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
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
  final currencyController = Get.find<CurrencyController>();
  late ConfettiController _confettiController;
  Worker? _levelWorker;

  @override
  void initState() {
    super.initState();
    controller.startGame(widget.selectedMode,
        seed: widget.dailySeed, isDaily: widget.isDailyChallenge);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));

    // Listen for level changes to trigger confetti
    _levelWorker = ever(controller.level, (_) {
      // Simple check: if level increases, it meant a success (roughly).
      // Ideally controller should emit a 'success' event, but this works for now.
      // Ensure we don't trigger if widget is disposed (extra safety)
      if (mounted && controller.level.value > 1) {
        _playSuccess();
      }
    });
  }

  void _playSuccess() {
    soundController.playSuccess();
    if (mounted) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _levelWorker?.dispose();
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
                    const GlassBackButton(),
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
                    // Mute Button
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

              // HUD (Level, Time & Coins)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildHUDChip(
                        "LEVEL", controller.level, GameColors.secondary),
                    _buildCoinHUD(),
                    _buildHUDChip("TIME", controller.timer, GameColors.danger),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Obx(() => Text(
                                            controller.question.value,
                                            style: GoogleFonts.nunito(
                                              fontSize: 56.sp, // Larger text
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          )),
                                      const SizedBox(height: 20),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 30),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Obx(() => Text(
                                              controller
                                                      .userAnswer.value.isEmpty
                                                  ? "?"
                                                  : controller.userAnswer.value,
                                              style: GoogleFonts.fredoka(
                                                fontSize: 42,
                                                color: GameColors.primary,
                                                letterSpacing: 2,
                                              ),
                                            )),
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

                      // Power-Up Bar
                      _buildPowerUpBar(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
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
          Obx(
            () => controller.isGameOver.value
                ? GameResultPopup(
                    score: controller.level.value,
                    onRetry: () {
                      controller.startGame(controller.mode.value);
                    },
                    onHome: () {
                      Get.offAll(() => const HomeScreen());
                    },
                  )
                : const SizedBox.shrink(),
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
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildCoinHUD() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.shade700,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("🪙", style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
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

  Widget _buildPowerUpBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Freeze Time
          PowerUpButton(
            icon: Icons.ac_unit,
            label: "Freeze",
            cost: kFreezeCost,
            color: Colors.cyan,
            onActivate: () => controller.freezeTime(),
          ),
          // Skip Level
          PowerUpButton(
            icon: Icons.skip_next,
            label: "Skip",
            cost: kSkipCost,
            color: GameColors.secondary,
            onActivate: () => controller.skipLevel(),
          ),
          // Hint (placeholder for now)
          PowerUpButton(
            icon: Icons.lightbulb,
            label: "Hint",
            cost: kHintCost,
            color: Colors.orange,
            onActivate: () {
              // For Calculate, hint could show first digit?
              Get.snackbar("💡 Hint",
                  "Answer starts with: ${controller.correctAnswer.value.toString()[0]}",
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3));
            },
          ),
        ],
      ),
    );
  }
}
