import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/widgets/game_background.dart';
import 'package:flutter_omath/widgets/game_button.dart';
import 'package:flutter_omath/utils/game_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GameBackground(
      child: Stack(
        children: [
          Center(
            child: FadeInDown(
              child: Hero(
                tag: 'logo',
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                    BoxShadow(
                        color: GameColors.primary.withOpacity(0.5),
                        blurRadius: 40)
                  ]),
                  child: Image.asset(
                    imgLogoTr,
                    height: 240,
                    width: 240,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Train Your Brain with Math',
                    style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: GameButton(
                    text: "Continue",
                    color: Colors.white,
                    textColor:
                        GameColors.bgBottom, // Purple text on white button
                    shadowColor: Colors.grey.shade400,
                    fontSize: 22,
                    onTap: () {
                      Get.to(() => const HomeScreen());
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FadeInUp(
                    delay: const Duration(milliseconds: 600),
                    child: const PrivacyTermsRow()),
              ],
            ),
          )
        ],
      ),
    );
  }
}
