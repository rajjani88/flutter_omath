import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String subTitle;
  final String imgName;
  final VoidCallback onTap;
  final Color color;

  const GameCard({
    super.key,
    required this.title,
    required this.subTitle,
    required this.imgName,
    required this.onTap,
    this.color = GameColors.secondary,
  });

  @override
  Widget build(BuildContext context) {
    // Sound Controller for optional click sound if not handled by parent (though usually handled by onTap)
    final soundController = Get.find<SoundController>();

    return GestureDetector(
      onTap: () {
        soundController.playClick();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: GameColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            // Bottom "3D" edge
            BoxShadow(
              color: GameColors.panel.withOpacity(0.5),
              offset: const Offset(0, 8),
              blurRadius: 0,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background accent
              Positioned(
                right: -20,
                bottom: -20,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: color.withOpacity(0.1),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(imgName, height: 60, width: 60),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: GameColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subTitle,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
