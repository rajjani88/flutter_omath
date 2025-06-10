import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/commons/show_unlock_game_mode.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/screens/arrange_numbers/arrange_number.dart';
import 'package:flutter_omath/screens/calculate_numbers/calculate_numbers_screens.dart';
import 'package:flutter_omath/screens/go_pro/go_pro_screen.dart';
import 'package:flutter_omath/screens/home_screen/widgets/build_game_option.dart';
import 'package:flutter_omath/screens/math_grid/math_grid_find_number_screen.dart';
import 'package:flutter_omath/screens/math_maze/math_maze_view.dart';
import 'package:flutter_omath/screens/true_false/true_false_game_screen.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AdsController adsController = Get.find();
  InAppPurchaseController purchaseController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mAppBlue,
      body: Column(
        children: [
          const SizedBox(
            height: 56,
          ),
          Row(
            children: [
              Hero(
                tag: 'logo',
                child: Image.asset(
                  imgLogoTr,
                  height: 60,
                  width: 60,
                ),
              ),
              const Text(
                appName,
                style: TextStyle(
                    color: mWhitecolor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),

          //game ottions
          BuildGameOption(
            title: 'Math Grid (3x3)',
            subTitle: 'Find Correct number from Grid',
            onTap: () {
              if (purchaseController.isPro.value) {
                Get.to(() => const ArrangeNumber());
                return;
              }
              if (adsController.isInterstitialAdLoaded.value) {
                adsController.showInterstitialAd();
                Get.to(() => const MathGridFindNumber());
              }
            },
            imgName: imgMathgrid,
          ),
          const SizedBox(
            height: 14,
          ),

          BuildGameOption(
              title: 'True or False',
              subTitle: 'can you find statement is True or False ?',
              onTap: () {
                if (purchaseController.isPro.value) {
                  Get.to(() => const TrueFalseGame());
                  return;
                }
                if (adsController.isInterstitialAdLoaded.value) {
                  adsController.showInterstitialAd();
                  Get.to(() => const TrueFalseGame());
                }
              },
              imgName: imgTrueOrFalse),
          const SizedBox(
            height: 14,
          ),
          BuildGameOption(
            title: 'Arrange Number',
            subTitle: 'Arrange Number in order within the given time.',
            onTap: () {
              if (purchaseController.isPro.value) {
                Get.to(() => const ArrangeNumber());
                return;
              }
              showUnlockGameModeDialog(
                onWatchAd: () {
                  if (adsController.isRewardedAdLoaded.value) {
                    adsController.showRewardedAd(
                      onRewardGranted: () {
                        Get.to(() => const ArrangeNumber());
                      },
                    );
                  } else {
                    Get.snackbar(
                        'Ad not ready', 'Please try again in a moment');
                  }
                },
                onGoPro: () {
                  Get.to(() => const GoProScreen());
                },
              );
            },
            imgName: imgNumber,
          ),
          const SizedBox(
            height: 14,
          ),
          BuildGameOption(
              title: 'Calculate ',
              subTitle: 'Solve basic calculation problems.',
              onTap: () {
                if (purchaseController.isPro.value) {
                  Get.to(() => const CalculateNumbersScreen(
                      selectedMode: OperationMode.auto));
                  return;
                }
                showUnlockGameModeDialog(
                  onWatchAd: () {
                    if (adsController.isRewardedAdLoaded.value) {
                      adsController.showRewardedAd(
                        onRewardGranted: () {
                          Get.to(() => const CalculateNumbersScreen(
                              selectedMode: OperationMode.auto));
                        },
                      );
                    } else {
                      Get.snackbar(
                          'Ad not ready', 'Please try again in a moment');
                    }
                  },
                  onGoPro: () {
                    Get.to(() => const GoProScreen());
                  },
                );
              },
              imgName: imgcalculator),
          const SizedBox(
            height: 14,
          ),

          BuildGameOption(
            title: 'Math Maze',
            subTitle: '4 moves to reach the target',
            onTap: () {
              if (purchaseController.isPro.value) {
                Get.to(() => MathMazeView());
                return;
              }
              showUnlockGameModeDialog(
                onWatchAd: () {
                  if (adsController.isRewardedAdLoaded.value) {
                    adsController.showRewardedAd(
                      onRewardGranted: () {
                        Get.to(() => MathMazeView());
                      },
                    );
                  } else {
                    Get.snackbar(
                        'Ad not ready', 'Please try again in a moment');
                  }
                },
                onGoPro: () {
                  Get.to(() => const GoProScreen());
                },
              );
            },
            imgName: imgMathmaze,
          ),
          const Spacer(),
          const PrivacyTermsRow(),
          const SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }
}
