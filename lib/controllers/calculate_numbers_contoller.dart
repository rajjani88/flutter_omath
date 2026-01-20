import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
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

  final RxBool isGamOver = false.obs;

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
    isGamOver.value = false;
    _startTimerForLevel();
  }

  void _startTimerForLevel() {
    _gameTimer?.cancel();
    // Adaptive Timer: Higher level = Less time
    int timeForLevel = max(10, 30 - level.value);
    timer.value = timeForLevel;

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer.value > 0) {
        timer.value--;
      } else {
        t.cancel();
        isGamOver.value = true;
        // Don't call resetGame immediately, let view handle Game Over UI
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
        Get.dialog(
          // Simple Dialog for Daily Challenge Win
          GetBuilder<DailyChallengeController>(builder: (dc) {
            return AlertDialog(
              title: const Text("🎉 Daily Challenge Complete!"),
              content: Text(
                  "You kept your streak alive!\nCurrent Streak: ${dc.currentStreak.value}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Get.back(); // close dialog
                    Get.back(); // close game
                  },
                  child: const Text("Awesome!"),
                )
              ],
            );
          }),
          barrierDismissible: false,
        );
        return;
      }

      // Get.snackbar("Correct!", "Level ${level.value}"); // Too noisy
      _startTimerForLevel(); // Reset timer for new level
      generateQuestion();
    } else {
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

  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }
}
