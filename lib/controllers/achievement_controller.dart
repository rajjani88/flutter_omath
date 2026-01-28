import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Achievement data model
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final String category;
  final int targetValue;
  final RxInt currentValue;
  final RxBool isUnlocked;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.targetValue,
    int initialValue = 0,
    bool unlocked = false,
  })  : currentValue = initialValue.obs,
        isUnlocked = unlocked.obs;

  double get progress => (currentValue.value / targetValue).clamp(0.0, 1.0);
}

/// AchievementController: Manages unlockable badges and milestones
class AchievementController extends GetxController {
  static const String _unlockedKey = 'unlocked_achievements';
  static const String _progressKey = 'achievement_progress';
  static const String _streakKey = 'correct_streak';

  final SharedPreferences _prefs;

  AchievementController({required SharedPreferences prefs}) : _prefs = prefs;

  // Correct answer streak (for Sharp Shooter)
  final RxInt correctStreak = 0.obs;

  // All achievements
  final RxList<Achievement> achievements = <Achievement>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initAchievements();
    _loadProgress();
  }

  void _initAchievements() {
    achievements.addAll([
      // Economy Category
      Achievement(
        id: 'penny_pincher',
        name: 'Penny Pincher',
        description: 'Reach 5,000 coins',
        icon: '💰',
        category: 'Economy',
        targetValue: 5000,
      ),
      Achievement(
        id: 'big_spender',
        name: 'Big Spender',
        description: 'Spend 2,000 coins on power-ups',
        icon: '🛒',
        category: 'Economy',
        targetValue: 2000,
      ),

      // Dedication Category
      Achievement(
        id: 'daily_grinder',
        name: 'Daily Grinder',
        description: 'Achieve a 7-day login streak',
        icon: '🔥',
        category: 'Dedication',
        targetValue: 7,
      ),
      Achievement(
        id: 'night_owl',
        name: 'Night Owl',
        description: 'Play between 12 AM - 4 AM',
        icon: '🦉',
        category: 'Dedication',
        targetValue: 1,
      ),

      // Skill Category
      Achievement(
        id: 'sharp_shooter',
        name: 'Sharp Shooter',
        description: '10 correct answers in a row',
        icon: '🎯',
        category: 'Skill',
        targetValue: 10,
      ),

      // Social Category
      Achievement(
        id: 'show_off',
        name: 'Show Off',
        description: 'Share your score with friends',
        icon: '📣',
        category: 'Social',
        targetValue: 1,
      ),
    ]);
  }

  void _loadProgress() {
    // Load unlocked status
    final unlockedList = _prefs.getStringList(_unlockedKey) ?? [];
    for (var achievement in achievements) {
      if (unlockedList.contains(achievement.id)) {
        achievement.isUnlocked.value = true;
        achievement.currentValue.value = achievement.targetValue;
      }
    }

    // Load progress values
    for (var achievement in achievements) {
      final progress = _prefs.getInt('${_progressKey}_${achievement.id}') ?? 0;
      achievement.currentValue.value = progress;
    }

    // Load streak
    correctStreak.value = _prefs.getInt(_streakKey) ?? 0;
  }

  Future<void> _saveProgress() async {
    // Save unlocked list
    final unlockedList =
        achievements.where((a) => a.isUnlocked.value).map((a) => a.id).toList();
    await _prefs.setStringList(_unlockedKey, unlockedList);

    // Save progress values
    for (var achievement in achievements) {
      await _prefs.setInt(
          '${_progressKey}_${achievement.id}', achievement.currentValue.value);
    }

    // Save streak
    await _prefs.setInt(_streakKey, correctStreak.value);
  }

  /// Main event check method - call from game controllers
  void checkEvents(String eventType, dynamic value) {
    switch (eventType) {
      case 'correct_answer':
        _onCorrectAnswer();
        break;
      case 'wrong_answer':
        _onWrongAnswer();
        break;
      case 'coins_earned':
        _checkCoinMilestone();
        break;
      case 'coins_spent':
        _checkSpendingMilestone(value as int);
        break;
      case 'share':
        _unlockAchievement('show_off');
        break;
      case 'login_streak':
        _checkStreakMilestone(value as int);
        break;
      case 'game_played':
        _checkNightOwl();
        break;
    }
  }

  void _onCorrectAnswer() {
    correctStreak.value++;
    _saveProgress();

    // Check Sharp Shooter
    if (correctStreak.value >= 10) {
      _updateProgress('sharp_shooter', correctStreak.value);
    }
  }

  void _onWrongAnswer() {
    correctStreak.value = 0;
    _saveProgress();
  }

  void _checkCoinMilestone() {
    try {
      final coins = Get.find<CurrencyController>().coinBalance.value;
      _updateProgress('penny_pincher', coins);
    } catch (e) {
      // Controller not ready
    }
  }

  void _checkSpendingMilestone(int spent) {
    try {
      final totalSpent = Get.find<CurrencyController>().totalSpent.value;
      _updateProgress('big_spender', totalSpent);
    } catch (e) {
      // Controller not ready
    }
  }

  void _checkStreakMilestone(int streak) {
    _updateProgress('daily_grinder', streak);
  }

  void _checkNightOwl() {
    final hour = DateTime.now().hour;
    if (hour >= 0 && hour < 4) {
      _unlockAchievement('night_owl');
    }
  }

  void _updateProgress(String achievementId, int value) {
    final achievement =
        achievements.firstWhereOrNull((a) => a.id == achievementId);
    if (achievement == null || achievement.isUnlocked.value) return;

    achievement.currentValue.value = value;

    if (value >= achievement.targetValue) {
      _unlockAchievement(achievementId);
    }

    _saveProgress();
  }

  void _unlockAchievement(String achievementId) {
    final achievement =
        achievements.firstWhereOrNull((a) => a.id == achievementId);
    if (achievement == null || achievement.isUnlocked.value) return;

    achievement.isUnlocked.value = true;
    achievement.currentValue.value = achievement.targetValue;
    _saveProgress();

    // Show unlock notification
    Get.snackbar(
      "🏆 Achievement Unlocked!",
      "${achievement.icon} ${achievement.name}",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.amber.withOpacity(0.95),
      colorText: Colors.black,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Get achievements by category
  List<Achievement> getByCategory(String category) {
    return achievements.where((a) => a.category == category).toList();
  }

  /// Get unlock count
  int get unlockedCount => achievements.where((a) => a.isUnlocked.value).length;

  /// Get total count
  int get totalCount => achievements.length;
}
