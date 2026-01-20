import 'dart:async';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Wait for 3 seconds (splash animation + initialization time)
    await Future.delayed(const Duration(seconds: 3));

    // Ensure controllers are ready (they should be from DI, but we verify)
    try {
      Get.find<UserController>();
      Get.find<SoundController>();
    } catch (e) {
      debugPrint('Controller initialization warning: $e');
    }

    // Navigate to Home Screen (removing splash from stack)
    if (mounted) {
      Get.offAll(() => const HomeScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Cosmic Theme Colors
    const Color bgStart = Color(0xFF2d1b4e);
    const Color bgMid = Color(0xFF1a0b2e);
    const Color bgEnd = Color(0xFF0f071a);

    return Scaffold(
      backgroundColor: bgEnd,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgStart, bgMid, bgEnd],
          ),
        ),
        child: Stack(
          children: [
            // Animated Stars/Math Symbols Background (Optional subtle effect)
            ...List.generate(15, (index) {
              return Positioned(
                top: (index * 50.0) % MediaQuery.of(context).size.height,
                left: (index * 80.0) % MediaQuery.of(context).size.width,
                child: FadeIn(
                  delay: Duration(milliseconds: index * 100),
                  child: Text(
                    ['✨', '➕', '➖', '✖️', '➗', '🔢'][index % 6],
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ),
              );
            }),

            // Center Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with Zoom + Fade Animation
                  FadeIn(
                    duration: const Duration(milliseconds: 1500),
                    child: ZoomIn(
                      duration: const Duration(milliseconds: 1500),
                      child: Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purpleAccent.withOpacity(0.5),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            imgLogoTr, // From consts.dart
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App Name with Gradient Text
                  FadeIn(
                    delay: const Duration(milliseconds: 500),
                    duration: const Duration(milliseconds: 1500),
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFFfbbf24), // Gold
                          Color(0xFFffffff), // White
                          Color(0xFFc084fc), // Purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(bounds),
                      child: Text(
                        appName,
                        style: GoogleFonts.quicksand(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                          color: Colors.white, // Base color for ShaderMask
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Tagline
                  FadeIn(
                    delay: const Duration(milliseconds: 800),
                    duration: const Duration(milliseconds: 1500),
                    child: Text(
                      "Train Your Brain with Math",
                      style: GoogleFonts.quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Loading Indicator
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: FadeIn(
                delay: const Duration(milliseconds: 1200),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
