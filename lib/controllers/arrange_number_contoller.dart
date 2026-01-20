import 'dart:async';
import 'package:flutter_omath/models/order_type.dart';
import 'package:flutter_omath/utils/app_colors.dart';
import 'package:get/get.dart';
import 'dart:math';

class ArrangeNumberController extends GetxController implements GetxService {
  final RxList<int> originalNumbers = <int>[].obs;
  final RxList<int> numberPool = <int>[].obs; // Buttons
  final RxList<int?> userSelection = <int?>[].obs;

  final Rx<OrderType> currentOrder = OrderType.asc.obs;

  late Timer gameTimer;
  final RxInt remainingTime = 30.obs; // 30 seconds per round

  final RxInt currentLevel = 1.obs;

  final gameOver = false.obs;

  void generateNumbers(int count) {
    final random = Random();
    List<int> numbers = [];

    currentOrder.value =
        currentLevel.value % 2 == 0 ? OrderType.dsc : OrderType.asc;

    // Smart Generation Logic
    if (currentLevel.value <= 3) {
      // Easy: Random small numbers
      while (numbers.length < count) {
        int num = random.nextInt(20) + 1;
        if (!numbers.contains(num)) numbers.add(num);
      }
    } else if (currentLevel.value <= 7) {
      // Medium: Random 0-99
      while (numbers.length < count) {
        int num = random.nextInt(100);
        if (!numbers.contains(num)) numbers.add(num);
      }
    } else {
      // Hard: Clustered Numbers (Confusing)
      // Pick a 'base' and Generate numbers close to it
      int base = random.nextInt(70) + 15;
      int range = 15; // +/- 15
      while (numbers.length < count) {
        int num = base + (random.nextInt(range * 2) - range);
        if (num < 0) num = num.abs();
        if (!numbers.contains(num)) numbers.add(num);
      }
    }

    // Save original sorted reference
    List<int> sorted = [...numbers];
    if (currentOrder.value == OrderType.asc) {
      sorted.sort();
    } else {
      sorted.sort((a, b) => b.compareTo(a));
    }

    originalNumbers.assignAll(sorted);
    numberPool.assignAll(numbers..shuffle());
    userSelection.assignAll(List.filled(count, null));
  }

  void selectNumber(int number) {
    int index = userSelection.indexWhere((e) => e == null);
    if (index != -1) {
      userSelection[index] = number;
      numberPool.remove(number);
    }
    // Check if user filled all
    if (!userSelection.contains(null)) {
      checkAnswer();
    }
  }

  void resetGame() {
    numberPool.assignAll([...originalNumbers]..shuffle());
    userSelection.assignAll(List.filled(originalNumbers.length, null));
    // remainingTime.value = 0; // Dont reset time to 0, user needs restart?
    // Actually current logic says resetGame makes user try again.
    // If we want to restart LEVEL, we should keep time or reset time?
    // Let's reset time for fairness if level restarts.
    resetTimer();
  }

  void checkAnswer() {
    List<int> selection = userSelection.whereType<int>().toList();
    List<int> sorted = [...selection];

    if (currentOrder.value == OrderType.asc) {
      sorted.sort();
    } else {
      sorted.sort((a, b) => b.compareTo(a));
    }

    // Compare actual sequence (original) with user selection order?
    // Wait, originalNumbers is SORTED.
    // userSelection must match the DESIRED order.
    // If user filled slots [5, 10, 20], logic checks if [5,10,20] is sorted?
    // My code just checks if selection == sorted version of itself.
    // That means ANY numbers are fine as long as they are sorted?
    // BUT the user must select ALL numbers from the pool.
    // So yes, if selection contains all pool numbers and is sorted, it is correct.
    // The previous logic was: selection.toString() == sorted.toString().
    // This is valid.

    if (selection.toString() == sorted.toString()) {
      // Get.snackbar("Correct!", "Great job!"); // Removed spam
      nextLevel();
    } else {
      Get.snackbar("Oops!", "Incorrect Order.",
          backgroundColor: mRedColor, colorText: mWhitecolor);
      resetGame();
    }
  }

  void nextLevel() {
    currentLevel.value++;
    // Scale count: Starts 4. Max 9.
    int numberCount = min(9, 4 + (currentLevel.value ~/ 2));

    generateNumbers(numberCount);
    resetTimer();
  }

  void resetTimer() {
    gameTimer.cancel();
    // Adaptive Timer: Base 5s + (3s per item) - (0.5s * Level)
    int count = originalNumbers.length;
    double time = 5.0 + (count * 4.0) - (currentLevel.value * 0.5);
    remainingTime.value = max(15, time.toInt());

    startTimer();
  }

  void startTimer() {
    if (remainingTime.value <= 0) remainingTime.value = 30;
    gameOver.value = false;
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        timer.cancel();
        onTimeOut();
      }
    });
  }

  void onTimeOut() {
    Get.snackbar("Time's Up", "Try the level again!",
        backgroundColor: mRedColor, colorText: mWhitecolor);
    gameOver.value = true;
    resetGame();
  }

  disposeGame() {
    resetGame();
    if (gameTimer.isActive) {
      gameTimer.cancel();
    }
  }
}
