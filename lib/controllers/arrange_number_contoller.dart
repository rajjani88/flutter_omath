import 'dart:async';
import 'dart:math';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';

import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class ArrangeNumberController extends GetxController implements GetxService {
  final level = 1.obs;
  final lives = 3.obs;
  final extraLivesGained = 0.obs;
  final userAnswerTap = 0.obs;
  final score = 0.obs;
  final questionNumbers = <int>[].obs;
  final userSelection = <int>[].obs;
  final isDescending = false.obs;
  final isGameOver = false.obs;

  Timer? _freezeTimer;
  final _rng = Random();

  // Power-Up States
  RxBool isTimeFrozen = false.obs;
  RxInt hintIndex = (-1).obs;
  List<int> _correctOrder = [];

  void startGame() {
    Get.find<CurrencyController>().resetSession();
    level.value = 1;
    lives.value = 3;
    extraLivesGained.value = 0;
    userAnswerTap.value = 0;
    score.value = 0;
    isGameOver.value = false;
    generateNewRound();
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
    userAnswerTap.value++;

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
      Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
      Get.find<SoundController>().playSuccess();

      if (userAnswerTap.value % 2 == 0) {
        Get.find<AdsController>().showInterstitialAd();
      }

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

      if (userAnswerTap.value % 2 == 0) {
        Get.find<AdsController>().showInterstitialAd();
      }

      lives.value--;
      if (lives.value <= 0) {
        isGameOver.value = true;
      }

      if (!isGameOver.value) {
        Get.snackbar("❌ Wrong Order!", "Try again! Lives: ${lives.value}",
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 1));
      }
    }
  }

  void solveLevel() {
    score.value += 10 * level.value;
    level.value++;
    Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
    Get.find<SoundController>().playSuccess();
    Get.find<AdsController>().showInterstitialAd();
    generateNewRound();
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
