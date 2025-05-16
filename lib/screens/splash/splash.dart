import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mAppBlue,
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      imgLogoTr,
                      height: 240,
                      width: 240,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 16,
            left: 22,
            right: 22,
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Train Your Brain with Some Math.',
                      style: TextStyle(
                          color: mWhitecolor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    )
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          onPressed: () {
                            Get.to(() => const HomeScreen());
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                  color: mAppBlue,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600),
                            ),
                          )),
                    )
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                const PrivacyTermsRow(),
                const SizedBox(
                  height: 16,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
