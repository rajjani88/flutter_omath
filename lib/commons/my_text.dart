import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

//Title = 20 / 22
// normal text 16
// medium  = 18
//extra small = 14
class MyText extends StatelessWidget {
  final String text;
  final Color textColor;
  final double textSize;
  final bool isBold;
  const MyText(
      {super.key,
      required this.text,
      this.textColor = mWhitecolor,
      this.textSize = 16,
      this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.robotoSlab().copyWith(
          color: textColor,
          fontSize: textSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
    );
  }
}
