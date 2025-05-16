import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/app_colors.dart';

class PrivacyTermsRow extends StatelessWidget {
  const PrivacyTermsRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {},
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
                color: mLisghWhiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {},
          child: const Text(
            'Terms of Use',
            style: TextStyle(
                color: mLisghWhiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        )
      ],
    );
  }
}
