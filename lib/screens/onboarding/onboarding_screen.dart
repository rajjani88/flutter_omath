import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/glass_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Train Your Brain",
      "description":
          "Engage your mind with fun, challenging math puzzles designed for all skill levels.",
      "icon": Icons.psychology_rounded,
      "color": GameColors.primary,
    },
    {
      "title": "Track Your Progress",
      "description":
          "Build a daily streak and watch your cognitive skills soar over time.",
      "icon": Icons.trending_up_rounded,
      "color": GameColors.success,
    },
    {
      "title": "Achieve Greatness",
      "description":
          "Unlock new challenges, collect achievements, and become a MathWize.",
      "icon": Icons.emoji_events_rounded,
      "color": GameColors.secondary,
    },
  ];

  Future<void> _completeOnboarding() async {
    try {
      Get.find<SoundController>().playClick();
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);

    if (mounted) {
      Get.offAll(() => const HomeScreen());
    }
  }

  void _nextPage() {
    try {
      Get.find<SoundController>().playClick();
    } catch (_) {}

    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCirc,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.bgBottom,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [GameColors.bgTop, GameColors.bgBottom],
              ),
            ),
          ),

          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: _onboardingData.length,
            itemBuilder: (context, index) {
              return _buildPage(_onboardingData[index]);
            },
          ),

          // Bottom Navigation Area
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // Page Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _onboardingData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? GameColors.primary
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Next / Get Started Button
                GestureDetector(
                  onTap: _nextPage,
                  child: GlassCard(
                    borderRadius: 30,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    gradient: LinearGradient(
                      colors: [
                        GameColors.primary.withOpacity(0.5),
                        GameColors.primary.withOpacity(0.2),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _currentPage == _onboardingData.length - 1
                            ? "Get Started"
                            : "Next",
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Glassmorphic Icon Container
          GlassCard(
            borderRadius: 60,
            padding: const EdgeInsets.all(32),
            gradient: LinearGradient(
              colors: [
                data['color'].withOpacity(0.3),
                data['color'].withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Icon(
              data['icon'],
              size: 100,
              color: data['color'],
            ),
          ),
          const SizedBox(height: 60),

          // Title
          Text(
            data['title'],
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),

          // Description
          Text(
            data['description'],
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 100), // Space for bottom controls
        ],
      ),
    );
  }
}
