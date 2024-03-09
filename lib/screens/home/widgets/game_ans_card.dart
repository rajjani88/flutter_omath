import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class GameAnsCard extends StatelessWidget {
  const GameAnsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: const BoxDecoration(color: mLighthWhiteColor),
            child: Consumer<HomeGameController>(
                builder: (context, provider, child) {
              return MyText(
                text: provider.ansText,
                textSize: 60,
                isBold: true,
              );
            }),
          ),
        ),
      ],
    );
  }
}
