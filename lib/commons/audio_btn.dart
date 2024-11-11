import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/gap.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/controllers/game_menu_controller.dart';
import 'package:provider/provider.dart';

class AudioBtn extends StatelessWidget {
  final String lblText;
  final Function() onClick;

  const AudioBtn({super.key, required this.lblText, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameMenuController>(builder: (context, provider, child) {
      return AnimatedButton(
        height: 48,
        onPressed: onClick,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MyText(text: "Music : "),
            gapHorizontal(w: 14),
            MyText(
              text: provider.isMusicOn ? 'ON' : 'OFF',
              textSize: 20,
              textColor:
                  provider.isMusicOn ? Colors.orangeAccent : Colors.black,
            )
          ],
        ),
      );
    });
  }
}
