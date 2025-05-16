import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';

class BuildGameOption extends StatelessWidget {
  const BuildGameOption({
    super.key,
    required this.title,
    required this.subTitle,
    required this.onTap,
    required this.imgName,
  });

  final String title;
  final String subTitle;
  final void Function() onTap;
  final String imgName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: InkWell(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Image.asset(
                  imgName,
                  height: 80,
                  width: 80,
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            color: mAppBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.w800),
                      ),
                      Text(
                        subTitle,
                        style: const TextStyle(
                            color: mAppBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
