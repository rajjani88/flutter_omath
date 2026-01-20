import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DailyChallengeController extends GetxController {
  final SharedPreferences _prefs;

  DailyChallengeController({required SharedPreferences prefs}) : _prefs = prefs;

  RxInt currentStreak = 0.obs;
  RxBool isTodayCompleted = false.obs;
  RxString lastPlayedDate = "".obs;

  static const String keyStreak = 'daily_streak';
  static const String keyLastPlayedDate = 'last_played_date';

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    currentStreak.value = _prefs.getInt(keyStreak) ?? 0;
    lastPlayedDate.value = _prefs.getString(keyLastPlayedDate) ?? "";
    _checkStatus();
  }

  void _checkStatus() {
    String today = _getTodayString();
    if (lastPlayedDate.value == today) {
      isTodayCompleted.value = true;
    } else {
      isTodayCompleted.value = false;
      // Check if streak is broken (i.e., last played was before yesterday)
      if (lastPlayedDate.value.isNotEmpty) {
        DateTime last = _parseDate(lastPlayedDate.value);
        DateTime now = DateTime.now();
        // Calculate difference in days, ignoring time
        DateTime todayDate = DateTime(now.year, now.month, now.day);
        DateTime lastDate = DateTime(last.year, last.month, last.day);

        int difference = todayDate.difference(lastDate).inDays;

        if (difference > 1) {
          // Streak broken
          // Don't reset here immediately, maybe wait until they actually play?
          // Requirement says: "If the user missed yesterday, reset the streak to 1."
          // Usually resetting happens when they try to play or when they complete the new challenge.
          // Leaving it as is for now, will handle reset on completion or just display 0 if we want strict logic.
        }
      }
    }
  }

  void completeChallenge() {
    if (isTodayCompleted.value) return;

    String today = _getTodayString();
    DateTime now = DateTime.now();
    DateTime todayDate = DateTime(now.year, now.month, now.day);

    if (lastPlayedDate.value.isEmpty) {
      // First time playing
      currentStreak.value = 1;
    } else {
      DateTime last = _parseDate(lastPlayedDate.value);
      DateTime lastDate = DateTime(last.year, last.month, last.day);
      int difference = todayDate.difference(lastDate).inDays;

      if (difference == 1) {
        // consecutve day
        currentStreak.value++;
      } else if (difference > 1) {
        // missed a day or more
        currentStreak.value = 1;
      } else {
        // difference == 0, already handled by isTodayCompleted check usually,
        // but safe to do nothing or just set completed.
      }
    }

    lastPlayedDate.value = today;
    isTodayCompleted.value = true;

    _prefs.setInt(keyStreak, currentStreak.value);
    _prefs.setString(keyLastPlayedDate, lastPlayedDate.value);
  }

  // Returns integer seed based on date, e.g., 20240113
  int getDailySeed() {
    DateTime now = DateTime.now();
    return int.parse(
        "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}");
  }

  // Example method to generate questions using the daily seed
  List<String> generateDailyQuestions() {
    int seed = getDailySeed();
    Random random = Random(seed);

    List<String> questions = [];
    for (int i = 0; i < 5; i++) {
      int a = random.nextInt(100);
      int b = random.nextInt(100);
      questions.add("$a + $b = ?");
    }
    return questions;
  }

  String _getTodayString() {
    DateTime now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  DateTime _parseDate(String dateStr) {
    try {
      List<String> parts = dateStr.split('-');
      return DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
    } catch (e) {
      return DateTime.now(); // Fallback
    }
  }
}
