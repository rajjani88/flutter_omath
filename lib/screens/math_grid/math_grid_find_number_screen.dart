import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/math_grid_puzzle_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
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
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MathGridFindNumber extends StatefulWidget {
  final bool isDailyChallenge;
  final int? dailySeed;

  const MathGridFindNumber({
    super.key,
    this.isDailyChallenge = false,
    this.dailySeed,
  });

  @override
  State<MathGridFindNumber> createState() => _MathGridFindNumberState();
}

class _MathGridFindNumberState extends State<MathGridFindNumber> {
  final controller = Get.find<MathGridPuzzleController>();
  final soundController = Get.find<SoundController>();
  final adsController = Get.find<AdsController>();

  @override
  void initState() {
    super.initState();
    controller.isDailyChallenge = widget.isDailyChallenge;
    controller.dailySeed = widget.dailySeed;
    controller.startGame();
  }

  @override
  void dispose() {
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
              // Custom Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const GlassBackButton(),
                    const SizedBox(width: 16),
                    Text(
                      "Math Grid",
                      style: GoogleFonts.fredoka(
                        fontSize: 20.sp,
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

              const SizedBox(height: 10),

              // HUD with Coins
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(() => _buildHUDChip("LEVEL",
                        "${controller.level.value}", GameColors.secondary)),
                    const CoinDisplayWidget(),
                    Obx(() => _buildHUDChip("LIVES",
                        "${controller.lives.value}", GameColors.danger)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Question Panel
              FadeInDown(
                child: Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding:
                      EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
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
                  child: Obx(() => Text(
                        controller.question.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      )),
                ),
              ),

              const SizedBox(height: 20),

              // Answer Grid
              _buildAnswerGrid(controller),

              // Power-Up Bar
              Obx(() => GamePowerUpBar(
                    onHint: () => controller.useHint(),
                    onFreeze: () {}, // No timer
                    onSkip: () => controller.skipLevel(),
                    onSolve: () => controller.solveLevel(),
                    onAddLife: () => controller.addExtraLife(),
                    showFreeze: false,
                    showSolve: true,
                    showAddLife: controller.extraLivesGained.value < 2,
                  )),
              Obx(
                () => adsController.isBannerAd1Loaded.value
                    ? SizedBox(
                        height: AdSize.banner.height.toDouble(),
                        child: AdWidget(ad: adsController.bannerAd1!))
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 10),
            ],
          ),
          Obx(
            () => controller.isGameOver.value
                ? GameResultPopup(
                    score: controller.level.value,
                    onRetry: () {
                      Get.find<AdsController>().showRewardedAd(
                        onRewardGranted: () {
                          controller.startGame();
                        },
                      );
                    },
                    onHome: () {
                      Get.find<AdsController>().showInterstitialAd();
                      Get.offAll(() => const HomeScreen());
                    },
                  )
                : const SizedBox.shrink(),
          ),
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (_, index) {
              final item = controller.answerOptions[index];
              // Check if this tile should be highlighted (hint)
              final isHighlighted = controller.highlightedAnswer.value == item;
              return FadeInUp(
                delay: Duration(milliseconds: 50 * index),
                child: GameButton(
                  text: "$item",
                  fontSize: 22.sp,
                  color:
                      isHighlighted ? Colors.green.shade400 : GameColors.panel,
                  shadowColor: Colors.black.withOpacity(0.3),
                  onTap: () {
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: Offset(0, 4.h),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(
            label == "LIVES" ? Icons.favorite : null,
            color: Colors.white,
            size: 16.sp,
          ),
          if (label == "LIVES") SizedBox(width: 4.w),
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
