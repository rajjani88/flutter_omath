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
    int a = rng.nextInt(10) + 1;
    int b = rng.nextInt(10) + 1;
    int result = a * b;

    bool showCorrect = rng.nextBool();
    int displayedResult = showCorrect ? result : result + rng.nextInt(5) - 2;

    question.value = "$a × $b = $displayedResult";
    isCorrectAnswer.value = (displayedResult == result);
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
