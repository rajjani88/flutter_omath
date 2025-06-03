import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';

class GoProScreen extends StatefulWidget {
  const GoProScreen({super.key});

  @override
  State<GoProScreen> createState() => _GoProScreenState();
}

class _GoProScreenState extends State<GoProScreen> {
  InAppPurchaseController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mAppBlue,
      appBar: AppBar(
        leading: const BackButton(
          color: mWhitecolor,
        ),
        backgroundColor: mAppBlue,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Hero(
                    tag: 'logo',
                    child: Image.asset(
                      imgLogoTr,
                      height: 100,
                      width: 100,
                    ),
                  ),
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Become Pro-Member.',
                    style: TextStyle(
                        color: mWhitecolor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  )
                ],
              ),
              const SizedBox(
                height: 100,
              ),
              _buildFeatureRow("One Time Payment"),
              const SizedBox(
                height: 16,
              ),
              _buildFeatureRow('Unlimited Game modes'),
              const SizedBox(
                height: 16,
              ),
              _buildFeatureRow('No Ads'),
              const SizedBox(
                height: 16,
              ),
              _buildFeatureRow('Daily Challege and Rewards'),
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
                      child: Obx(
                        () => controller.price.value.isEmpty
                            ? SizedBox(
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: mWhitecolor,
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14))),
                                onPressed: () {
                                  controller.buyPro();
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: Text(
                                    'Buy pro ${controller.price.value}',
                                    style: const TextStyle(
                                        color: mGreenColor,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                      ),
                    )
                  ],
                ),
                const SizedBox(
                  height: 18,
                ),
                PrivacyTermsRow(
                  showRestore: true,
                  onRestoreClick: () {},
                ),
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

  Widget _buildFeatureRow(String title) {
    return Padding(
      padding: const EdgeInsetsGeometry.only(
        left: 20,
      ),
      child: Row(
        children: [
          Image.asset(
            imgPro,
            height: 26,
            width: 26,
          ),
          const SizedBox(
            width: 12,
          ),
          Text(
            title,
            style: const TextStyle(
                color: mWhitecolor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
