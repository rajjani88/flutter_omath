import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';

import 'package:flutter_omath/screens/arrange_numbers/arrange_number.dart';
import 'package:flutter_omath/screens/calculate_numbers/calculate_numbers_screens.dart';
import 'package:flutter_omath/screens/settings/settings_screen.dart';
import 'package:flutter_omath/screens/leaderboard/leaderboard_screen.dart';
import 'package:flutter_omath/screens/achievements/achievements_screen.dart';
import 'package:flutter_omath/screens/math_grid/math_grid_find_number_screen.dart';
import 'package:flutter_omath/screens/go_pro/go_pro_screen.dart';

import 'package:flutter_omath/screens/math_maze/math_maze_view.dart';
import 'package:flutter_omath/screens/profile/profile_screen.dart';
import 'package:flutter_omath/screens/true_false/true_false_game_screen.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';
import 'package:flutter_omath/widgets/floating_background.dart';
import 'package:flutter_omath/widgets/game_icon_3d.dart';
import 'package:flutter_omath/widgets/glass_card.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_omath/widgets/streak_components.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// --- Main Screen ---

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final CurrencyController currencyController = Get.find();
  final UserController userController = Get.find<UserController>();
  final DailyChallengeController dailyController =
      Get.find<DailyChallengeController>(); // Inject
  final SoundController soundController = Get.find<SoundController>();
  final AdsController adsController = Get.find();

  // Bottom Nav State
  String activeTab = 'home'; // home, games, rank, stats

  Future<void> _onTabSelected(String tabId) async {
    soundController.playClick();
    setState(() => activeTab = tabId);

    // 1. If Home is pressed, scroll to top
    if (tabId == 'home') {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut);
      }
      return;
    }

    // 2. Navigate to external screens
    try {
      switch (tabId) {
        case 'games':
          await Get.to(() => const AchievementsScreen());
          break;
        case 'leaderboard':
          await Get.to(() => LeaderboardScreen());
          break;
        case 'profile':
          await Get.to(() => const ProfileScreen());
          break;
      }
    } catch (e) {
      debugPrint("Navigation error: $e");
    }

    // Reset tab to Home when user comes back
    if (mounted) {
      setState(() => activeTab = 'home');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    const Color bgStart = Color(0xFF2d1b4e);
    const Color bgMid = Color(0xFF1a0b2e);
    const Color bgEnd = Color(0xFF0f071a);

    // Dynamic Game Modes List (UPDATED: Icon-based design)
    final List<Map<String, dynamic>> gameModes = [
      {
        "title": "Number Grid",
        "desc": "Find the hidden patterns",
        "color": const Color(0xFF34d399), // Mint Green
        "icon": Icons.grid_3x3,
        "onTap": () => Get.to(() => const MathGridFindNumber())
      },
      {
        "title": "True or False",
        "desc": "Quick math decisions",
        "color": const Color(0xFF38bdf8), // Sky Blue
        "icon": Icons.check_circle_outline,
        "onTap": () => Get.to(() => const TrueFalseGame())
      },
      {
        "title": "Arrange It",
        "desc": "Order from low to high",
        "color": const Color(0xFFfbbf24), // Amber
        "icon": Icons.swap_horiz,
        "onTap": () => Get.to(() => const ArrangeNumber())
      },
      {
        "title": "Calculator",
        "desc": "Solve the equation",
        "color": const Color(0xFFf472b6), // Hot Pink
        "icon": Icons.calculate,
        "onTap": () => Get.to(() =>
            const CalculateNumbersScreen(selectedMode: OperationMode.auto))
      },
      {
        "title": "Math Maze",
        "desc": "Navigate the puzzle",
        "color": const Color(0xFFc084fc), // Purple
        "icon": Icons.extension,
        "onTap": () => Get.to(() => MathMazeView())
      },
    ];

    // double screenWidth = 1.sw;
    // Calculate card width for 2 columns with spacing
    // double cardWidth = (screenWidth - 40.w - 16.w) / 2;

    return Scaffold(
      backgroundColor: bgEnd, // Fallback
      body: Stack(
        children: [
          // 1. Background Gradient & Floating Symbols
          const Positioned.fill(
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
          const FloatingBackground(), // Animated symbols

          // Glare Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withAlpha(25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                        20, 20, 20, 100), // Bottom padding for nav bar
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Header ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [Color(0xFFe2e8f0), Colors.white],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds),
                                  child: Text(
                                    appName,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w800,
                                      fontStyle: FontStyle.italic,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                Text(
                                  "Premium Learning",
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12.sp,
                                    color: const Color(0xFFE9D5FF),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),

                            // Right Side: Coins + Settings
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Coin Capsule
                                GlassCard(
                                  borderRadius: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 4),
                                  onTap: () {
                                    soundController.playClick();
                                    currencyController.watchAdForCoins();
                                  },
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        margin: const EdgeInsets.only(left: 4),
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: Colors.amber.shade400,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                                color: Colors.amber.shade200,
                                                width: 1),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: Colors.amber
                                                      .withAlpha(25),
                                                  blurRadius: 4)
                                            ]),
                                        child: const Text("💲",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.brown)),
                                      ),
                                      const SizedBox(width: 8),
                                      Obx(() => Text(
                                            "${currencyController.coinBalance.value}",
                                            style: GoogleFonts.quicksand(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              letterSpacing: 1,
                                            ),
                                          )),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color(0xFF4ade80),
                                              Color(0xFF16a34a)
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.add,
                                            color: Colors.white, size: 16),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Settings Button
                                GlassCard(
                                  borderRadius: 50,
                                  padding: const EdgeInsets.all(10),
                                  onTap: () {
                                    soundController.playClick();
                                    Get.to(() => const SettingsScreen());
                                  },
                                  child: const Icon(Icons.settings_rounded,
                                      color: Colors.white, size: 22),
                                ),
                              ],
                            ),
                          ],
                        ),

                        SizedBox(height: 12.h),

                        // --- Daily Streak Section ---
                        // DailyStreakCard(userController: userController),
                        Obx(() => StreakHomeCard(
                              streakCount: userController.loginStreak.value,
                              onTap: () =>
                                  _onTabSelected('games'), // Go to Achievements
                              isCompleted:
                                  dailyController.isTodayCompleted.value,
                              onPlay: () {
                                adsController.showRewardedAd(
                                  onRewardGranted: () {
                                    int seed = dailyController.getDailySeed();
                                    Get.to(() => CalculateNumbersScreen(
                                        selectedMode: OperationMode.auto,
                                        isDailyChallenge: true,
                                        dailySeed: seed));
                                  },
                                );
                              },
                            )),

                        SizedBox(height: 12.h),

                        // --- Game Modes ---
                        Row(
                          children: [
                            const Icon(Icons.videogame_asset_rounded,
                                color: Color(0xFFC084FC)),
                            const SizedBox(width: 8),
                            Text(
                              "Play & Learn",
                              style: GoogleFonts.quicksand(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Game Grid (Icon-based design) ---
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16.w,
                            mainAxisSpacing: 16.w,
                            childAspectRatio: 0.85, // Adjusted for card height
                          ),
                          itemCount: gameModes.length,
                          itemBuilder: (context, index) {
                            final mode = gameModes[index];
                            return _buildGameCard(
                              title: mode['title'],
                              desc: mode['desc'],
                              color: mode['color'],
                              icon: mode['icon'],
                              onTap: mode['onTap'],
                            );
                          },
                        ),

                        SizedBox(height: 14.h),
                        Obx(
                          () => adsController.isBannerAdLoaded.value
                              ? SizedBox(
                                  height: AdSize.banner.height.toDouble(),
                                  child: AdWidget(ad: adsController.bannerAd!))
                              : const SizedBox.shrink(),
                        ),

                        SizedBox(height: 14.h),

                        // --- Premium Banner Section ---
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 4),
                        //   child: GlassCard(
                        //     onTap: () {
                        //       soundController.playClick();
                        //       Get.to(() => const GoProScreen());
                        //     },
                        //     borderRadius: 32,
                        //     padding: const EdgeInsets.all(24),
                        //     // Gradient: Purple to Blue low opacity
                        //     gradient: LinearGradient(
                        //       colors: [
                        //         Colors.purple.withOpacity(0.2),
                        //         Colors.blue.withOpacity(0.2),
                        //       ],
                        //       begin: Alignment.centerLeft,
                        //       end: Alignment.centerRight,
                        //     ),
                        //     child: Row(
                        //       children: [
                        //         // Crown Icon Container
                        //         Container(
                        //           width: 48,
                        //           height: 48,
                        //           decoration: BoxDecoration(
                        //             borderRadius: BorderRadius.circular(16),
                        //             gradient: const LinearGradient(
                        //               colors: [
                        //                 Color(0xFFFBBF24), // Amber 400
                        //                 Color(0xFFF97316), // Orange 500
                        //               ],
                        //               begin: Alignment.topLeft,
                        //               end: Alignment.bottomRight,
                        //             ),
                        //             boxShadow: [
                        //               BoxShadow(
                        //                 color: Colors.orange.withOpacity(0.4),
                        //                 blurRadius: 12.r,
                        //                 offset: Offset(0, 4.h),
                        //               )
                        //             ],
                        //           ),
                        //           child: const Icon(
                        //             Icons.workspace_premium_rounded,
                        //             color: Colors.white,
                        //             size: 24,
                        //           ),
                        //         ),
                        //         const SizedBox(width: 16),
                        //         // Text Content
                        //         Expanded(
                        //           child: Column(
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.start,
                        //             children: [
                        //               Text(
                        //                 "Premium Plan",
                        //                 style: GoogleFonts.quicksand(
                        //                   fontSize: 18,
                        //                   fontWeight: FontWeight.bold,
                        //                   color: Colors.white,
                        //                 ),
                        //               ),
                        //               const SizedBox(height: 4),
                        //               Text(
                        //                 "Unlock infinite hearts & juicy themes.",
                        //                 style: GoogleFonts.quicksand(
                        //                   fontSize: 12,
                        //                   color: Colors.white70,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //         ),
                        //         const SizedBox(width: 12),
                        //         // Arrow Button
                        //         Container(
                        //           padding: const EdgeInsets.all(8),
                        //           decoration: BoxDecoration(
                        //             color: Colors.white.withOpacity(0.1),
                        //             shape: BoxShape.circle,
                        //           ),
                        //           child: const Icon(
                        //             Icons.arrow_forward_rounded,
                        //             color: Colors.white,
                        //             size: 16,
                        //           ),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

                        SizedBox(height: 30.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 3. Floating Bottom Nav (4 Icons)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a0b2e).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(32.r),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home, 'home'),
                    _buildNavItem(Icons.videogame_asset, 'games'),
                    _buildNavItem(Icons.emoji_events, 'leaderboard'),
                    _buildNavItem(Icons.bar_chart, 'profile'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String desc,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      onTap: () {
        soundController.playClick();
        onTap();
      },
      borderRadius: 32.r,
      //padding: EdgeInsets.all(10.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 3D Icon with glow
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 30.r,
                      spreadRadius: 5.r,
                    )
                  ],
                ),
              ),
              // 3D Icon
              GameIcon3D(color: color, icon: icon),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            desc,
            style: GoogleFonts.quicksand(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFE9D5FF),
              height: 1.1,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String tabName) {
    bool isActive = activeTab == tabName;
    return GestureDetector(
      onTap: () => _onTabSelected(tabName),
      behavior: HitTestBehavior.opaque, // Fix for touch detection
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        transform: Matrix4.translationValues(0, isActive ? -8 : 0, 0),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Glow effect for active tab
            if (isActive)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFc084fc).withOpacity(0.4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFc084fc).withOpacity(0.6),
                      blurRadius: 20.r,
                      spreadRadius: 2.r,
                    )
                  ],
                ),
              ),
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? Colors.transparent : Colors.transparent,
              ),
              child: Icon(
                icon,
                color: isActive
                    ? const Color(0xFFc084fc)
                    : Colors.white.withOpacity(0.6),
                size: isActive ? 28 : 24,
              ),
            ),
            // Active indicator dot
            if (isActive)
              Positioned(
                bottom: -12,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFc084fc),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFc084fc).withOpacity(0.8),
                        blurRadius: 8,
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Reusable Components ---

