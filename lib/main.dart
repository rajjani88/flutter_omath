import 'package:flutter/material.dart';
import 'package:flutter_omath/screens/splash/splash.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'utils/get_di.dart' as getit;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  getit.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brainy Math',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
