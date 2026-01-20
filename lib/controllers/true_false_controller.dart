import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';

class TrueFalseGameController extends GetxController {
  var timer = 40.obs;
  Timer? _gameTimer;

  var score = 0.obs;
  var level = 1.obs;
  var isGameOver = false.obs;

  RxString question = ''.obs;
  RxBool isCorrectAnswer = false.obs;

  @override
  void onInit() {
    super.onInit();
    startGame();
  }

  void startGame() {
    resetTimer();
    score.value = 0;
    level.value = 1;
    isGameOver.value = false;
    generateQuestion();
    startTimer();
  }

  void resetTimer() {
    timer.value = 30;
  }

  void startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timer.value == 0) {
        t.cancel();
        isGameOver.value = true;
      } else {
        timer.value--;
      }
    });
  }

  void generateQuestion() {
    final rng = Random();
    int currentLevel = level.value;
    int a, b, realResult;
    String op;

    // Difficulty Curve ("Flow Channel")
    if (currentLevel <= 5) {
      a = rng.nextInt(10) + 1;
      b = rng.nextInt(10) + 1;
      realResult = a + b;
      op = "+";
    } else if (currentLevel <= 10) {
      a = rng.nextInt(20) + 5;
      b = rng.nextInt(10) + 1;
      realResult = a - b;
      op = "-";
    } else {
      // High level: Multiplication
      a = rng.nextInt(12) + 2;
      b = rng.nextInt(10) + 2;
      realResult = a * b;
      op = "×";
    }

    bool showCorrect = rng.nextBool();
    int displayedResult;

    if (showCorrect) {
      displayedResult = realResult;
    } else {
      // Smart Logic: Ensure fake answer is NEVER equal to real answer
      do {
        int offset =
            rng.nextInt(9) - 4; // Range -4 to +4 (excluding 0 via loop)
        displayedResult = realResult + offset;
      } while (displayedResult == realResult);
    }

    question.value = "$a $op $b = $displayedResult";

    // Logic: Correct answer is True if displayed == real
    isCorrectAnswer.value = (displayedResult == realResult);
  }

  void onAnswer(bool userSaysTrue) {
    if (isGameOver.value) return;

    if (userSaysTrue == isCorrectAnswer.value) {
      score.value += 10;
      level.value++;
    } else {
      timer.value = max(timer.value - 5, 0); // penalty
    }

    if (timer.value > 0) {
      generateQuestion();
    }
  }

  void resetGame() {
    startGame();
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    super.onClose();
  }
}
