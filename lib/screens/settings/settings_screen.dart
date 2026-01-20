import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/widgets/tutorial_overlay.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Colors (Matches HomeScreen)
    const Color bgStart = Color(0xFF2d1b4e);
    const Color bgMid = Color(0xFF1a0b2e);
    const Color bgEnd = Color(0xFF0f071a);

    final SoundController soundController = Get.find<SoundController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leadingWidth: 70,
        leading: const Center(child: GlassBackButton()),
        title: Text(
          "Settings",
          style: GoogleFonts.quicksand(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgStart, bgMid, bgEnd],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 10),

                // Audio Section
                _buildSectionTitle("AUDIO & HAPTICS"),
                const SizedBox(height: 10),

                Obx(() => _buildGlassSwitch(
                      label: "Background Music",
                      icon: Icons.music_note_rounded,
                      value: soundController.isMusicOn.value,
                      onChanged: (val) => soundController.toggleMusic(val),
                      color: Colors.purpleAccent,
                    )),
                const SizedBox(height: 12),

                Obx(() => _buildGlassSwitch(
                      label: "Sound Effects",
                      icon: Icons.volume_up_rounded,
                      value: soundController.isSfxOn.value,
                      onChanged: (val) => soundController.toggleSfx(val),
                      color: Colors.blueAccent,
                    )),
                const SizedBox(height: 12),

                Obx(() => _buildGlassSwitch(
                      label: "Vibration",
                      icon: Icons.vibration_rounded,
                      value: soundController.isVibrationOn.value,
                      onChanged: (val) => soundController.toggleVibration(val),
                      color: Colors.orangeAccent,
                    )),

                const SizedBox(height: 30),

                // Support Section
                _buildSectionTitle("SUPPORT"),
                const SizedBox(height: 10),

                _buildGlassButton(
                  label: "How to Play",
                  icon: Icons.help_outline_rounded,
                  onTap: () => TutorialOverlay.show(),
                ),
                const SizedBox(height: 12),

                _buildGlassButton(
                  label: "Privacy Policy",
                  icon: Icons.privacy_tip_outlined,
                  onTap: () async {
                    const url =
                        'https://sites.google.com/view/brainy-math-app/privacy-policy'; // From consts.dart if available
                    if (!await launchUrl(Uri.parse(url))) {
                      Get.snackbar("Error", "Could not launch URL");
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildGlassButton(
                  label: "Terms & Conditions",
                  icon: Icons.description_outlined,
                  onTap: () async {
                    const url =
                        'https://sites.google.com/view/brainy-math-app/terms-and-conditions';
                    if (!await launchUrl(Uri.parse(url))) {
                      Get.snackbar("Error", "Could not launch URL");
                    }
                  },
                ),
                const SizedBox(height: 12),
                _buildGlassButton(
                  label: "Rate Us",
                  icon: Icons.star_rate_rounded,
                  onTap: () async {
                    final Uri marketUri = Uri.parse(urlRateUs);
                    final Uri webUri = Uri.parse(urlRateUsWeb);

                    if (await canLaunchUrl(marketUri)) {
                      await launchUrl(marketUri,
                          mode: LaunchMode.externalApplication);
                    } else if (await canLaunchUrl(webUri)) {
                      await launchUrl(webUri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      Get.snackbar("Error", "Could not open store");
                    }
                  },
                ),

                const SizedBox(height: 50),

                Center(
                  child: Text(
                    "Version 1.9.0",
                    style: GoogleFonts.quicksand(
                        fontSize: 12,
                        color: Colors.white30,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Text(
        title,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFC084FC),
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildGlassSwitch({
    required String label,
    required IconData icon,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.quicksand(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Switch.adaptive(
                value: value,
                onChanged: onChanged,
                activeColor: color,
                activeTrackColor: color.withOpacity(0.4),
                inactiveThumbColor: Colors.grey.shade400,
                inactiveTrackColor: Colors.white10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 22),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.quicksand(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white30, size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
