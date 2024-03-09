import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/gap.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/commons/number_btn.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class KeyBtn extends StatelessWidget {
  const KeyBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeGameController>(builder: (context, provider, child) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NumberBtn(
                lblText: "1",
                onClick: () {
                  provider.addDigitToAns("1");
                },
              ),
              NumberBtn(
                lblText: "2",
                onClick: () {
                  provider.addDigitToAns("2");
                },
              ),
              NumberBtn(
                lblText: "3",
                onClick: () {
                  provider.addDigitToAns("3");
                },
              )
            ],
          ),
          gapVertical(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NumberBtn(
                lblText: "4",
                onClick: () {
                  provider.addDigitToAns("4");
                },
              ),
              NumberBtn(
                lblText: "5",
                onClick: () {
                  provider.addDigitToAns("5");
                },
              ),
              NumberBtn(
                lblText: "6",
                onClick: () {
                  provider.addDigitToAns("6");
                },
              )
            ],
          ),
          gapVertical(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NumberBtn(
                lblText: "7",
                onClick: () {
                  provider.addDigitToAns("7");
                },
              ),
              NumberBtn(
                lblText: "8",
                onClick: () {
                  provider.addDigitToAns("8");
                },
              ),
              NumberBtn(
                lblText: "9",
                onClick: () {
                  provider.addDigitToAns("9");
                },
              )
            ],
          ),
          gapVertical(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              NumberBtn(
                lblText: "0",
                onClick: () {
                  provider.addDigitToAns("0");
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {
                  provider.resetAns();
                },
                child: const MyText(
                  text: "Reset",
                  textColor: mBlackColor,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  provider.removeFromAns();
                },
                child: const MyText(
                  text: "Clear",
                  textColor: mBlackColor,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
