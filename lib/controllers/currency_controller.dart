import 'package:flutter_omath/controllers/ads_contoller.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_omath/utils/consts.dart';
import 'package:flutter_omath/controllers/user_controller.dart';

/// Manages the in-game currency (coins) for power-ups and rewards.
class CurrencyController extends GetxController implements GetxService {
  static const String _coinKey = 'coin_balance';
  static const String _totalSpentKey = 'total_spent';

  final RxInt coinBalance = 0.obs;
  final RxInt totalSpent = 0.obs; // Track for "Big Spender" achievement
  final RxInt lastRewardAmount = 0.obs; // Track for "Double your reward" ad
  final RxInt sessionCoins = 0.obs; // Track coins earned in current session
  late SharedPreferences _prefs;

  @override
  void onInit() {
    super.onInit();
    _loadBalance();
  }

  Future<void> _loadBalance() async {
    _prefs = await SharedPreferences.getInstance();
    coinBalance.value = _prefs.getInt(_coinKey) ?? kStartingCoins;
    totalSpent.value = _prefs.getInt(_totalSpentKey) ?? 0;
  }

  Future<void> _saveBalance() async {
    await _prefs.setInt(_coinKey, coinBalance.value);
    _syncToCloud();
  }

  /// Sync coins to Supabase (cloud)
  void _syncToCloud() {
    _syncCoinsToSupabase();
  }

  Future<void> _syncCoinsToSupabase() async {
    try {
      if (Get.isRegistered<UserController>()) {
        final userController = Get.find<UserController>();
        if (userController.isLoggedIn.value) {
          userController.updateCloudCoins(coinBalance.value);
        }
      }
    } catch (e) {
      // Silently fail if controller not ready - strictly prevent crash
      print("Coin sync warning: $e");
    }
  }

  /// Set coins directly (used for cloud sync)
  void setCoins(int amount) {
    coinBalance.value = amount;
    _prefs.setInt(_coinKey, amount);
  }

  /// Add coins when user wins a level or watches an ad.
  void addCoins(int amount, {bool trackAsReward = true, bool isSession = true}) {
    coinBalance.value += amount;
    if (trackAsReward) {
      lastRewardAmount.value = amount;
    }
    if (isSession) {
      sessionCoins.value += amount;
    }
    _saveBalance();
  }

  /// Spend coins on power-ups. Returns true if successful.
  bool spendCoins(int cost) {
    if (coinBalance.value >= cost) {
      coinBalance.value -= cost;
      totalSpent.value += cost; // Track spending for achievements
      _saveBalance();
      _prefs.setInt(_totalSpentKey, totalSpent.value);

      // Check for spending achievement
      _checkSpendingAchievement();

      return true;
    }
    return false;
  }

  void _checkSpendingAchievement() {
    try {
      // Will trigger achievement check if controller exists
      // Handled by AchievementController listening to this
    } catch (e) {
      // Ignore
    }
  }

  /// Placeholder for rewarded ad integration.
  /// Call this after ad successfully watched.
  void watchAdForCoins() {
    Get.find<AdsController>().showRewardedAd(
      onRewardGranted: () {
        addCoins(kCoinsFromAd);
        Get.snackbar(
          "🎉 Bonus!",
          "+$kCoinsFromAd Coins added!",
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2),
        );
      },
    );
  }

  /// Check if user can afford a purchase without deducting.
  bool canAfford(int cost) => coinBalance.value >= cost;

  /// Triggered after game success to double the last reward.
  void doubleLastReward() {
    if (lastRewardAmount.value > 0) {
      int bonus = lastRewardAmount.value;
      addCoins(bonus, trackAsReward: false, isSession: false);
      lastRewardAmount.value = 0; // Reset after doubling
      Get.snackbar(
        "💎 Double Reward!",
        "+$bonus Coins added!",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Reset session counter when a new game starts
  void resetSession() {
    sessionCoins.value = 0;
  }

  /// Double the total coins earned in this session
  void doubleSessionCoins() {
    if (sessionCoins.value > 0) {
      int bonus = sessionCoins.value;
      addCoins(bonus, trackAsReward: false, isSession: false);
      sessionCoins.value = 0; // Reset after doubling
      Get.snackbar(
        "💰 Session Doubled!",
        "+$bonus Coins added!",
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    }
  }
}
