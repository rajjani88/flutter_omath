import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/sudoku_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter_omath/widgets/unified_success_popup.dart';
import 'package:flutter_omath/utils/sudoku_utils.dart';
import 'package:flutter_omath/widgets/reward_choice_dialog.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SudokuScreen extends StatelessWidget {
  final bool isDailyChallenge;
  final int? dailySeed;

  const SudokuScreen({
    super.key,
    this.isDailyChallenge = false,
    this.dailySeed,
  });

  @override
  Widget build(BuildContext context) {
    final SudokuController controller = Get.put(SudokuController());
    final AdsController adsController = Get.find<AdsController>();

    // Initialize daily challenge if needed
    if (isDailyChallenge) {
      controller.isDailyChallenge = true;
      controller.dailySeed = dailySeed;
      controller.startNewGame();
    }

    return GameBackground(
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      const GlassBackButton(),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Mini Sudoku",
                            style: GoogleFonts.fredoka(
                              fontSize: 22.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Obx(() => Text(
                                controller.difficulty.value.name.toUpperCase(),
                                style: GoogleFonts.nunito(
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              )),
                        ],
                      ),
                      const Spacer(),
                      _buildDifficultyPicker(controller),
                      const SizedBox(width: 12),
                      Obx(() => _buildHeaderInfo(
                            Icons.timer_outlined,
                            controller.formatTime(),
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Grid Area
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Container(
                          decoration: BoxDecoration(
                            color: GameColors.panel.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: _buildSudokuGrid(controller),
                        ),
                      ),
                    ),
                  ),
                ),

                // Controls Area
                _buildControlsArea(controller),
                const SizedBox(height: 20),

                Obx(
                  () => adsController.isBannerAd2Loaded.value
                      ? SizedBox(
                          height: AdSize.banner.height.toDouble(),
                          child: AdWidget(ad: adsController.bannerAd2!))
                      : const SizedBox.shrink(),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Win Result Popup
          Obx(() => controller.isGameWon.value
              ? UnifiedSuccessPopup(
                  coins: kCoinsPerCorrectAnswer * 2,
                  xp: 20,
                  time: controller.formatTime(),
                  onNext: () => controller.startNewGame(),
                  onHome: () => Get.back(),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: GameColors.secondary),
          const SizedBox(width: 6),
          Text(text,
              style: GoogleFonts.courierPrime(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp)),
        ],
      ),
    );
  }

  Widget _buildSudokuGrid(SudokuController controller) {
    return LayoutBuilder(builder: (context, constraints) {
      double cellSize = constraints.maxWidth / 6;
      return Column(
        children: List.generate(6, (r) {
          return Row(
            children: List.generate(6, (c) {
              return Obx(() {
                bool isSelected = controller.selectedRow.value == r &&
                    controller.selectedCol.value == c;
                bool isFixed = controller.isFixed[r][c];
                int value = controller.currentBoard[r][c];
                Set<int>? cellNotes = controller.notes[r * 6 + c];
                bool isError = value != 0 &&
                    !isFixed &&
                    value != controller.solution[r][c];

                // Borders logic for 2x3 blocks
                BorderSide bottomBorder = (r == 1 || r == 3 || r == 5)
                    ? const BorderSide(color: Colors.white, width: 2)
                    : const BorderSide(color: Colors.white24, width: 0.5);
                BorderSide rightBorder = (c == 2 || c == 5)
                    ? const BorderSide(color: Colors.white, width: 2)
                    : const BorderSide(color: Colors.white24, width: 0.5);
                // Top and left outer borders
                BorderSide topBorder = (r == 0)
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none;
                BorderSide leftBorder = (c == 0)
                    ? const BorderSide(color: Colors.white, width: 2)
                    : BorderSide.none;

                return GestureDetector(
                  onTap: () => controller.selectCell(r, c),
                  child: Container(
                    width: cellSize,
                    height: cellSize,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? GameColors.secondary.withOpacity(0.4)
                          : isError
                              ? Colors.red.withOpacity(0.2)
                              : Colors.transparent,
                      border: Border(
                        bottom: bottomBorder,
                        right: rightBorder,
                        top: topBorder,
                        left: leftBorder,
                      ),
                    ),
                    child: Center(
                      child: value != 0
                          ? Text(
                              "$value",
                              style: GoogleFonts.fredoka(
                                fontSize: 24.sp,
                                fontWeight:
                                    isFixed ? FontWeight.bold : FontWeight.w500,
                                color: isFixed
                                    ? Colors.white
                                    : isError
                                        ? Colors.redAccent
                                        : GameColors.secondary,
                              ),
                            )
                          : (cellNotes != null && cellNotes.isNotEmpty)
                              ? _buildNotesGrid(cellNotes)
                              : const SizedBox.shrink(),
                    ),
                  ),
                );
              });
            }),
          );
        }),
      );
    });
  }

  Widget _buildDifficultyPicker(SudokuController controller) {
    return GestureDetector(
      onTap: () {
        Get.dialog(
          AlertDialog(
            backgroundColor: const Color(0xFF1a0b2e),
            title: Text("Select Difficulty",
                style: GoogleFonts.fredoka(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: SudokuDifficulty.values
                  .map((d) => ListTile(
                        title: Text(d.name.toUpperCase(),
                            style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          controller.startNewGame(diff: d);
                          Get.back();
                        },
                      ))
                  .toList(),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child:
            const Icon(Icons.settings_suggest, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildNotesGrid(Set<int> notes) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        int num = index + 1;
        return Center(
          child: Text(
            notes.contains(num) ? "$num" : "",
            style: TextStyle(fontSize: 8.sp, color: Colors.white70),
          ),
        );
      },
    );
  }

  Widget _buildControlsArea(SudokuController controller) {
    return Column(
      children: [
        // Action Buttons
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionButton(
                Icons.lightbulb_outline,
                "Hint",
                () {
                  Get.dialog(
                    RewardChoiceDialog(
                      title: "Hint",
                      icon: Icons.lightbulb_outline,
                      coinCost: kHintCost,
                      description: "Reveal the correct value for this cell!",
                      onConfirm: () => controller.useHint(),
                    ),
                  );
                },
                color: Colors.amber,
              ),
              Obx(() => _buildActionButton(
                    Icons.ac_unit,
                    "Freeze",
                    () {
                      Get.dialog(
                        RewardChoiceDialog(
                          title: "Freeze",
                          icon: Icons.ac_unit,
                          coinCost: kFreezeCost,
                          description: "Stop the timer for 10 seconds!",
                          onConfirm: () => controller.freezeTime(),
                        ),
                      );
                    },
                    color: controller.isTimeFrozen.value
                        ? Colors.cyan
                        : Colors.white54,
                    subtitle: controller.isTimeFrozen.value ? "ON" : "OFF",
                  )),
              _buildActionButton(
                Icons.skip_next,
                "Skip",
                () {
                  Get.dialog(
                    RewardChoiceDialog(
                      title: "Skip",
                      icon: Icons.skip_next,
                      coinCost: kSkipCost,
                      description: "Skip to the next level!",
                      onConfirm: () => controller.skipLevel(),
                    ),
                  );
                },
                color: GameColors.secondary,
              ),
              Obx(() => _buildActionButton(
                    Icons.edit_note,
                    "Notes",
                    () => controller.toggleNotesMode(),
                    color: controller.isNotesMode.value
                        ? GameColors.secondary
                        : Colors.white54,
                    subtitle: controller.isNotesMode.value ? "ON" : "OFF",
                  )),
              _buildActionButton(
                Icons.delete_outline,
                "Clear",
                () => controller.clearCell(),
                color: GameColors.danger,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Number Pad
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: List.generate(6, (i) {
              int num = i + 1;
              return GestureDetector(
                onTap: () => controller.inputNumber(num),
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Center(
                    child: Text(
                      "$num",
                      style: GoogleFonts.fredoka(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap,
      {Color color = Colors.white, String? subtitle}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28.sp),
          const SizedBox(height: 2),
          Text(label,
              style: GoogleFonts.nunito(
                  color: color, fontSize: 12.sp, fontWeight: FontWeight.bold)),
          if (subtitle != null)
            Text(subtitle,
                style: TextStyle(
                    color: color, fontSize: 9.sp, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
