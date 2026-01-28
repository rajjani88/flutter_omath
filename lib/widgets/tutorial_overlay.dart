import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_omath/widgets/glass_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({super.key});

  static void show() {
    Get.dialog(
      const TutorialOverlay(),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: GlassCard(
            borderRadius: 32,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "How to Play",
                        style: GoogleFonts.quicksand(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    children: [
                      _buildSlide(
                        title: "Daily Challenge",
                        description:
                            "Keep your streak alive! Play the daily challenge every day to earn massive rewards and exclusive badges. Don't break the chain!",
                        icon: Icons.whatshot,
                        color: Colors.orange,
                      ),
                      _buildSlide(
                        title: "Number Grid",
                        description:
                            "Find the hidden pattern or missing number in the grid. Swipe or tap to select the correct answer before time runs out!",
                        icon: Icons.grid_3x3,
                        color: Colors.teal,
                      ),
                      _buildSlide(
                        title: "True or False",
                        description:
                            "Think fast! Decide if the equation is Correct or Incorrect. Speed is key to earning high scores.",
                        icon: Icons.check_circle_outline,
                        color: Colors.blue,
                      ),
                      _buildSlide(
                        title: "Arrange It",
                        description:
                            "Order the numbers from Lowest to Highest. Tap them in the correct sequence to clear the board.",
                        icon: Icons.swap_horiz,
                        color: Colors.amber,
                      ),
                      _buildSlide(
                        title: "Calculator",
                        description:
                            "Solve the math problem by typing the correct answer using the numpad. Use power-ups if you get stuck!",
                        icon: Icons.calculate,
                        color: Colors.pink,
                      ),
                      _buildSlide(
                        title: "Math Maze",
                        description:
                            "Navigate the maze to reach the target number. Plan your path carefully to hit the exact sum!",
                        icon: Icons.extension,
                        color: Colors.purple,
                      ),
                    ],
                  ),
                ),
                // Indicators? Simpler to just have swipe hint
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    "Swipe to explore modes ->",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      color: Colors.white30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Icon(icon, size: 60, color: color),
          ),
          const SizedBox(height: 30),
          Text(
            title,
            style: GoogleFonts.quicksand(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.quicksand(
              fontSize: 16,
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
