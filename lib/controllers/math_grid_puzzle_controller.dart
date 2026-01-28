import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';

import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class MathGridPuzzleController extends GetxController {
  final level = 1.obs;
  final question = ''.obs;
  final answerOptions = <int>[].obs;
  final timeLeft = 30.obs;
  final isGameOver = false.obs;

  final _random = Random();
  late int _correctAnswer;
  late Timer _timer;
  Timer? _freezeTimer;

  // Power-Up States
  RxBool isTimeFrozen = false.obs;
  RxInt highlightedAnswer = (-1).obs;

  @override
  void onInit() {
    super.onInit();
    startGame();
  }

  void startGame() {
    level.value = 1;
    timeLeft.value = 30;
    isGameOver.value = false;
    _generateNewQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      // Don't decrement if frozen
      if (isTimeFrozen.value) return;

      if (timeLeft.value == 0) {
        t.cancel();
        isGameOver.value = true;
        Get.find<SoundController>().playWrong();
      } else {
        timeLeft.value--;
      }
    });
  }

  @override
  void onClose() {
    _timer.cancel();
    _freezeTimer?.cancel();
    super.onClose();
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
      int newTime = max(10, 30 - level.value);
      timeLeft.value = newTime;

      _updateLeaderboard();
      _checkAchievements();
    } else {
      timeLeft.value = max(0, timeLeft.value - 5);
      Get.find<SoundController>().playWrong();
      Fluttertoast.showToast(msg: "Wrong! -5s");
    }

    if (timeLeft.value > 0) {
      _generateNewQuestion();
    } else {
      _timer.cancel();
      isGameOver.value = true;
      Get.find<SoundController>().playWrong();
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

    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(seconds: kFreezeDuration), () {
      isTimeFrozen.value = false;
      Get.snackbar("⏱️ Time Resumed!", "Back to action!",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
    });
  }

  void skipLevel() {
    level.value++;
    int newTime = max(10, 30 - level.value);
    timeLeft.value = newTime;
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
