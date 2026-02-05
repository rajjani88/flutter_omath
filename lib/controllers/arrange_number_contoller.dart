import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';

import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:get/get.dart';

class ArrangeNumberController extends GetxController implements GetxService {
  final level = 1.obs;
  final timer = 30.obs;
  final score = 0.obs;
  final questionNumbers = <int>[].obs;
  final userSelection = <int>[].obs;
  final isDescending = false.obs;
  final isGameOver = false.obs;

  Timer? _gameTimer;
  Timer? _freezeTimer;
  final _rng = Random();

  // Power-Up States
  RxBool isTimeFrozen = false.obs;
  RxInt hintIndex = (-1).obs;
  List<int> _correctOrder = [];

  void startGame() {
    level.value = 1;
    timer.value = 30;
    score.value = 0;
    isGameOver.value = false;
    generateNewRound();
    startTimer();
  }

  void startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (isTimeFrozen.value) return;

      if (timer.value == 0) {
        t.cancel();
        onTimeOut();
      } else {
        timer.value--;
      }
    });
  }

  void generateNewRound() {
    userSelection.clear();
    hintIndex.value = -1;

    int count = min(9, 4 + (level.value ~/ 2));
    isDescending.value = _rng.nextBool();

    Set<int> numSet = {};

    // Clustered Numbers for difficulty
    if (level.value >= 3) {
      int base = _rng.nextInt(40) + 10;
      while (numSet.length < count) {
        int offset = _rng.nextInt(10) - 2;
        int num = base + offset;
        if (num > 0 && num < 100) numSet.add(num);
      }
    } else {
      while (numSet.length < count) {
        numSet.add(_rng.nextInt(50) + 1);
      }
    }

    questionNumbers.value = numSet.toList()..shuffle();
    _correctOrder = List.from(numSet.toList());
    _correctOrder.sort();
    if (isDescending.value) {
      _correctOrder = _correctOrder.reversed.toList();
    }

    int timeForLevel = 15 + (count * 3);
    timer.value = timeForLevel;
  }

  void selectNumber(int num) {
    if (userSelection.contains(num)) return;
    userSelection.add(num);
    hintIndex.value = -1;

    if (userSelection.length == questionNumbers.length) {
      checkAnswer();
    }
  }

  void removeNumber(int num) {
    userSelection.remove(num);
  }

  void checkAnswer() {
    List<int> expected = List.from(questionNumbers);
    expected.sort();
    if (isDescending.value) {
      expected = expected.reversed.toList();
    }

    bool isCorrect = true;
    for (int i = 0; i < expected.length; i++) {
      if (userSelection[i] != expected[i]) {
        isCorrect = false;
        break;
      }
    }

    if (isCorrect) {
      score.value += 10 * level.value;
      // Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
      Get.find<SoundController>().playSuccess();

      _updateLeaderboard();
      _checkAchievements();

      level.value++;
      generateNewRound();

      Get.snackbar("✅ Correct!", "Level ${level.value}",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
    } else {
      userSelection.clear();
      Get.find<SoundController>().playWrong();
      Get.snackbar("❌ Wrong Order!", "Try again!",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
    }
  }

  // ===== POWER-UP METHODS =====

  /// Smart Hint: Auto-place the next correct number
  void useHint() {
    final currentPos = userSelection.length;
    if (currentPos >= _correctOrder.length) return;

    final nextCorrectNum = _correctOrder[currentPos];

    // Auto-place it
    if (!userSelection.contains(nextCorrectNum)) {
      userSelection.add(nextCorrectNum);

      // Highlight it briefly
      hintIndex.value = nextCorrectNum;
      Future.delayed(const Duration(milliseconds: 500), () {
        hintIndex.value = -1;
      });

      // Check if complete
      if (userSelection.length == questionNumbers.length) {
        checkAnswer();
      }
    }
  }

  void onTimeOut() {
    if (isClosed) return;
    isGameOver.value = true;
    Get.find<SoundController>().playWrong();
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
    generateNewRound();
    Get.snackbar("⏭️ Skipped!", "Moving to Level ${level.value}",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
  }

  void disposeGame() {
    _gameTimer?.cancel();
    _freezeTimer?.cancel();
  }

  @override
  void onClose() {
    disposeGame();
    super.onClose();
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
