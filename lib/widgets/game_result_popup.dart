import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GameResultPopup extends StatefulWidget {
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onHome;
  final bool isTimeUp;

  const GameResultPopup({
    super.key,
    required this.score,
    required this.onRetry,
    required this.onHome,
    this.isTimeUp = true,
  });

  @override
  State<GameResultPopup> createState() => _GameResultPopupState();
}

class _GameResultPopupState extends State<GameResultPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 1. Backdrop with Blur
          Positioned.fill(
            child: GestureDetector(
              onTap: () {}, // Block taps
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
            ),
          ),

          // 2. Popup Card
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 300,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1a0b2e).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(40),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glow behind icon
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.4),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(color: Colors.transparent),
                          ),
                        ),
                        // Icon Circle
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFEF4444),
                                Color(0xFFDC2626)
                              ], // Red-400 to Red-600
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                                color: const Color(0xFF1a0b2e), width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.cancel_outlined, // XCircle equivalent
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Texts
                    Text(
                      "OOPS!",
                      style: GoogleFonts.quicksand(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.isTimeUp
                          ? "Time's up!"
                          : "That wasn't quite right.",
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Score Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "CURRENT SCORE",
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white54,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "⭐ ${widget.score}",
                            style: GoogleFonts.quicksand(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow.shade400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Retry Button
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEF4444), Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            // Add a small delay to show ripple
                            Future.delayed(const Duration(milliseconds: 150),
                                () {
                              widget.onRetry();
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.refresh,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "Try Again",
                                  style: GoogleFonts.quicksand(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Home/Menu Button (Optional Text Button)
                    TextButton(
                      onPressed: widget.onHome,
                      child: Text(
                        "Back to Menu",
                        style: GoogleFonts.quicksand(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white54,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
