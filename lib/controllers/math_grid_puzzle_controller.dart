import 'dart:async';
import 'dart:math';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';

import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:flutter_omath/widgets/daily_challenge_success_popup.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class MathGridPuzzleController extends GetxController {
  final level = 1.obs;
  final question = ''.obs;
  final answerOptions = <int>[].obs;
  final lives = 3.obs;
  final extraLivesGained = 0.obs;
  final isGameOver = false.obs;

  // Daily Challenge
  bool isDailyChallenge = false;
  int? dailySeed;
  static const int dailyChallengeTargetLevel = 6; // Complete 5 levels

  var _random = Random();
  late int _correctAnswer;

  // Power-Up States
  RxBool isTimeFrozen = false.obs;
  RxInt highlightedAnswer = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    startGame();
  }

  void startGame() {
    Get.find<CurrencyController>().resetSession();
    if (dailySeed != null) {
      _random = Random(dailySeed!);
    }
    level.value = 1;
    lives.value = 3;
    extraLivesGained.value = 0;
    isGameOver.value = false;
    _generateNewQuestion();
  }

  void _generateNewQuestion() {
    highlightedAnswer.value = -1;

    int a, b;
    String op;
    int scaleFactor = min(5, (level.value / 3).floor() + 1);

    int opType = _random.nextInt(3);
    switch (opType) {
      case 0:
        a = _random.nextInt(10 * scaleFactor) + 1;
        b = _random.nextInt(10 * scaleFactor) + 1;
        op = '+';
        _correctAnswer = a + b;
        break;
      case 1:
        a = _random.nextInt(15 * scaleFactor) + 10;
        b = _random.nextInt(a);
        op = '-';
        _correctAnswer = a - b;
        break;
      default:
        a = _random.nextInt(8) + 2;
        b = _random.nextInt(8) + 2;
        op = '×';
        _correctAnswer = a * b;
    }

    question.value = "$a $op $b = ?";

    // Smart Fake Answers
    Set<int> options = {_correctAnswer};
    List<int> offsets = [-10, -2, -1, 1, 2, 10];
    for (var offset in offsets) {
      int fakeAnswer = _correctAnswer + offset;
      if (fakeAnswer > 0 && fakeAnswer != _correctAnswer) {
        options.add(fakeAnswer);
      }
      if (options.length >= 9) break;
    }

    while (options.length < 9) {
      int wrong = _correctAnswer + _random.nextInt(20) - 10;
      if (wrong > 0 && wrong != _correctAnswer) {
        options.add(wrong);
      }
    }
    answerOptions.value = options.toList()..shuffle();
  }

  void onAnswerSelected(int selected) {
    if (selected == _correctAnswer) {
      level.value++;
      Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
      Get.find<SoundController>().playSuccess();
      Get.find<AdsController>().onLevelCompleted();

      _updateLeaderboard();
      _checkAchievements();

      if (isDailyChallenge && level.value >= dailyChallengeTargetLevel) {
        final dc = Get.find<DailyChallengeController>();
        dc.completeChallenge();
        Get.dialog(
          DailyChallengeSuccessPopup(
            streak: dc.currentStreak.value,
            onContinue: () => Get.offAll(() => const HomeScreen()),
          ),
          barrierDismissible: false,
        );
        return;
      }

      _generateNewQuestion();
    } else {
      lives.value--;
      Get.find<SoundController>().playWrong();

      if (lives.value <= 0) {
        isGameOver.value = true;
      } else {
        Fluttertoast.showToast(msg: "Wrong! ${lives.value} lives left");
        _generateNewQuestion();
      }
    }
  }

  void solveLevel() {
    level.value++;
    Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
    Get.find<SoundController>().playSuccess();
    _generateNewQuestion();
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

  void useHint() {
    highlightedAnswer.value = _correctAnswer;
    Future.delayed(const Duration(seconds: 1), () {
      highlightedAnswer.value = -1;
    });
  }

  void freezeTime() {
    if (isTimeFrozen.value) return;

    isTimeFrozen.value = true;
    Get.snackbar("❄️ Time Frozen!", "10 seconds of peace...",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 2));
  }

  void skipLevel() {
    level.value++;
    _generateNewQuestion();
    Get.snackbar("⏭️ Skipped!", "Moving to Level ${level.value}",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
  }

  // ===== FUTURE INTEGRATION HOOKS =====

  void _updateLeaderboard() {
    try {
      Get.find<UserController>().addXp(SupabaseConfig.xpPerCorrectAnswer);
    } catch (e) {
      // Not initialized
    }
  }

  void _checkAchievements() {
    try {
      final ac = Get.find<AchievementController>();
      ac.checkEvents('correct_answer', null);
      ac.checkEvents('game_played', null);
      ac.checkEvents('coins_earned', null);
    } catch (e) {
      // Not initialized
    }
  }
}
