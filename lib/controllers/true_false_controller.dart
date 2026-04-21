import 'dart:async';
import 'dart:math';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class TrueFalseGameController extends GetxController {
  final level = 1.obs;
  final score = 0.obs;
  final lives = 3.obs;
  final extraLivesGained = 0.obs;
  final question = ''.obs;
  final isCorrectAnswer = true.obs;
  final isGameOver = false.obs;

  Timer? _freezeTimer;
  final _rng = Random();

  // Power-Up States
  RxBool isTimeFrozen = false.obs;
  RxBool showHint = false.obs;

  //user answere tap
  RxInt userAnswerTap = 0.obs;

  @override
  void onInit() {
    super.onInit();
    startGame();
  }

  void startGame() {
    Get.find<CurrencyController>().resetSession();
    level.value = 1;
    score.value = 0;
    lives.value = 3;
    extraLivesGained.value = 0;
    isGameOver.value = false;
    generateQuestion();
  }

  void generateQuestion() {
    int a, b;
    String op;
    int realResult;
    int displayedResult;

    // Difficulty scaling
    if (level.value <= 5) {
      // Easy: Addition
      a = _rng.nextInt(20) + 1;
      b = _rng.nextInt(20) + 1;
      op = '+';
      realResult = a + b;
    } else if (level.value <= 10) {
      // Medium: Subtraction
      a = _rng.nextInt(30) + 10;
      b = _rng.nextInt(a);
      op = '-';
      realResult = a - b;
    } else {
      // Hard: Multiplication
      a = _rng.nextInt(12) + 1;
      b = _rng.nextInt(10) + 1;
      op = '×';
      realResult = a * b;
    }

    // 50% chance to show correct, 50% to show fake
    if (_rng.nextBool()) {
      displayedResult = realResult;
    } else {
      do {
        int offset = _rng.nextInt(9) - 4;
        displayedResult = realResult + offset;
      } while (displayedResult == realResult);
    }

    question.value = "$a $op $b = $displayedResult";
    isCorrectAnswer.value = (displayedResult == realResult);
  }

  void onAnswer(bool userSaysTrue) {
    if (isGameOver.value) return;

    userAnswerTap.value++;

    if (userSaysTrue == isCorrectAnswer.value) {
      score.value += 10;
      level.value++;
      // Award coins
      Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
      Get.find<SoundController>().playSuccess();
      if (userAnswerTap.value % 2 == 0) {
        print("interstial ad show ${userAnswerTap.value}");

        Get.find<AdsController>().showInterstitialAd();
      }

      // Future Integrations
      _updateLeaderboard();
      _checkAchievements();
    } else {
      //when user play wrong
      if (userAnswerTap.value % 2 == 0) {
        print("interstial ad show ${userAnswerTap.value}");

        Get.find<AdsController>().showInterstitialAd();
      }
      Get.find<SoundController>().playWrong();
      lives.value--;
      if (lives.value <= 0) {
        isGameOver.value = true;
      }
    }

    if (!isGameOver.value) {
      generateQuestion();
    }
  }

  void solveLevel() {
    score.value += 10;
    level.value++;
    Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
    Get.find<SoundController>().playSuccess();
    Get.find<AdsController>().onLevelCompleted();
    generateQuestion();
  }

  void addExtraLife() {
    if (extraLivesGained.value < 2) {
      lives.value++;
      extraLivesGained.value++;
      Fluttertoast.showToast(
          msg: "Extra Life Added! (${extraLivesGained.value}/2)");
    }
  }

  // ===== POWER-UP METHODS =====

  /// Hint: Flash the correct answer button
  void useHint() {
    showHint.value = true;
    Future.delayed(const Duration(seconds: 1), () {
      showHint.value = false;
    });
  }

  /// Freeze Time: Pause timer for 10 seconds
  void freezeTime() {
    if (isTimeFrozen.value) return;

    isTimeFrozen.value = true;
    Get.snackbar("❄️ Time Frozen!", "10 seconds of peace...",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));

    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(seconds: kFreezeDuration), () {
      isTimeFrozen.value = false;
      Get.snackbar("⏱️ Time Resumed!", "Back to action!",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
    });
  }

  /// Skip: Auto-win current round
  void skipLevel() {
    score.value += 10;
    level.value++;
    generateQuestion();
    Get.snackbar("⏭️ Skipped!", "Moving to Level ${level.value}",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
  }

  @override
  void onClose() {
    _freezeTimer?.cancel();
    super.onClose();
  }

  // ===== FUTURE INTEGRATION HOOKS =====

  /// Update XP on Supabase leaderboard
  void _updateLeaderboard() {
    try {
      Get.find<UserController>().addXp(SupabaseConfig.xpPerCorrectAnswer);
    } catch (e) {
      // UserController not initialized yet
    }
  }

  /// Trigger achievement checks
  void _checkAchievements() {
    try {
      final ac = Get.find<AchievementController>();
      ac.checkEvents('correct_answer', null);
      ac.checkEvents('game_played', null);
      ac.checkEvents('coins_earned', null);
    } catch (e) {
      // AchievementController not initialized yet
    }
  }
}
