import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/math_grid_puzzle_controller.dart';
import 'package:flutter_omath/controllers/math_maze_controller.dart';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> init() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  Get.lazyPut(
    () => Sharedprefs(prefs: sharedPreferences),
  );
  Get.lazyPut(
    () => ArrangeNumberController(),
  );

  Get.lazyPut(
    () => CalculateNumbersController(),
  );

  Get.lazyPut(
    () => MathGridPuzzleController(),
  );

  Get.lazyPut(
    () => MathMazeController(),
  );

  Get.lazyPut(() => AdsController());

  Get.lazyPut(() => InAppPurchaseController(sp: Get.find()));
}
