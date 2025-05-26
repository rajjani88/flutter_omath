import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
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
      content: Text('Your level: ${level.value}'),
      onConfirm: () {
        Get.back();
        _resetGame();
      },
      textConfirm: 'Play Again',
    );
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
    List<int> nums = [6, 7, 8, 9, 10, 11, 12, 13, 14, 15];
    while (options.length < 9) {
      //int wrong = _correctAnswer + _random.nextInt(20) - 10;
      nums.shuffle();
      int wrong = _correctAnswer + nums[0] - 10;

      if (wrong != _correctAnswer && wrong > 0) {
        options.add(wrong);
      }
    }
    answerOptions.value = options.toList()..shuffle();
  }

  void onAnswerSelected(int selected) {
    if (selected == _correctAnswer) {
      level.value++;
    } else {
      timeLeft.value -= 5;
      Fluttertoast.showToast(msg: "This is wrong answer");
    }

    if (timeLeft.value > 0) {
      _generateNewQuestion();
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
