import 'package:flutter/material.dart';
import 'package:flutter_omath/screens/math_grid/math_grid_find_number_screen.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:get/get.dart';

class MathGridRulesScreen extends StatefulWidget {
  const MathGridRulesScreen({super.key});

  @override
  State<MathGridRulesScreen> createState() => _MathGridRulesScreenState();
}

class _MathGridRulesScreenState extends State<MathGridRulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mAppBlue,
      body: Column(
        children: [
          const SizedBox(
            height: 56,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                Hero(
                  tag: 'logo',
                  child: Image.asset(
                    imgMathgrid,
                    height: 56,
                    width: 56,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                const Text(
                  'Math Grid 3x3',
                  style: TextStyle(
                      color: mWhitecolor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(14),
            child: Divider(
              color: mWhitecolor,
            ),
          ),
          const Text(
            'Game Concept',
            style: TextStyle(
                color: mWhitecolor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 12,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Solve as many mini math equations as possible in a 3x3 grid.\n\nEach grid will contain simple equations like:\n  - 7 + 3 = ?\n  - 12 - 5 = ?\n  - 4 × 2 = ?\n\nTap the correct answer from multiple options.\nYou have 30 seconds to solve as many as you can!',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      color: mWhitecolor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14))),
                      onPressed: () {
                        Get.back();
                        Get.to(() => MathGridFindNumber());
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
          ),
          const SizedBox(
            height: 24,
          ),
        ],
      ),
    );
  }
}
