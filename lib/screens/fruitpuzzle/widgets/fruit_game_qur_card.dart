import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/controllers/fruit_game_controller.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:provider/provider.dart';

class FruitGameQueCard extends StatelessWidget {
  FruitGameQueCard({super.key});

  final List<Widget> _images = List.generate(
      10,
      (index) => SizedBox(
          height: 25,
          width: 25,
          child: Image.asset(
            'assets/images/apple.png',
            fit: BoxFit.cover,
          )));

  @override
  Widget build(BuildContext context) {
    return Consumer<FruitGameController>(builder: (context, provider, child) {
      return Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyText(
                text: 'How many fruit ?',
                textSize: 14,
                isBold: true,
                textColor: mGreenColor,
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              itemCount: _images.length,
              shrinkWrap: true,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
              itemBuilder: (context, index) => _images[index],
            ),
          ),
        ],
      );
    });
  }
}
