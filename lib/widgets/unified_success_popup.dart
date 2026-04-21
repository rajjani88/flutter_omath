import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_omath/widgets/juicy_button.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:confetti/confetti.dart';

class UnifiedSuccessPopup extends StatefulWidget {
  final int coins;
  final int xp;
  final String? time;
  final String? level;
  final VoidCallback onNext;
  final VoidCallback onHome;

  const UnifiedSuccessPopup({
    super.key,
    required this.coins,
    required this.xp,
    this.time,
    this.level,
    required this.onNext,
    required this.onHome,
  });

  @override
  State<UnifiedSuccessPopup> createState() => _UnifiedSuccessPopupState();
}

class _UnifiedSuccessPopupState extends State<UnifiedSuccessPopup> {
  late ConfettiController _confettiController;
  final RxBool _hasDoubled = false.obs;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 1. Backdrop Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(color: Colors.black.withOpacity(0.7)),
            ),
          ),

          // 2. Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.amber, Colors.blue, Colors.green, Colors.pink],
            ),
          ),

          // 3. Content
          Center(
            child: Container(
              width: 320.w,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1a0b2e).withOpacity(0.95),
                borderRadius: BorderRadius.circular(40.r),
                border: Border.all(color: Colors.amber.withOpacity(0.3), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 40,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cup Icon with Glow
                  _buildIconHeader(),
                  SizedBox(height: 20.h),

                  Text(
                    "AWESOME!",
                    style: GoogleFonts.blackOpsOne(
                      fontSize: 28.sp,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    widget.level != null ? "Level ${widget.level} Cleared!" : "Puzzle Solved!",
                    style: GoogleFonts.quicksand(
                      color: Colors.white70,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 30.h),

                  // Stats Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem("💰 +${widget.coins}", "COINS"),
                      _buildStatItem("✨ +${widget.xp}", "XP"),
                      if (widget.time != null) _buildStatItem("⏱️ ${widget.time}", "TIME"),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Double Coins Button
                  Obx(() => !_hasDoubled.value
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: JuicyButton(
                            label: "DOUBLE REWARD",
                            icon: Icons.play_circle_fill,
                            color: const Color(0xFF6366f1), // Indigo
                            height: 50.h,
                            onTap: () {
                              Get.find<AdsController>().showRewardedAd(
                                onRewardGranted: () {
                                  Get.find<CurrencyController>().doubleLastReward();
                                  _hasDoubled.value = true;
                                },
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink()),

                  // Main Actions
                  JuicyButton(
                    label: "NEXT LEVEL",
                    icon: Icons.arrow_forward_rounded,
                    onTap: widget.onNext,
                    color: Colors.green,
                    height: 56.h,
                  ),
                  SizedBox(height: 12.h),
                  TextButton(
                    onPressed: widget.onHome,
                    child: Text(
                      "Back to Menu",
                      style: GoogleFonts.quicksand(
                        color: Colors.white30,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 90.w,
          height: 90.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.amber.withOpacity(0.1),
          ),
        ),
        Container(
          width: 70.w,
          height: 70.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.orange.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withOpacity(0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Icon(
            Icons.emoji_events_rounded,
            size: 36.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.fredoka(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.quicksand(
            color: Colors.white30,
            fontSize: 10.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}
