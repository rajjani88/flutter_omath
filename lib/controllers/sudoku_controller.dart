import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/achievement_controller.dart';
import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/daily_challenge_controller.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/controllers/user_controller.dart';
import 'package:flutter_omath/screens/home_screen/home_screen.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/utils/sudoku_utils.dart';
import 'package:flutter_omath/widgets/daily_challenge_success_popup.dart';
import 'package:get/get.dart';

class SudokuController extends GetxController {
  // Game State
  final RxList<RxList<int>> currentBoard = <RxList<int>>[].obs;
  final RxList<List<int>> solution = <List<int>>[].obs;
  final RxList<List<bool>> isFixed = <List<bool>>[].obs;
  final RxMap<int, Set<int>> notes = <int, Set<int>>{}.obs;

  // Selected cell
  final RxInt selectedRow = (-1).obs;
  final RxInt selectedCol = (-1).obs;

  // Display State
  final RxInt level = 1.obs;
  final Rx<SudokuDifficulty> difficulty = SudokuDifficulty.easy.obs;
  final RxInt timeLeft = 0.obs;
  final RxBool isGameOver = false.obs;
  final RxBool isGameWon = false.obs;
  final RxBool isNotesMode = false.obs;
  final RxInt mistakes = 0.obs;
  final RxInt timerSeconds = 0.obs;
  final RxBool isTimeFrozen = false.obs;

  // Daily Challenge
  bool isDailyChallenge = false;
  int? dailySeed;

  Timer? _gameTimer;
  Timer? _freezeTimer;
  final SoundController _sound = Get.find<SoundController>();

  @override
  void onInit() {
    super.onInit();
    startNewGame();
  }

  void startNewGame({SudokuDifficulty? diff}) {
    Get.find<CurrencyController>().resetSession();
    if (diff != null) difficulty.value = diff;
    _stopTimer();

    final puzzleData = SudokuUtils.generatePuzzle(difficulty.value,
        random: dailySeed != null ? Random(dailySeed) : null);
    final puzzle = puzzleData['puzzle']!;
    final solved = puzzleData['solution']!;

    currentBoard.value = puzzle.map((row) => row.obs).toList();
    solution.value = solved;
    isFixed.value =
        puzzle.map((row) => row.map((cell) => cell != 0).toList()).toList();
    notes.clear();

    selectedRow.value = -1;
    selectedCol.value = -1;
    mistakes.value = 0;
    isGameOver.value = false;
    isGameWon.value = false;
    timeLeft.value = 0;
    timerSeconds.value = 0;

    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isTimeFrozen.value) {
        timerSeconds.value++;
      }
    });
  }

  void _stopTimer() {
    _gameTimer?.cancel();
  }

  @override
  void onClose() {
    _gameTimer?.cancel();
    _freezeTimer?.cancel();
    super.onClose();
  }

  void selectCell(int r, int c) {
    if (isGameWon.value) return;
    selectedRow.value = r;
    selectedCol.value = c;
    _sound.playClick();
  }

  void toggleNotesMode() {
    isNotesMode.value = !isNotesMode.value;
    _sound.playClick();
  }

  void inputNumber(int num) {
    if (selectedRow.value == -1 || selectedCol.value == -1) return;
    if (isFixed[selectedRow.value][selectedCol.value]) return;
    if (isGameWon.value) return;

    int r = selectedRow.value;
    int c = selectedCol.value;

    if (isNotesMode.value) {
      // Toggle note
      int cellIndex = r * 6 + c;
      if (!notes.containsKey(cellIndex)) {
        notes[cellIndex] = <int>{};
      }
      if (notes[cellIndex]!.contains(num)) {
        notes[cellIndex]!.remove(num);
      } else {
        notes[cellIndex]!.add(num);
      }
      notes.refresh(); // Important for UI update
    } else {
      // Input number
      currentBoard[r][c] = num;
      if (num == solution[r][c]) {
        _sound.playSuccess();
        _checkWin();
      } else {
        // Wrong answer but relaxed mode - just show mistake
        mistakes.value++;
        _sound.playWrong();
      }
    }
  }

  void clearCell() {
    if (selectedRow.value == -1 || selectedCol.value == -1) return;
    if (isFixed[selectedRow.value][selectedCol.value]) return;

    currentBoard[selectedRow.value][selectedCol.value] = 0;
    notes.remove(selectedRow.value * 6 + selectedCol.value);
    _sound.playClick();
  }

  void useHint() {
    _applyRandomHint();
    _sound.playSuccess();
  }

  void _applyRandomHint() {
    List<Point<int>> emptyCells = [];
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        if (currentBoard[r][c] == 0) {
          emptyCells.add(Point(r, c));
        }
      }
    }

    if (emptyCells.isNotEmpty) {
      final hintCell = emptyCells[Random().nextInt(emptyCells.length)];
      currentBoard[hintCell.x][hintCell.y] = solution[hintCell.x][hintCell.y];
      _checkWin();
    }
  }

  void _checkWin() {
    bool allFilled = true;
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        if (currentBoard[r][c] != solution[r][c]) {
          allFilled = false;
          break;
        }
      }
    }

    if (allFilled) {
      isGameWon.value = true;
      _stopTimer();

      if (isDailyChallenge) {
        final dc = Get.find<DailyChallengeController>();
        dc.completeChallenge();
        Get.dialog(
          DailyChallengeSuccessPopup(
            streak: dc.currentStreak.value,
            onContinue: () => Get.offAll(() => const HomeScreen()),
          ),
          barrierDismissible: false,
        );
      } else {
        _rewardUser();
      }
    }
  }

  void _rewardUser() {
    Get.find<AdsController>().onLevelCompleted();
    Get.find<CurrencyController>()
        .addCoins(kCoinsPerCorrectAnswer * 2); // Double for Sudoku
    Get.find<UserController>().addXp(20);
    try {
      Get.find<AchievementController>().checkEvents('correct_answer', null);
      Get.find<AchievementController>().checkEvents('game_played', null);
    } catch (_) {}
  }

  String formatTime() {
    int minutes = timerSeconds.value ~/ 60;
    int seconds = timerSeconds.value % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void freezeTime() {
    if (isTimeFrozen.value) return;

    isTimeFrozen.value = true;
    _freezeTimer?.cancel();
    _freezeTimer = Timer(const Duration(seconds: kFreezeDuration), () {
      isTimeFrozen.value = false;
    });
  }

  void skipLevel() {
    startNewGame();
    Get.snackbar("⏭️ Skipped!", "New Sudoku generated",
        snackPosition: SnackPosition.TOP);
  }
}
