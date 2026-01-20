import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/screens/arrange_numbers/arrange_number.dart';
import 'package:flutter_omath/screens/calculate_numbers/calculate_numbers_screens.dart';
import 'package:flutter_omath/screens/go_pro/go_pro_screen.dart';
import 'package:flutter_omath/screens/math_grid/math_grid_find_number_screen.dart';
import 'package:flutter_omath/screens/math_maze/math_maze_view.dart';
import 'package:flutter_omath/screens/true_false/true_false_game_screen.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_card.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AdsController adsController = Get.find();
  InAppPurchaseController purchaseController = Get.find();
  SoundController soundController = Get.find();

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Header with Animation
            FadeInDown(
              duration: const Duration(milliseconds: 800),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: Image.asset(imgLogoTr, width: 40, height: 40),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    appName,
                    style: GoogleFonts.fredoka(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  _buildIconButton(imgPro, () {
                    Get.to(() => const GoProScreen());
                  }),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Main Menu Grid
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 1000),
                delay: const Duration(milliseconds: 200),
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    GameCard(
                      title: 'Math Grid',
                      subTitle: 'Find number',
                      imgName: imgMathgrid,
                      color: GameColors.secondary,
                      onTap: () => Get.to(() => const MathGridFindNumber()),
                    ),
                    GameCard(
                      title: 'True/False',
                      subTitle: 'Correct statement?',
                      imgName: imgTrueOrFalse,
                      color: GameColors.danger,
                      onTap: () => Get.to(() => const TrueFalseGame()),
                    ),
                    GameCard(
                      title: 'Arrange',
                      subTitle: 'Order numbers',
                      imgName: imgNumber,
                      color: GameColors.primary,
                      onTap: () => Get.to(() => const ArrangeNumber()),
                    ),
                    GameCard(
                      title: 'Calculate',
                      subTitle: 'Basic Ops',
                      imgName: imgcalculator,
                      color: GameColors.success,
                      onTap: () => Get.to(() => const CalculateNumbersScreen(
                          selectedMode: OperationMode.auto)),
                    ),
                    // Spanning card or different layout for last one? keeping consistent for now
                    GameCard(
                      title: 'Math Maze',
                      subTitle: 'Reach target',
                      imgName: imgMathmaze,
                      color: Colors.orange,
                      onTap: () => Get.to(() => MathMazeView()),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Privacy Links
            FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 500),
                child: const PrivacyTermsRow()),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(String iconAsset, VoidCallback onTap) {
    return GestureDetector(
      onTap: () {
        soundController.playClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Image.asset(iconAsset, width: 28, height: 28),
      ),
    );
  }
}
