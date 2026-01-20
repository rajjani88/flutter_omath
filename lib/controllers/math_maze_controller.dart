import 'dart:math';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:get/get.dart';

class MathMazeController extends GetxController {
  final gridSize = 3;
  RxInt moveLimit = 3.obs; // Dynamic limit

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

    // Dynamic Difficulty: Move limit scales with level
    int limit = min(6, 3 + (level.value ~/ 5)); // 3 moves initially, max 6
    moveLimit.value = limit;

    List<String> solutionOps = [];
    int tempTarget = startNumber.value;

    // Generate Solution Path first (Guaranteed Solvable)
    for (int i = 0; i < limit; i++) {
      int op = possibleOperations[Random().nextInt(possibleOperations.length)];
      tempTarget += op;
      solutionOps.add(op >= 0 ? '+$op' : '$op');
    }
    targetNumber.value = tempTarget;

    // Create Grid containing solution
    List<String> flatGrid = [];
    flatGrid.addAll(solutionOps);

    // Fill remaining spots with random distractors
    int remaining = (gridSize * gridSize) - flatGrid.length;
    for (int i = 0; i < remaining; i++) {
      int op = possibleOperations[Random().nextInt(possibleOperations.length)];
      flatGrid.add(op >= 0 ? '+$op' : '$op');
    }
    flatGrid.shuffle();

    grid = List.generate(gridSize, (row) {
      return flatGrid.sublist(row * gridSize, (row + 1) * gridSize);
    }).obs;
  }

  void applyOperation(String operation) {
    if (movesMade.value >= moveLimit.value) return;

    final int opValue = int.parse(operation);
    currentNumber.value += opValue;
    movesMade.value++;

    if (movesMade.value == moveLimit.value) {
      Get.find<AdsController>().showInterstitialAd();

      if (currentNumber.value == targetNumber.value) {
        level.value++; // .value needed for RxInt ++? No, RxInt can use ++
        Get.defaultDialog(
            title: "✅ Level Up!",
            middleText: "You reached the target!",
            barrierDismissible: false);
      } else {
        Get.defaultDialog(
            title: "❌ Try Again",
            middleText: "Wrong target number.",
            barrierDismissible: false);
      }

      Future.delayed(const Duration(seconds: 2), () {
        Get.back(); // Close dialog
        // If wrong, we retry same level? Or new?
        // User requested "Better Logic". Retry same level is annoying if impossible.
        // But our logic makes it ALWAYS solvable.
        // Let's generate NEW level to avoid frustration.
        generateNewLevel();
      });
    }
  }
}
