import 'dart:math';

enum SudokuDifficulty { easy, medium, hard }

class SudokuUtils {
  static final Random _random = Random();

  /// Generates a new 6x6 Sudoku puzzle.
  /// Returns a Map containing 'puzzle' (grid with 0s) and 'solution' (full grid).
  static Map<String, List<List<int>>> generatePuzzle(
      SudokuDifficulty difficulty,
      {Random? random}) {
    final Random rng = random ?? _random;
    // 1. Start with a valid seed board
    List<List<int>> board = _getSeedBoard();

    // 2. Apply random transformations to increase variety
    _shuffleBoard(board, rng);

    // 3. Create a copy as the solution
    List<List<int>> solution = board.map((row) => List<int>.from(row)).toList();

    // 4. Remove numbers based on difficulty
    List<List<int>> puzzle = _removeNumbers(board, difficulty, rng);

    return {
      'puzzle': puzzle,
      'solution': solution,
    };
  }

  static List<List<int>> _getSeedBoard() {
    return [
      [1, 2, 3, 4, 5, 6],
      [4, 5, 6, 1, 2, 3],
      [2, 3, 1, 5, 6, 4],
      [5, 6, 4, 2, 3, 1],
      [3, 1, 2, 6, 4, 5],
      [6, 4, 5, 3, 1, 2],
    ];
  }

  static void _shuffleBoard(List<List<int>> board, Random rng) {
    // Swap numbers (1-6)
    List<int> mapping = [1, 2, 3, 4, 5, 6]..shuffle(rng);
    for (int r = 0; r < 6; r++) {
      for (int c = 0; c < 6; c++) {
        board[r][c] = mapping[board[r][c] - 1];
      }
    }

    // Swap rows within blocks (0-1, 2-3, 4-5)
    _swapRows(board, 0, 1, rng);
    _swapRows(board, 2, 3, rng);
    _swapRows(board, 4, 5, rng);

    // Swap columns within blocks (0-1-2, 3-4-5)
    _swapCols(board, 0, 1, rng);
    _swapCols(board, 1, 2, rng);
    _swapCols(board, 3, 4, rng);
    _swapCols(board, 4, 5, rng);
  }

  static void _swapRows(List<List<int>> board, int r1, int r2, Random rng) {
    if (rng.nextBool()) {
      List<int> temp = board[r1];
      board[r1] = board[r2];
      board[r2] = temp;
    }
  }

  static void _swapCols(List<List<int>> board, int c1, int c2, Random rng) {
    if (rng.nextBool()) {
      for (int r = 0; r < 6; r++) {
        int temp = board[r][c1];
        board[r][c1] = board[r][c2];
        board[r][c2] = temp;
      }
    }
  }

  static List<List<int>> _removeNumbers(
      List<List<int>> board, SudokuDifficulty difficulty, Random rng) {
    int cellsToRemove;
    switch (difficulty) {
      case SudokuDifficulty.easy:
        cellsToRemove = 12 + rng.nextInt(4); // 12-15 holes
        break;
      case SudokuDifficulty.medium:
        cellsToRemove = 16 + rng.nextInt(4); // 16-19 holes
        break;
      case SudokuDifficulty.hard:
        cellsToRemove = 20 + rng.nextInt(5); // 20-24 holes
        break;
    }

    List<List<int>> puzzle = board.map((row) => List<int>.from(row)).toList();
    List<int> indices = List.generate(36, (i) => i)..shuffle(rng);

    for (int i = 0; i < cellsToRemove; i++) {
      int r = indices[i] ~/ 6;
      int c = indices[i] % 6;
      puzzle[r][c] = 0;
    }

    return puzzle;
  }

  static bool isValid(List<List<int>> board, int row, int col, int num) {
    // Check row
    for (int i = 0; i < 6; i++) {
      if (board[row][i] == num) return false;
    }

    // Check col
    for (int i = 0; i < 6; i++) {
      if (board[i][col] == num) return false;
    }

    // Check 2x3 block
    int startRow = (row ~/ 2) * 2;
    int startCol = (col ~/ 3) * 3;
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 3; j++) {
        if (board[startRow + i][startCol + j] == num) return false;
      }
    }

    return true;
  }
}
