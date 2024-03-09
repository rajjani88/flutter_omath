import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/gap.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/screens/home/widgets/game_ans_card.dart';
import 'package:flutter_omath/screens/home/widgets/game_que_card.dart';
import 'package:flutter_omath/screens/home/widgets/key_btn.dart';
import 'package:flutter_omath/screens/home/widgets/que_count_card%20copy.dart';
import 'package:flutter_omath/screens/home/widgets/score_card.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HomeGame extends StatefulWidget {
  const HomeGame({super.key});

  @override
  State<HomeGame> createState() => _HomeGameState();
}

class _HomeGameState extends State<HomeGame> {
  @override
  void initState() {
    super.initState();
    context.read<HomeGameController>().readData(context);
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
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GameQueCard(),
                        GameAnsCard(),
                        KeyBtn(),
                      ],
                    ),
                  ),
                  //end game widget
                ],
              ));
  }
}
