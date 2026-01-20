import 'package:flutter/material.dart';
import 'package:flutter_omath/utils/game_colors.dart';

class GameBackground extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  const GameBackground({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GameColors.bgBottom,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameColors.bgTop,
              GameColors.bgBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: child,
        ),
      ),
    );
  }
}
