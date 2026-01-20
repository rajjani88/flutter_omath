import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:flutter_omath/widgets/daily_challenge_success_popup.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:get/get.dart';

enum OperationMode { auto, add, subtract, multiply, divide }

class CalculateNumbersController extends GetxController implements GetxService {
  final level = 1.obs;
  final timer = 30.obs;
  final question = ''.obs;
  final userAnswer = ''.obs;
  final correctAnswer = 0.obs;
  final mode = OperationMode.auto.obs;

  // Daily Challenge properties
  bool isDailyChallenge = false;
  Random? _rng;
  // Win condition for daily challenge (e.g., Reach Level 10)
  // TEMPORARY: Set to 1 for testing
  static const int dailyChallengeTargetLevel = 1;

  Timer? _gameTimer;

  final RxBool isGameOver = false.obs;

  // Power-Up States
  final RxBool isTimeFrozen = false.obs;
  Timer? _freezeTimer;

  void startGame(OperationMode selectedMode,
      {int? seed, bool isDaily = false}) {
    isDailyChallenge = isDaily;
    if (seed != null) {
      _rng = Random(seed);
    } else {
      _rng = Random();
    }

    level.value = 1;
    mode.value = selectedMode;

    startTimer();
    generateQuestion();
  }

  void startTimer() {
    isGameOver.value = false;
    _startTimerForLevel();
  }

  void _startTimerForLevel() {
    _gameTimer?.cancel();
    // Adaptive Timer: Higher level = Less time
    int timeForLevel = max(10, 30 - level.value);
    timer.value = timeForLevel;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      // Don't decrement if frozen
      if (isTimeFrozen.value) return;

      if (timer.value > 0) {
        timer.value--;
      } else {
        t.cancel();
        isGameOver.value = true;
        Get.find<SoundController>().playWrong();
      }
    });
  }

  void generateQuestion() {
    int lvl = level.value;
    int maxVal =
        min(100, (lvl * 8) + 5); // Scale numbers with level, cap at 100
    int a = _rng!.nextInt(maxVal) + 2;
    int b = _rng!.nextInt(maxVal) + 2;

    OperationMode currentMode = mode.value;
    if (currentMode == OperationMode.auto) {
      // Difficulty Flow
      if (lvl <= 4)
        currentMode = OperationMode.add;
      else if (lvl <= 8)
        currentMode = OperationMode.subtract;
      else if (lvl <= 12)
        currentMode = OperationMode.multiply;
      else {
        int r = _rng!.nextInt(100);
        if (r < 40)
          currentMode = OperationMode.add;
        else if (r < 70)
          currentMode = OperationMode.subtract;
        else
          currentMode =
              OperationMode.multiply; // Division is hard on phone keypad
      }
    }

    switch (currentMode) {
      case OperationMode.add:
        question.value = "$a + $b = ?";
        correctAnswer.value = a + b;
        break;
      case OperationMode.subtract:
        // Ensure positive result for simplicity initially
        if (a < b) {
          int t = a;
          a = b;
          b = t;
        }
        question.value = "$a - $b = ?";
        correctAnswer.value = a - b;
        break;
      case OperationMode.multiply:
        // Keep numbers smaller for multiply
        a = _rng!.nextInt(12) + 2;
        b = _rng!.nextInt(10) + 2;
        question.value = "$a × $b = ?";
        correctAnswer.value = a * b;
        break;
      case OperationMode.divide:
        correctAnswer.value = _rng!.nextInt(10) + 2;
        b = _rng!.nextInt(10) + 2;
        a = b * correctAnswer.value;
        question.value = "$a ÷ $b = ?";
        break;
      default:
        break;
    }
    userAnswer.value = '';
  }

  void addInput(String value) {
    userAnswer.value += value;
  }

  void resetInput() {
    userAnswer.value = '';
  }

  void submitAnswer() {
    if (userAnswer.value == correctAnswer.value.toString()) {
      level.value++;

      // Daily Challenge Win Condition
      if (isDailyChallenge && level.value > dailyChallengeTargetLevel) {
        Get.find<DailyChallengeController>().completeChallenge();

        if (isClosed) return;
        Get.dialog(
          GetBuilder<DailyChallengeController>(builder: (dc) {
            return DailyChallengeSuccessPopup(
              streak: dc.currentStreak.value,
              onContinue: () {
                Get.offAll(() => const HomeScreen());
              },
            );
          }),
          barrierDismissible: false,
        );
        return;
      }

      // Award coins for correct answer
      Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
      Get.find<SoundController>().playSuccess();

      // Future Integrations
      _updateLeaderboard();
      _checkAchievements();

      _startTimerForLevel(); // Reset timer for new level
      generateQuestion();
    } else {
      Get.find<SoundController>().playWrong();
      Get.snackbar("Wrong Answer", "Try again!");
    }
    resetInput();
  }

  void resetGame() {
    _gameTimer?.cancel();
    timer.value = 0;
    level.value = 1;
    userAnswer.value = '';
    question.value = '';
    correctAnswer.value = 0;
  }

  // ===== POWER-UP METHODS =====

  /// Freeze Time Power-Up: Pauses timer for 10 seconds
  void freezeTime() {
    if (isTimeFrozen.value) return; // Already frozen

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

  /// Skip Level Power-Up: Auto-advance to next question
  void skipLevel() {
    level.value++;
    _startTimerForLevel();
    generateQuestion();
    Get.snackbar("⏭️ Skipped!", "Moving to Level ${level.value}",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
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
