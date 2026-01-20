import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/controllers/arrange_number_contoller.dart';
import 'package:flutter_omath/controllers/calculate_numbers_contoller.dart';
import 'package:flutter_omath/controllers/inpurchase_controller.dart';
import 'package:flutter_omath/controllers/leaderboard_controller.dart';
import 'package:flutter_omath/controllers/math_grid_puzzle_controller.dart';
import 'package:flutter_omath/controllers/math_maze_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> init() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  // Core Utils
  Get.lazyPut(() => Sharedprefs(prefs: sharedPreferences), fenix: true);

  // Game Controllers
  Get.lazyPut(() => ArrangeNumberController(), fenix: true);
  Get.lazyPut(() => CalculateNumbersController(), fenix: true);
  Get.lazyPut(() => MathGridPuzzleController(), fenix: true);
  Get.lazyPut(() => MathMazeController(), fenix: true);

  // Core App Controllers
  Get.lazyPut(() => AdsController(sp: Get.find()), fenix: true);
  Get.lazyPut(() => InAppPurchaseController(sp: Get.find()), fenix: true);
  Get.lazyPut(() => SoundController(), fenix: true);
  Get.lazyPut(() => CurrencyController(), fenix: true);
  Get.lazyPut(() => DailyChallengeController(prefs: sharedPreferences),
      fenix: true);

  // Social/Leaderboard Controllers
  Get.lazyPut(() => UserController(), fenix: true);
  Get.lazyPut(() => AchievementController(prefs: sharedPreferences),
      fenix: true);
  Get.lazyPut(() => LeaderboardController(), fenix: true);
}
