import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyTermsRow extends StatelessWidget {
  final bool showRestore;
  final Function()? onRestoreClick;
  const PrivacyTermsRow(
      {super.key, this.showRestore = false, this.onRestoreClick});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url), mode: LaunchMode.inAppWebView)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            _launchUrl(urlPrivacy);
          },
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
                color: mLisghWhiteColor,
                fontSize: 14,
                fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        Visibility(
          visible: showRestore,
          child: TextButton(
            onPressed: onRestoreClick,
            child: const Text(
              'Restore',
              style: TextStyle(
                  color: mLisghWhiteColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            _launchUrl(urlTerms);
          },
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
