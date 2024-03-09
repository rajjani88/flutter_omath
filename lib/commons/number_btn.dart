import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/my_text.dart';
import 'package:flutter_omath/utils/app_colors.dart';

class NumberBtn extends StatelessWidget {
  final String lblText;
  final Function()? onClick;
  const NumberBtn({super.key, required this.lblText, required this.onClick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      width: 66,
      child: ElevatedButton(
        onPressed: onClick,
        child: MyText(
          text: lblText,
          textColor: mBlackColor,
          textSize: 34,
        ),
      ),
    );
  }
}
