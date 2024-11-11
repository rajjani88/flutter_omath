import 'package:flutter/material.dart';
import 'package:flutter_omath/screens/dashboard/game_menu.dart';
import 'package:flutter_omath/screens/fruitpuzzle/fruit_puzzle.dart';
import 'package:flutter_omath/screens/home/home_game.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.

const String routeSplashScreen = '/';
const String routeMenu = "/game_menu";
const String routeGameHome = "/game_home";
const String routeFruitGame = "/fruit_game";

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: routeSplashScreen,
      builder: (BuildContext context, GoRouterState state) {
        return const GameMenu();
      },
    ),

    //game menu
    GoRoute(
      path: routeMenu,
      builder: (BuildContext context, GoRouterState state) {
        return const GameMenu();
      },
    ),

    // home game
    GoRoute(
      path: routeGameHome,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeGame();
      },
    ),

    // fruit game
    GoRoute(
      path: routeFruitGame,
      builder: (BuildContext context, GoRouterState state) {
        return const FruitPuzzleGame();
      },
    ),
  ],
);

void popUntilPath(BuildContext context, String routePath) {
  while (
      router.routerDelegate.currentConfiguration.matches.last.matchedLocation !=
          routePath) {
    if (!context.canPop()) {
      return;
    }
    context.pop();
  }
}
