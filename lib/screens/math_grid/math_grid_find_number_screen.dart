import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/math_grid_puzzle_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MathGridFindNumber extends StatefulWidget {
  const MathGridFindNumber({super.key});

  @override
  State<MathGridFindNumber> createState() => _MathGridFindNumberState();
}

class _MathGridFindNumberState extends State<MathGridFindNumber> {
  final controller = Get.find<MathGridPuzzleController>();
  final soundController = Get.find<SoundController>();

  @override
  void initState() {
    super.initState();
    controller.startGame();
  }

  @override
  void dispose() {
    super.dispose();
    controller.gameDispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameBackground(
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
                Text(
                  "Math Grid",
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => _buildHUDChip("LEVEL", "${controller.level.value}",
                    GameColors.secondary)),
                Obx(() => _buildHUDChip("TIME", "${controller.timeLeft.value}s",
                    GameColors.danger)),
              ],
            ),
          ),

          const SizedBox(height: 30),

          // Question Panel
          FadeInDown(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                color: GameColors.panel,
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: const Offset(0, 10),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Obx(() => Text(
                    controller.currentQuestion.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 28, // Smaller than full equation but big enough
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  )),
            ),
          ),

          const SizedBox(height: 30),

          // Answer Grid
          _buildAnswerGrid(controller),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAnswerGrid(MathGridPuzzleController controller) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Obx(() {
          return GridView.builder(
            itemCount: controller.answerOptions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, index) {
              final item = controller.answerOptions[index];
              return FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: GameButton(
                  text: "$item",
                  fontSize: 28,
                  color: GameColors.panel,
                  shadowColor: Colors.black.withOpacity(0.3),
                  onTap: () {
                    // Assuming controller handles sound/logic internally or we should add sound here?
                    // GameButton adds click sound automatically.

                    // We can check if answer is correct to play success sound?
                    // Controller logic is opaque here, let's just trigger method.
                    controller.onAnswerSelected(item);
                  },
                ),
              );
            },
          );
        }),
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
