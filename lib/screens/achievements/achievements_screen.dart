import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter_omath/widgets/glass_card.dart'; // New Import
import 'package:flutter_omath/widgets/floating_background.dart'; // New Import
import 'package:flutter_omath/widgets/streak_components.dart';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final UserController userController = Get.find<UserController>();
  final AchievementController achievementController =
      Get.find<AchievementController>();

  // Theme Colors

  //final AdsController adsController = Get.find<AdsController>();
  Timer? _adsTimer;

  void showAds() {
    if (_adsTimer != null) {
      return;
    }
    log('timer is started');
    _adsTimer = Timer(const Duration(seconds: 13), () {
      // adsController.showInterstitialAd();
    });
  }

  @override
  void initState() {
    super.initState();
    showAds();
  }

  @override
  void dispose() {
    super.dispose();

    _adsTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    Color bgStart = const Color(0xFF2d1b4e);
    Color bgMid = const Color(0xFF1a0b2e);
    Color bgEnd = const Color(0xFF0f071a);

    return Scaffold(
      backgroundColor: bgEnd,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 70,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Center(child: GlassBackButton(onTap: () => Get.back())),
        title: Text(
          "Achievements",
          style: GoogleFonts.quicksand(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 1. Background Gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [bgStart, bgMid, bgEnd],
                ),
              ),
            ),
          ),

          // 2. Animated Symbols
          const FloatingBackground(),

          // 3. Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Streak Card
                Obx(() => StreakHomeCard(
                      streakCount: userController.loginStreak.value,
                    )),

                const SizedBox(height: 30),

                // Section Header
                Text(
                  "BADGES",
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC084FC),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),

                // Achievements by Category
                _buildCategorySection("Economy", achievementController),
                const SizedBox(height: 16),
                _buildCategorySection("Dedication", achievementController),
                const SizedBox(height: 16),
                _buildCategorySection("Skill", achievementController),
                const SizedBox(height: 16),
                _buildCategorySection("Social", achievementController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      String category, AchievementController controller) {
    final achievements = controller.getByCategory(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            category.toUpperCase(),
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.white38,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...achievements.map((achievement) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Obx(() => _buildAchievementCard(achievement)),
            )),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked.value;
    final progress = achievement.progress;
    final hasProgress = progress > 0;

    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      gradient: isUnlocked
          ? LinearGradient(
              colors: [
                Colors.amber.withOpacity(0.15),
                Colors.amber.withOpacity(0.05),
              ],
            )
          : null,
      child: Row(
        children: [
          // Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? Colors.amber.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05),
              border: Border.all(
                color: isUnlocked
                    ? Colors.amber.withOpacity(0.5)
                    : Colors.white.withOpacity(0.1),
                width: 2,
              ),
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: Center(
              child: isUnlocked
                  ? Text(achievement.icon, style: const TextStyle(fontSize: 28))
                  : const Icon(Icons.lock_outline,
                      color: Colors.white24, size: 28),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.white : Colors.white38,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: GoogleFonts.quicksand(
                    fontSize: 12,
                    color: isUnlocked ? Colors.white70 : Colors.white24,
                  ),
                ),

                // Progress Bar (if has progress)
                if (hasProgress && !isUnlocked) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${achievement.currentValue.value} / ${achievement.targetValue}",
                        style: GoogleFonts.quicksand(
                          fontSize: 10,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Colors.purpleAccent),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
