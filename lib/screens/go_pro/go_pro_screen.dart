import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/widgets/glass_back_button.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class GoProScreen extends StatefulWidget {
  const GoProScreen({super.key});

  @override
  State<GoProScreen> createState() => _GoProScreenState();
}

class _GoProScreenState extends State<GoProScreen> {
  final InAppPurchaseController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Custom Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        GlassBackButton(onTap: () => Get.back()),
                        const SizedBox(width: 16),
                        Text(
                          "Go Pro!",
                          style: GoogleFonts.fredoka(
                            fontSize: 24,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Logo
                  FadeInDown(
                    child: Hero(
                      tag: 'logo',
                      child: Container(
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: GameColors.primary.withOpacity(0.5),
                                  blurRadius: 30)
                            ]),
                        child: Image.asset(
                          imgLogoTr,
                          height: 120,
                          width: 120,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Become a Pro Member',
                      style: GoogleFonts.fredoka(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.2))),
                    child: Column(
                      children: [
                        _buildFeatureRow("One Time Payment",
                            Icons.monetization_on_rounded, GameColors.success),
                        const SizedBox(height: 16),
                        _buildFeatureRow('Unlimited Game modes',
                            Icons.games_rounded, GameColors.primary),
                        const SizedBox(height: 16),
                        _buildFeatureRow(
                            'No Ads', Icons.block_rounded, GameColors.danger),
                        const SizedBox(height: 16),
                        _buildFeatureRow('Daily Challenges',
                            Icons.calendar_today_rounded, GameColors.secondary),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Bottom Sheet (Fixed at bottom via Column)
          FadeInUp(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: GameColors.panel,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, -5))
                  ]),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Train Your Brain with Math!',
                    style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Obx(
                    () => controller.price.value.isEmpty
                        ? const SizedBox(
                            height: 30,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : GameButton(
                            text: 'Buy Pro ${controller.price.value}',
                            color: GameColors.success,
                            shadowColor: GameColors.successShadow,
                            fontSize: 20,
                            height: 60,
                            onTap: () {
                              controller.buyPro();
                            },
                          ),
                  ),
                  const SizedBox(height: 20),
                  PrivacyTermsRow(
                    showRestore: true,
                    onRestoreClick: () {
                      // Implement restore logic if needed or just trigger controller
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String title, IconData icon, Color color) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
