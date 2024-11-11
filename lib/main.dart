import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/fruit_game_controller.dart';
import 'package:flutter_omath/controllers/game_menu_controller.dart';
import 'package:flutter_omath/controllers/home_game_contoller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/navigation_router.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameMenuController()),
        ChangeNotifierProvider(create: (_) => HomeGameController()),
        ChangeNotifierProvider(create: (_) => FruitGameController()),
      ],
      child: Builder(
        builder: (context) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: appName,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
