import 'dart:async';

import 'package:collection/collection.dart';
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

  void generateNumbers(
    int count,
  ) {
    final random = Random();
    List<int> numbers = [];

    currentOrder.value =
        currentLevel.value % 2 == 0 ? OrderType.dsc : OrderType.asc;

    while (numbers.length < count) {
      int num = random.nextInt(100);
      if (!numbers.contains(num)) {
        numbers.add(num);
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
      //validateAnswer();
      checkAnswer();
    }
  }

  void resetGame() {
    numberPool.assignAll([...originalNumbers]..shuffle());
    userSelection.assignAll(List.filled(originalNumbers.length, null));
  }

  // void validateAnswer() {
  //   final input = userSelection.whereType<int>().toList();
  //   if (const ListEquality().equals(input, originalNumbers)) {
  //     Get.snackbar('✅ Correct!', 'You arranged them in the correct order.');
  //   } else {
  //     Get.snackbar('❌ Incorrect!', 'Try again.');
  //     Future.delayed(const Duration(seconds: 1), resetGame);
  //   }
  // }

  void checkAnswer() {
    List<int> selection = userSelection.whereType<int>().toList();
    List<int> sorted = [...selection];

    if (currentOrder.value == OrderType.asc) {
      sorted.sort();
    } else {
      sorted.sort((a, b) => b.compareTo(a));
    }

    if (selection.toString() == sorted.toString()) {
      Get.snackbar("Correct!", "Great job! Moving to next level.");
      nextLevel();
    } else {
      Get.snackbar("Oops!", "Incorrect. Try again.",
          backgroundColor: mRedColor, colorText: mWhitecolor);
      resetGame();
    }
  }

  void nextLevel() {
    currentLevel.value++;
    int numberCount =
        3 + currentLevel.value; // e.g. level 1 → 4 numbers, level 2 → 5
    generateNumbers(numberCount); // You can alternate order type too!
    resetTimer();
  }

  void startTimer() {
    if (remainingTime.value == 0) {
      remainingTime.value = 30;
    }

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime.value > 0) {
        remainingTime.value--;
      } else {
        timer.cancel();
        onTimeOut();
      }
    });
  }

  void resetTimer() {
    gameTimer.cancel();
    remainingTime.value = 30;
    startTimer();
  }

  void onTimeOut() {
    Get.snackbar("Time's Up", "Try the level again!",
        backgroundColor: mRedColor, colorText: mWhitecolor);
    resetGame();
  }

  disposeGame() {
    resetGame();
    if (gameTimer.isActive) {
      gameTimer.cancel();
    }
  }
}
