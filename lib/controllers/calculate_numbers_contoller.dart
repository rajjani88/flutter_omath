import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum OperationMode { auto, add, subtract, multiply, divide }

class CalculateNumbersController extends GetxController implements GetxService {
  final level = 1.obs;
  final timer = 30.obs;
  final question = ''.obs;
  final userAnswer = ''.obs;
  final correctAnswer = 0.obs;
  final mode = OperationMode.auto.obs;

  Timer? _gameTimer;

  void startGame(OperationMode selectedMode) {
    level.value = 1;
    mode.value = selectedMode;
    startTimer();
    generateQuestion();
  }

  void startTimer() {
    timer.value = 30;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer.value > 0) {
        timer.value--;
      } else {
        t.cancel();
        Get.snackbar("Time's up!", "Game over!");
        resetGame();
      }
    });
  }

  void generateQuestion() {
    int a = Random().nextInt(90) + 10;
    int b = Random().nextInt(90) + 10;

    OperationMode currentMode = mode.value;
    if (currentMode == OperationMode.auto) {
      currentMode = OperationMode.values[Random().nextInt(4) + 1];
    }

    switch (currentMode) {
      case OperationMode.add:
        question.value = "$a + $b = ?";
        correctAnswer.value = a + b;
        break;
      case OperationMode.subtract:
        question.value = "$a - $b = ?";
        correctAnswer.value = a - b;
        break;
      case OperationMode.multiply:
        question.value = "$a × $b = ?";
        correctAnswer.value = a * b;
        break;
      case OperationMode.divide:
        // Make sure divisible
        correctAnswer.value = Random().nextInt(9) + 2;
        b = correctAnswer.value;
        a = b * (Random().nextInt(9) + 2);
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
      Get.snackbar("Correct!", "Level ${level.value}");
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
