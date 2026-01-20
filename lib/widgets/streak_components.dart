import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Constants for Colors (Matching React Design) ---
class StreakColors {
  static const Color orangeStart = Color(0xFFEA580C); // orange-600
  static const Color redEnd = Color(0xFFDC2626); // red-600
  static const Color yellowFlame = Color(0xFFFACC15); // yellow-400
  static const Color orangeText = Color(0xFFC2410C); // orange-700
  static const Color glassBorder = Colors.white24;
}

// --- Common: Pulsing Flame Icon Widget ---
class PulsingFlameIcon extends StatefulWidget {
  final double size;
  const PulsingFlameIcon({super.key, required this.size});

  @override
  State<PulsingFlameIcon> createState() => _PulsingFlameIconState();
}

class _PulsingFlameIconState extends State<PulsingFlameIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      // Note: Use Icons.local_fire_department or a custom asset here
      child: Icon(
        Icons.local_fire_department_rounded,
        size: widget.size,
        color: StreakColors.yellowFlame,
        shadows: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}

// --- 1. Home Screen Streak Card (Scoreboard Style) ---
class StreakHomeCard extends StatelessWidget {
  final int streakCount;
  final VoidCallback? onTap;
  final VoidCallback? onPlay;
  final bool isCompleted;

  const StreakHomeCard({
    super.key,
    required this.streakCount,
    this.onTap,
    this.onPlay,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: const LinearGradient(
            colors: [StreakColors.orangeStart, StreakColors.redEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: StreakColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: StreakColors.orangeStart.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              // Background Decor
              Positioned(
                right: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.local_fire_department,
                      size: 150, color: Colors.white),
                ),
              ),

              // Content
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CURRENT STREAK",
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade100,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  "$streakCount",
                                  style: GoogleFonts.fredoka(
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  "Days",
                                  style: GoogleFonts.nunito(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade100,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Small Flame Box
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white30),
                          ),
                          child: const Center(
                            child: PulsingFlameIcon(size: 32),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Area
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    color: Colors.black.withOpacity(0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isCompleted
                              ? "Daily Challenge Completed!"
                              : "Play Daily Challenge",
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        if (!isCompleted && onPlay != null)
                          GestureDetector(
                            onTap: onPlay,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    "PLAY",
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: StreakColors.orangeText,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.play_arrow_rounded,
                                      size: 16, color: StreakColors.orangeText),
                                ],
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- 2. Profile Screen Streak Card (Snapchat Style) ---
class StreakProfileCard extends StatelessWidget {
  final int streakCount;

  const StreakProfileCard({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 280, // Taller card for profile
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [StreakColors.orangeStart, StreakColors.redEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Texture Overlay (Simple dots)
            CustomPaint(
              size: Size.infinite,
              painter: DotTexturePainter(),
            ),

            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Flame & Badge Stack
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Glowing background behind flame
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade300.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    // Main Flame Icon
                    const PulsingFlameIcon(size: 100),

                    // Floating Number Badge
                    Positioned(
                      bottom: -15,
                      child: Transform.rotate(
                        angle: -3 * (math.pi / 180), // -3 degrees rotation
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                                color: Colors.orange.shade200, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Text(
                            "$streakCount",
                            style: GoogleFonts.fredoka(
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              color: StreakColors.orangeText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 35),

                Text(
                  "DAY STREAK",
                  style: GoogleFonts.fredoka(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "You're unstoppable! 🔥",
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper: Dot Texture Painter ---
class DotTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    const double spacing = 20;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Offset every other row
        double dx = x + ((y / spacing).round() % 2 == 0 ? 0 : spacing / 2);
        canvas.drawCircle(Offset(dx, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
