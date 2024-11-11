import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Consumer<HomeGameController>(builder: (context, provider, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const MyText(
                  text: 'Score',
                  textColor: mLisghWhiteColor,
                ),
                MyText(
                  text: '${provider.score}',
                  textSize: 20,
                )
              ],
            );
          }),
        ],
      ),
    );
  }
}
