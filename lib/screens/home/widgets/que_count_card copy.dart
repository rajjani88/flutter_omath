import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:provider/provider.dart';

class QueCountCard extends StatelessWidget {
  const QueCountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Consumer<HomeGameController>(builder: (context, provider, child) {
                return MyText(
                  text: 'Level : ${provider.level + 1}',
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
