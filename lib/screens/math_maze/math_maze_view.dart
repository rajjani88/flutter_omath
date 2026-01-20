import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/math_maze_controller.dart';
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

class MathMazeView extends StatelessWidget {
  MathMazeView({super.key});

  final MathMazeController controller = Get.put(MathMazeController());
  final SoundController soundController = Get.find<SoundController>();

  @override
  Widget build(BuildContext context) {
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
                      "Math Maze",
                      style: GoogleFonts.fredoka(
                        fontSize: 24.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
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

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Obx(() => Column(
                          children: [
                            // HUD with Coins
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildHUDChip(
                                    "LEVEL",
                                    "${controller.level.value}",
                                    GameColors.secondary),
                                const CoinDisplayWidget(),
                                _buildHUDChip(
                                    "MOVES",
                                    "${controller.movesMade}/${controller.moveLimit}",
                                    GameColors.danger),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Info Panel
                            FadeInDown(
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.2)),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        _buildTargetInfo(
                                            "Start",
                                            "${controller.startNumber}",
                                            GameColors.primary),
                                        const Icon(Icons.arrow_forward,
                                            color: Colors.white70),
                                        _buildTargetInfo(
                                            "Target",
                                            "${controller.targetNumber}",
                                            GameColors.success),
                                      ],
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                        'Reach target in exactly ${controller.moveLimit.value} moves',
                                        style: GoogleFonts.nunito(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white70))
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Current Number Board
                            FadeInUp(
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                    color: GameColors.panel,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5))
                                    ]),
                                child: Column(
                                  children: [
                                    Text("Current",
                                        style: GoogleFonts.nunito(
                                            color: Colors.white60,
                                            fontSize: 16.sp)),
                                    Text(
                                      "${controller.currentNumber}",
                                      style: GoogleFonts.fredoka(
                                          fontSize: 48.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 9,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                              itemBuilder: (context, index) {
                                final row = index ~/ 3;
                                final col = index % 3;
                                final operation = controller.grid[row][col];

                                // Check if hint
                                bool isHintTile =
                                    (controller.hintRow.value == row &&
                                        controller.hintCol.value == col);

                                // Determine color based on operation (+ or -)
                                Color btnColor = isHintTile
                                    ? Colors.yellow.shade600
                                    : (operation.startsWith('-')
                                        ? GameColors.danger
                                        : GameColors.success);

                                return GameButton(
                                  text: operation,
                                  color: btnColor,
                                  shadowColor: HSLColor.fromColor(btnColor)
                                      .withLightness(0.4)
                                      .toColor(),
                                  fontSize: 24.sp,
                                  onTap: () {
                                    controller.applyOperation(operation);
                                  },
                                );
                              },
                            ),

                            const SizedBox(height: 20),

                            // Power-Up Bar (No Freeze for this game - no timer)
                            GamePowerUpBar(
                              onHint: () => controller.useHint(),
                              onFreeze: () {}, // No timer in maze
                              onSkip: () => controller.skipLevel(),
                              showFreeze: false,
                            ),
                          ],
                        )),
                  ),
                ),
              ),
            ],
          ),
          Obx(() => controller.isGameOver.value
              ? Positioned.fill(
                  child: GameResultPopup(
                    score: (controller.level.value - 1) *
                        10, // Approx score logic or just 0
                    isTimeUp:
                        false, // It's moves up, but we can reuse the generic look or adjust text if needed. The popup says "Time's Up" by default if isTimeUp is true. If false, it says "Game Over".
                    // Wait, GameResultPopup checks isTimeUp for title.
                    // If isTimeUp is true -> "Time's Up!".
                    // If isTimeUp is false -> "Wrong Answer!".
                    // Here it's "Out of Moves" effectively. I'll define isTimeUp=true for now as it's closer to "resource ran out".
                    // Or I can modify GameResultPopup later to take a custom title.
                    // For now, I'll pass isTimeUp: true for consistency with "run out of resources".
                    onRetry: () => controller.generateNewLevel(),
                    onHome: () => Get.offAll(() => const HomeScreen()),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildTargetInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: const Offset(0, 2))
              ]),
          child: Text(value,
              style: GoogleFonts.fredoka(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold)),
        )
      ],
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
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.fredoka(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
