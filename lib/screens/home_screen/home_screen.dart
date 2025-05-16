import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/privacy_terms_row.dart';
import 'package:flutter_omath/screens/arrange_numbers/arrange_number.dart';
import 'package:flutter_omath/screens/home_screen/widgets/build_game_option.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                  height: 100,
                  width: 100,
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
            title: 'Arrange Number',
            subTitle: 'Arrange Number in order within the given time.',
            onTap: () {
              Get.to(() => ArrangeNumber());
            },
            imgName: imgNumber,
          ),
          const SizedBox(
            height: 14,
          ),
          BuildGameOption(
              title: 'Calculate ',
              subTitle: 'Solve basic calculation problems.',
              onTap: () {},
              imgName: imgcalculator),
          Spacer(),
          PrivacyTermsRow(),
          SizedBox(
            height: 18,
          ),
        ],
      ),
    );
  }
}
