import 'dart:async';
import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/leaderboard_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:get/get.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final LeaderboardController controller = Get.find<LeaderboardController>();
  final AdsController adsController = Get.find<AdsController>();
  Timer? _adsTimer;

  void showAds() {
    if (_adsTimer != null) {
      return;
    }
    log('timer is started');
    _adsTimer = Timer(const Duration(seconds: 13), () {
      adsController.showInterstitialAd();
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
    if (_adsTimer != null) {
      _adsTimer!.cancel();
      _adsTimer = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                GlassBackButton(onTap: () => Get.back()),
                const SizedBox(width: 16),
                Text(
                  "🏆 Leaderboard",
                  style: GoogleFonts.fredoka(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Refresh button
                // Refresh button
                GestureDetector(
                  onTap: () {
                    try {
                      Get.find<SoundController>().playClick();
                    } catch (_) {}
                    controller.refresh();
                  },
                  child: Container(
                    width: 45,
                    height: 45,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Leaderboard List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: GameColors.secondary),
                );
              }

              if (controller.hasError.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load leaderboard",
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GameButton(
                        text: "Retry",
                        icon: Icons.refresh,
                        width: 120,
                        height: 45,
                        color: GameColors.primary,
                        shadowColor: GameColors.primaryShadow,
                        onTap: () => controller.refresh(),
                      ),
                    ],
                  ),
                );
              }

              if (controller.topPlayers.isEmpty) {
                return Center(
                  child: Text(
                    "No players yet. Be the first!",
                    style: GoogleFonts.nunito(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  // Top Players List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.topPlayers.length,
                      itemBuilder: (context, index) {
                        final entry = controller.topPlayers[index];
                        return FadeInUp(
                          delay: Duration(milliseconds: 50 * index),
                          child: _buildLeaderboardTile(entry),
                        );
                      },
                    ),
                  ),

                  // Current User (if not in top 50)
                  if (!controller.isCurrentUserInTop50 &&
                      controller.currentUserEntry.value != null)
                    _buildCurrentUserFooter(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTile(LeaderboardEntry entry) {
    // Special styling for top 3
    Color? tileColor;
    String? trophy;

    if (entry.rank == 1) {
      trophy = "🥇";
      tileColor = Colors.amber.shade700;
    } else if (entry.rank == 2) {
      trophy = "🥈";
      tileColor = Colors.grey.shade400;
    } else if (entry.rank == 3) {
      trophy = "🥉";
      tileColor = Colors.orange.shade700;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? GameColors.secondary.withOpacity(0.3)
            : GameColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: entry.isCurrentUser
            ? Border.all(color: GameColors.secondary, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tileColor ?? Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: trophy != null
                ? Text(trophy, style: const TextStyle(fontSize: 20))
                : Text(
                    "${entry.rank}",
                    style: GoogleFonts.fredoka(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),

          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                SupabaseConfig.getAvatarPath(entry.avatarId),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: GameColors.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.odUsername,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.isCurrentUser)
                  Text(
                    "You",
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: GameColors.secondary,
                    ),
                  ),
              ],
            ),
          ),

          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("⭐", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  "${entry.totalXp}",
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentUserFooter() {
    final entry = controller.currentUserEntry.value!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: GameColors.secondary.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GameColors.secondary, width: 2),
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: GameColors.secondary,
              shape: BoxShape.circle,
            ),
            child: Text(
              "#${entry.rank}",
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: GameColors.secondary, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                SupabaseConfig.getAvatarPath(entry.avatarId),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: GameColors.primary,
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.odUsername,
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Your Rank",
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: GameColors.secondary,
                  ),
                ),
              ],
            ),
          ),

          // XP
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("⭐", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  "${entry.totalXp}",
                  style: GoogleFonts.fredoka(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
