import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/widgets/glass_card.dart';
import 'package:flutter_omath/widgets/juicy_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class DailyChallengeSuccessPopup extends StatefulWidget {
  final int streak;
  final VoidCallback onContinue;

  const DailyChallengeSuccessPopup({
    super.key,
    required this.streak,
    required this.onContinue,
  });

  @override
  State<DailyChallengeSuccessPopup> createState() =>
      _DailyChallengeSuccessPopupState();
}

class _DailyChallengeSuccessPopupState
    extends State<DailyChallengeSuccessPopup> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Card
          GlassCard(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
            // border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2), // Removed invalid param
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.8),
                const Color(0xFF2e1065).withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header Icon
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Colors.amber, Colors.orange],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  "CHALLENGE CRUSHED!",
                  style: GoogleFonts.blackOpsOne(
                    fontSize: 24,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                Text(
                  "You kept the flame alive!",
                  style: GoogleFonts.quicksand(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Streak Display
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("🔥", style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "DAILY STREAK",
                            style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.orangeAccent,
                            ),
                          ),
                          Text(
                            "${widget.streak} DAYS",
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Button
                JuicyButton(
                  label: "CONTINUE", // Fixed parameter name
                  onTap: widget.onContinue,
                  color: Colors.green,
                  // width: double.infinity, // Removed invalid param
                  height: 56,
                  icon: Icons.arrow_forward_rounded,
                ),
              ],
            ),
          ),

          // Confetti
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
            numberOfParticles: 50,
          ),
        ],
      ),
    );
  }
}
