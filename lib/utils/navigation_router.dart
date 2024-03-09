import 'package:flutter/material.dart';
import 'package:flutter_omath/screens/home/home_game.dart';
import 'package:go_router/go_router.dart';

/// The route configuration.

const String routeSplashScreen = '/';
const String routeGameHome = "/game_home";

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: routeSplashScreen,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeGame();
      },
    ),

    //profile details
    GoRoute(
      path: routeGameHome,
      builder: (BuildContext context, GoRouterState state) {
        return const HomeGame();
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
