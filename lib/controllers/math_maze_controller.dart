import 'dart:math';
import 'package:get/get.dart';

class MathMazeController extends GetxController {
  final gridSize = 3;
  final moveLimit = 4;

  RxInt level = 1.obs;
  RxInt startNumber = 0.obs;
  RxInt currentNumber = 0.obs;
  RxInt targetNumber = 0.obs;
  RxInt movesMade = 0.obs;

  late RxList<List<String>> grid;

  final List<int> possibleOperations = [-5, -3, -2, -1, 1, 2, 3, 5];

  @override
  void onInit() {
    super.onInit();
    generateNewLevel();
  }

  void generateNewLevel() {
    startNumber.value = Random().nextInt(20) + 1;
    currentNumber.value = startNumber.value;
    movesMade.value = 0;
    grid = List.generate(
        gridSize,
        (_) => List.generate(gridSize, (_) {
              final op = possibleOperations[
                  Random().nextInt(possibleOperations.length)];
              return op >= 0 ? '+$op' : '$op';
            })).obs;

    // Randomly simulate reaching the target
    int temp = startNumber.value;
    for (int i = 0; i < moveLimit; i++) {
      int step =
          possibleOperations[Random().nextInt(possibleOperations.length)];
      temp += step;
    }
    targetNumber.value = temp;
  }

  void applyOperation(String operation) {
    if (movesMade.value >= moveLimit) return;

    final int opValue = int.parse(operation);
    currentNumber.value += opValue;
    movesMade.value++;

    if (movesMade.value == moveLimit) {
      if (currentNumber.value == targetNumber.value) {
        level++;
        Get.defaultDialog(
            title: "✅ Level Up!", middleText: "You reached the target!");
      } else {
        Get.defaultDialog(
            title: "❌ Try Again", middleText: "Wrong target number.");
      }

      Future.delayed(const Duration(seconds: 2), () {
        Get.back(); // Close dialog
        generateNewLevel();
      });
    }
  }
}