class DailyStreakCard extends StatelessWidget {
  final UserController userController;
  const DailyStreakCard({super.key, required this.userController});

  @override
  Widget build(BuildContext context) {
    // Inject DailyChallengeController
    final DailyChallengeController dailyController =
        Get.put(DailyChallengeController(prefs: Get.find<Sharedprefs>().prefs));

    return Obx(() {
      final isCompleted = dailyController.isTodayCompleted.value;

      return GlassCard(
        onTap: () {
          Get.find<SoundController>().playClick();
          if (!isCompleted) {
            // Start Daily Challenge
            Get.to(() => CalculateNumbersScreen(
                  selectedMode: OperationMode.auto,
                  isDailyChallenge: true,
                  dailySeed: dailyController.getDailySeed(),
                ));
          } else {
            // View Achievements
            Get.to(() => const AchievementsScreen());
          }
        },
        padding: const EdgeInsets.all(20),
        borderRadius: 32,
        gradient: LinearGradient(
          colors: [
            isCompleted
                ? Colors.green.withOpacity(0.2)
                : Colors.orange.withOpacity(0.2),
            isCompleted
                ? Colors.teal.withOpacity(0.4)
                : const Color(0xFF581c87).withOpacity(0.4),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isCompleted ? "CHALLENGE COMPLETE" : "DAILY CHALLENGE",
                        style: GoogleFonts.quicksand(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: isCompleted
                                ? Colors.greenAccent
                                : Colors.orange.shade200,
                            letterSpacing: 1.5)),
                    const SizedBox(height: 4),
                    Text(isCompleted ? "COME BACK TOMORROW" : "PLAY NOW",
                        style: GoogleFonts.quicksand(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white)),
                  ],
                ),
                Icon(
                    isCompleted
                        ? Icons.check_circle_outline
                        : Icons.play_circle_fill,
                    size: 48.w,
                    color: isCompleted
                        ? Colors.greenAccent
                        : Colors.orange.shade500,
                    shadows: [
                      Shadow(
                          color: (isCompleted ? Colors.green : Colors.orange)
                              .withOpacity(0.6),
                          blurRadius: 20.r)
                    ]),
              ],
            ),
            const SizedBox(height: 16),
            // Streak Viz
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ['M', 'T', 'W', 'T', 'F', 'S', 'S']
                  .asMap()
                  .entries
                  .map((entry) {
                final idx = entry.key;
                final day = entry.value;

                return Obx(() {
                  // Use DailyChallengeController streak if available, else fallback?
                  // Actually let's use dailyController.currentStreak for consistency with this card
                  final streak = dailyController.currentStreak.value;
                  // For visual simplicity, let's assume streak maps to days 0-6 relative to something?
                  // Or just simple circles:
                  // The original code used 'loginStreak' and mapped to M-S.
                  // Let's keep the M-S visual but highlight based on count (mod 7).

                  bool active = idx < (streak % 7) || (streak >= 7 && idx < 7);
                  // If streak is 0, none active
                  if (streak == 0) active = false;

                  // Highlight today if completed
                  // This visualization is abstract, let's stick to the previous simple logic but with daily streak

                  bool isCurrent = idx == ((streak - 1) % 7);
                  if (streak == 0) isCurrent = false;

                  Color bg = active ? Colors.orange.shade500 : Colors.black26;
                  Color textC = active ? Colors.white : Colors.white30;
                  BoxBorder? border =
                      active ? null : Border.all(color: Colors.white12);

                  if (isCurrent && isCompleted) {
                    bg = Colors.green;
                  }

                  return Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: bg,
                      shape: BoxShape.circle,
                      border: border,
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color: Colors.orange.withOpacity(0.4),
                                  blurRadius: 8.r)
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(day,
                          style: GoogleFonts.quicksand(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: textC)),
                    ),
                  );
                });
              }).toList(),
            ),
          ],
        ),
      );
    });
  }
}
