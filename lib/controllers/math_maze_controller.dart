import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';

import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:get/get.dart';

class MathMazeController extends GetxController {
  final level = 1.obs;
  final currentNumber = 0.obs;
  final startNumber = 0.obs;
  final targetNumber = 0.obs;
  final moveLimit = 4.obs;
  final movesMade = 0.obs;

  final int gridSize = 3;
  List<List<String>> grid = [];
  final _rng = Random();

  // Power-up states
  List<String> solutionPath = [];
  int pathStep = 0;
  RxInt hintRow = (-1).obs;
  RxInt hintCol = (-1).obs;

  final isGameOver = false.obs;

  @override
  void onInit() {
    super.onInit();
    generateNewLevel();
  }

  void generateNewLevel() {
    isGameOver.value = false;
    movesMade.value = 0;
    hintRow.value = -1;
    hintCol.value = -1;
    pathStep = 0;

    // Difficulty scaling
    moveLimit.value = min(6, 3 + (level.value ~/ 3));

    // Start with random number
    int start = _rng.nextInt(15) + 5;
    startNumber.value = start;
    currentNumber.value = start;

    // Generate solvable path
    solutionPath.clear();
    int temp = start;
    grid = List.generate(gridSize, (_) => List.filled(gridSize, ''));

    for (int i = 0; i < moveLimit.value; i++) {
      int op = _rng.nextInt(4);
      int val = _rng.nextInt(5) + 1;
      String opStr;

      switch (op) {
        case 0:
          opStr = '+$val';
          temp += val;
          break;
        case 1:
          opStr = '-$val';
          temp -= val;
          break;
        case 2:
          opStr = '+${val * 2}';
          temp += val * 2;
          break;
        default:
          opStr = '-${val ~/ 2 + 1}';
          temp -= (val ~/ 2 + 1);
      }
      solutionPath.add(opStr);
    }

    targetNumber.value = temp;

    // Place solution path in grid
    List<int> positions = List.generate(gridSize * gridSize, (i) => i);
    positions.shuffle();

    for (int i = 0; i < solutionPath.length && i < positions.length; i++) {
      int pos = positions[i];
      int r = pos ~/ gridSize;
      int c = pos % gridSize;
      grid[r][c] = solutionPath[i];
    }

    // Fill remaining with distractors
    for (int r = 0; r < gridSize; r++) {
      for (int c = 0; c < gridSize; c++) {
        if (grid[r][c].isEmpty) {
          int val = _rng.nextInt(8) + 1;
          grid[r][c] = _rng.nextBool() ? '+$val' : '-$val';
        }
      }
    }
  }

  void applyOperation(String operation) {
    if (movesMade.value >= moveLimit.value) return;

    final int opValue = int.parse(operation);
    currentNumber.value += opValue;
    movesMade.value++;

    if (movesMade.value == moveLimit.value) {
      if (isClosed) return;
      Get.find<AdsController>().showInterstitialAd();

      if (currentNumber.value == targetNumber.value) {
        level.value++;
        Get.find<CurrencyController>().addCoins(kCoinsPerCorrectAnswer);
        Get.find<SoundController>().playSuccess();

        _updateLeaderboard();
        _checkAchievements();

        // Level Up Dialog
        if (Get.isDialogOpen ?? false) return;
        Get.dialog(
          AlertDialog(
            title: const Text("✅ Level Up!"),
            content: const Text("You reached the target!"),
            actions: [
              TextButton(
                onPressed: () {
                  Get.back(); // close dialog
                  generateNewLevel();
                },
                child: const Text("Next Level"),
              )
            ],
          ),
          barrierDismissible: false,
        );
      } else {
        // Game Over
        isGameOver.value = true;
        Get.find<SoundController>().playWrong();
      }
    }
  }

  // ===== POWER-UP METHODS =====

  void useHint() {
    if (pathStep < solutionPath.length) {
      String nextOp = solutionPath[pathStep];
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          if (grid[r][c] == nextOp) {
            hintRow.value = r;
            hintCol.value = c;
            Future.delayed(const Duration(seconds: 1), () {
              hintRow.value = -1;
              hintCol.value = -1;
            });
            return;
          }
        }
      }
    }
  }

  void skipLevel() {
    level.value++;
    generateNewLevel();
    Get.snackbar("⏭️ Skipped!", "Moving to Level ${level.value}",
        snackPosition: SnackPosition.TOP, duration: const Duration(seconds: 1));
  }

  // ===== FUTURE INTEGRATION HOOKS =====

  void _updateLeaderboard() {
    try {
      Get.find<UserController>().addXp(SupabaseConfig.xpPerCorrectAnswer);
    } catch (e) {
      // Not initialized
    }
  }

  void _checkAchievements() {
    try {
      final ac = Get.find<AchievementController>();
      ac.checkEvents('correct_answer', null);
      ac.checkEvents('game_played', null);
      ac.checkEvents('coins_earned', null);
    } catch (e) {
      // Not initialized
    }
  }
}
