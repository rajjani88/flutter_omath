import 'package:flutter/material.dart';
import 'package:flutter_omath/commons/audio_btn.dart';
import 'package:flutter_omath/commons/gap.dart';
import 'package:flutter_omath/commons/menu_btn.dart';
import 'package:flutter_omath/controllers/game_menu_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/navigation_router.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class GameMenu extends StatefulWidget {
  const GameMenu({super.key});

  @override
  State<GameMenu> createState() => _GameMenuState();
}

class _GameMenuState extends State<GameMenu> {
  bool musicStatus = true;

  @override
  void initState() {
    super.initState();
    context.read<GameMenuController>().setupMusic();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //icons btn
  Widget menuIconBtn(IconData icon, Function() action) {
    return GestureDetector(
      onTap: action,
      child: Container(
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        child: Icon(
          icon,
          color: Colors.orangeAccent,
          size: 30,
        ),
      ),
    );
  }

  //for openning url
  Future<void> lunchLinkForReview() async {
    if (!await launchUrl(
      Uri.parse(""),
    )) {
      throw 'Could not launch';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: Image.asset(imgBg).image, fit: BoxFit.cover),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: (Image.asset(imgLogo,
                            height: 160, width: 160, fit: BoxFit.fill)),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MenuBtn(
                    lblText: 'Play Easy Math',
                    onClick: () {
                      context.push(routeGameHome);
                    },
                  ),
                  gapVertical(h: 20),
                  MenuBtn(
                    lblText: 'Fruit Puzzle',
                    onClick: () {
                      context.push(routeFruitGame);
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MenuBtn(
                    lblText: 'About Game',
                    onClick: () {},
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  MenuBtn(lblText: "More Apps", onClick: () {}),
                  const SizedBox(
                    height: 20,
                  ),
                  AudioBtn(
                    lblText: 'Music',
                    onClick: () {
                      context.read<GameMenuController>().updateMusicStatus();
                    },
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 46,
                        width: 46,
                        child: menuIconBtn(
                            Icons.share,
                            () => Share.share(
                                'Let me Recommend Awesome Word Puzzle Game')),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      SizedBox(
                        height: 46,
                        width: 46,
                        child: menuIconBtn(Icons.rate_review, () {
                          lunchLinkForReview();
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'By Playing this Game your are agree to our ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // print('privacy policy');
                          },
                          child: const Text('Privacy Policy',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Text(
                          ' & ',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // launchUrl(Uri.parse(AppStrings.terms));
                          },
                          child: const Text('Terms and Conditions',
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
