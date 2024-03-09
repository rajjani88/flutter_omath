import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class GameQueCard extends StatelessWidget {
  const GameQueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeGameController>(builder: (context, provider, child) {
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: provider.successMsg,
                textSize: 14,
                isBold: true,
                textColor: mGreenColor,
              )
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Flexible(
                flex: 1,
                child: MyText(
                  text: provider.currentQue == null
                      ? ""
                      : provider.currentQue!.que,
                  textSize: 56,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
