import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class MathGridPuzzleController extends GetxController implements GetxService {
  RxInt level = 1.obs;
  RxInt timeLeft = 30.obs;
  RxString currentQuestion = ''.obs;
  RxList<int> answerOptions = <int>[].obs;
  late Timer _timer;
  int _correctAnswer = 0;
  final Random _random = Random();

  void startGame() {
    timeLeft.value = 30;
    _generateNewQuestion();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft.value <= 0) {
        timer.cancel();
        _showGameOver();
      } else {
        timeLeft.value--;
      }
    });
  }

  void _showGameOver() {
    Get.defaultDialog(
      title: 'Game Over',
      titleStyle: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      content: Text('Your level: ${level.value}',
          style: const TextStyle(fontSize: 18)),
      barrierDismissible: false, // Force user to choose
      confirmTextColor: Colors.white,
      buttonColor: Colors.green,
      cancelTextColor: Colors.red,
      onConfirm: () {
        Get.back(); // Close dialog
        _resetGame(); // Dialog might handle close automatically? usually confirm needs manual close?
        // Get.defaultDialog auto-close behavior depends on implementation.
        // Standard Get.defaultDialog usually REQUIRES manual close in onConfirm if not using textConfirm alone?
        // Actually usually onConfirm implies ACTION.
        // Let's use standard pattern.
      },
      textConfirm: 'Play Again',
      textCancel: 'Menu',
      onCancel: () {
        Get.back(); // Close Dialog
        Get.back(); // Close Screen
      },
    );
    Get.find<AdsController>().showInterstitialAd();
  }

  void _resetGame() {
    level.value = 1;
    timeLeft.value = 30;
    startGame();
  }

  void _generateNewQuestion() {
    int a = _random.nextInt(50) + 1;
    int b = _random.nextInt(50) + 1;

    _correctAnswer = a + b;
    currentQuestion.value = "$a + $b = ?";

    _generateAnswerOptions();
  }

  void _generateAnswerOptions() {
    Set<int> options = {_correctAnswer};
    // Smart Fakes: Close numbers to confuse logic
    // +/- 1, +/- 2, +/- 10, and some randoms
    List<int> offsets = [-1, 1, -2, 2, -10, 10, -5, 5];

    // Fill with smart fakes first
    for (int offset in offsets) {
      int fake = _correctAnswer + offset;
      if (fake > 0 && fake != _correctAnswer) {
        options.add(fake);
      }
      if (options.length >= 9) break;
    }

    // Fill remaining with random range if needed
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
      // Dynamic Timer Logic (Pressure)
      // Level 1: ~30s, Level 10: ~20s, Level 20: ~10s
      int newTime = max(10, 30 - level.value);
      timeLeft.value = newTime;
    } else {
      timeLeft.value = max(0, timeLeft.value - 5);
      Fluttertoast.showToast(msg: "Wrong! -5s");
    }

    if (timeLeft.value > 0) {
      _generateNewQuestion();
    } else {
      _timer.cancel(); // Ensure timer stops if penalty killed it
      _showGameOver();
    }
  }

  void gameDispose() {
    _timer.cancel();
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }
}
