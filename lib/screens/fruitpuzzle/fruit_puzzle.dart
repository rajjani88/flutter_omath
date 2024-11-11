import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/gap.dart';
import 'package:flutter_omath/controllers/fruit_game_controller.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/screens/fruitpuzzle/widgets/fruit_game_qur_card.dart';
import 'package:flutter_omath/screens/fruitpuzzle/widgets/que_count_card.dart';
import 'package:flutter_omath/screens/fruitpuzzle/widgets/score_card.dart';
import 'package:flutter_omath/screens/home/widgets/key_btn.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class FruitPuzzleGame extends StatefulWidget {
  const FruitPuzzleGame({super.key});

  @override
  State<FruitPuzzleGame> createState() => _FruitPuzzleGameState();
}

class _FruitPuzzleGameState extends State<FruitPuzzleGame> {
  @override
  void initState() {
    super.initState();
    context.read<FruitGameController>().buildQueList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: context.watch<HomeGameController>().loading
            ? const Column(
                children: [
                  CircularProgressIndicator(
                    backgroundColor: mWhitecolor,
                  )
                ],
              )
            : Column(
                children: [
                  gapVertical(h: 24),
                  const ScoreCard(),
                  gapVertical(),
                  const QueCountCard(),
                  //game widet
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FruitGameQueCard(),
                      ],
                    ),
                  ),
                  //end game widget
                ],
              ));
  }
}
