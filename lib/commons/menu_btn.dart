import 'package:animated_button/animated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';

class MenuBtn extends StatelessWidget {
  final String lblText;
  final Function() onClick;

  const MenuBtn({super.key, required this.lblText, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return AnimatedButton(
      height: 48,
      onPressed: onClick,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MyText(
            text: lblText,
            textSize: 20,
          )
        ],
      ),
    );
  }
}
