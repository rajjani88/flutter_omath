import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// UserController: Manages authentication, profile, daily rewards, and social sharing
class UserController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // User state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isOffline = false.obs;

  // Profile data
  final RxString odUsername = 'Player'.obs;
  final RxInt avatarId = 0.obs;
  final RxInt totalXp = 0.obs;
  final RxInt loginStreak = 0.obs;
  final Rx<DateTime?> lastLogin = Rx<DateTime?>(null);
  final Rx<DateTime?> lastShareDate = Rx<DateTime?>(null);

  // Daily reward state
  final RxBool hasDailyReward = false.obs;
  final RxInt dailyRewardAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Delay initialization to ensure UI is ready (prevents No Overlay Widget errors)
    Future.delayed(const Duration(seconds: 2), () {
      _initAuth();
    });
  }

  /// Initialize authentication - auto anonymous login
  Future<void> _initAuth() async {
    isLoading.value = true;

    // Check existing session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      currentUser.value = session.user;
      isLoggedIn.value = true;
      await _loadProfile();
    } else {
      await signInAnonymously();
    }

    isLoading.value = false;
  }

  /// Anonymous sign-in
  Future<void> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      if (response.user != null) {
        currentUser.value = response.user;
        isLoggedIn.value = true;
        await _loadProfile();
      }
    } catch (e) {
      debugPrint('Anonymous login error: $e');
      // Fallback: work offline
      isLoggedIn.value = false;
    }
  }

  /// Load user profile from Supabase
  Future<void> _loadProfile() async {
    if (currentUser.value == null) return;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser.value!.id)
          .single();

      odUsername.value = data['username'] ?? 'Player';
      avatarId.value = data['avatar_id'] ?? 0;
      totalXp.value = data['total_xp'] ?? 0;
      loginStreak.value = data['login_streak'] ?? 0;

      if (data['last_login'] != null) {
        lastLogin.value = DateTime.parse(data['last_login']);
      }
      if (data['last_share_date'] != null) {
        lastShareDate.value = DateTime.parse(data['last_share_date']);
      }

      // Sync coins with local (use higher value)
      await _syncCoins(data['coin_balance'] ?? 100);

      // Check for daily reward
      await _checkDailyLogin();
    } catch (e) {
      debugPrint('Load profile error: $e');
    }
  }

  /// Sync coins between local and cloud (use higher value)
  Future<void> _syncCoins(int cloudCoins) async {
    final currencyController = Get.find<CurrencyController>();
    final localCoins = currencyController.coinBalance.value;

    // Use the higher value to prevent data loss
    final syncedCoins = localCoins > cloudCoins ? localCoins : cloudCoins;

    // Update local
    if (syncedCoins != localCoins) {
      currencyController.setCoins(syncedCoins);
    }

    // Update cloud if local was higher
    if (localCoins > cloudCoins && currentUser.value != null) {
      await _supabase.from('profiles').update({'coin_balance': syncedCoins}).eq(
          'id', currentUser.value!.id);
    }
  }

  /// Check daily login and award streak bonus
  Future<void> _checkDailyLogin() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastLogin.value == null) {
      // First login ever
      loginStreak.value = 1;
      hasDailyReward.value = true;
      dailyRewardAmount.value = SupabaseConfig.getDailyReward(1);
    } else {
      final lastDate = DateTime(
        lastLogin.value!.year,
        lastLogin.value!.month,
        lastLogin.value!.day,
      );

      final difference = today.difference(lastDate).inDays;

      if (difference == 0) {
        // Already logged in today
        hasDailyReward.value = false;
      } else if (difference == 1) {
        // Consecutive day - increment streak
        loginStreak.value++;
        hasDailyReward.value = true;
        dailyRewardAmount.value =
            SupabaseConfig.getDailyReward(loginStreak.value);
      } else {
        // Missed days - reset streak
        loginStreak.value = 1;
        hasDailyReward.value = true;
        dailyRewardAmount.value = SupabaseConfig.getDailyReward(1);
      }
    }

    // Update last_login
    lastLogin.value = now;
    await _updateProfile({'last_login': now.toIso8601String()});
  }

  /// Claim daily reward
  Future<void> claimDailyReward() async {
    if (!hasDailyReward.value) return;

    final amount = dailyRewardAmount.value;
    Get.find<CurrencyController>().addCoins(amount);

    hasDailyReward.value = false;

    // Update streak in database
    await _updateProfile({
      'login_streak': loginStreak.value,
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        "🎁 Daily Reward!",
        "+$amount Coins (Day ${loginStreak.value} Streak)",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withOpacity(0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// Check if username is available (excluding current user)
  Future<dynamic> isUsernameAvailable(String username) async {
    // Check internet connection first (mock for now or basic check)
    try {
      // Simple connectivity check
      // If we are already in offline mode fallback
      if (isOffline.value) return "OFFLINE";

      if (currentUser.value == null) return false;
      if (username.trim().isEmpty) return false;

      final result = await _supabase
          .from('profiles')
          .select()
          .eq('username', username.trim())
          .neq('id', currentUser.value!.id)
          .maybeSingle();

      // If result is null, username is available
      return result == null;
    } catch (e) {
      debugPrint('Username check error: $e');
      // Assume offline/error
      return "OFFLINE";
    }
  }

  /// Update username (with uniqueness validation)
  Future<void> updateUsername(String newName) async {
    if (newName.trim().isEmpty) return;

    // Check availability
    final result = await isUsernameAvailable(newName);

    if (result == "OFFLINE") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "📡 No Internet",
          "Please check your internet connection.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
        );
      });
      return;
    }

    if (result == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "❌ Error",
          "Username '$newName' is already taken! Try another.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withOpacity(0.9),
          colorText: Colors.white,
        );
      });
      return;
    }

    // Username is available, proceed with update
    odUsername.value = newName.trim();
    await _updateProfile({'username': odUsername.value});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("✅ Updated", "Username changed to ${odUsername.value}",
          snackPosition: SnackPosition.TOP);
    });
  }

  /// Update avatar
  Future<void> updateAvatar(int newAvatarId) async {
    avatarId.value = newAvatarId.clamp(0, 4);
    await _updateProfile({'avatar_id': avatarId.value});
  }

  /// Add XP (called from game controllers)
  Future<void> addXp(int amount) async {
    totalXp.value += amount;
    await _updateProfile({'total_xp': totalXp.value});
  }

  /// Update cloud coins (called from CurrencyController)
  Future<void> updateCloudCoins(int coins) async {
    if (currentUser.value == null) return;
    await _updateProfile({'coin_balance': coins});
  }

  /// Share app with anti-spam logic
  Future<void> shareApp() async {
    debugPrint("UserController: shareApp called");
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check if already shared today
      if (lastShareDate.value != null) {
        final lastDate = DateTime(
          lastShareDate.value!.year,
          lastShareDate.value!.month,
          lastShareDate.value!.day,
        );

        if (today.isAtSameMomentAs(lastDate)) {
          debugPrint("UserController: Already shared today");
          debugPrint("UserController: Already shared today");
          if (Get.context != null) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              SnackBar(
                content: const Text(
                    "You've already earned your share reward today!"),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          } else {
            // Fallback if context is somehow null
            debugPrint(
                "UserController: Get.context is null, cannot show snackbar");
          }
          return;
        }
      }

      debugPrint("UserController: Invoking Share.share");
      // Open share dialog
      final result = await Share.share(
        "🧠 Challenge your brain with OMath Puzzle! Can you beat my score? Download now!",
        subject: "OMath Puzzle Game",
      );
      debugPrint("UserController: Share result: ${result.status}");

      // If shared successfully, give reward
      if (result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed) {
        lastShareDate.value = now;
        await _updateProfile({'last_share_date': now.toIso8601String()});

        Get.find<CurrencyController>()
            .addCoins(SupabaseConfig.shareRewardCoins);

        try {
          Get.snackbar(
            "🎉 Thanks for Sharing!",
            "+${SupabaseConfig.shareRewardCoins} Coins earned!",
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } catch (e) {
          debugPrint("UserController: Snackbar error: $e");
        }
      }
    } catch (e) {
      debugPrint("UserController: shareApp ERROR: $e");
      try {
        Get.snackbar("Error", "Could not share: $e");
      } catch (_) {}
    }
  }

  /// Helper: Update profile in Supabase
  Future<void> _updateProfile(Map<String, dynamic> data) async {
    if (currentUser.value == null) return;

    try {
      await _supabase
          .from('profiles')
          .update(data)
          .eq('id', currentUser.value!.id);
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
  }

  /// Get avatar asset path
  String get avatarPath => SupabaseConfig.getAvatarPath(avatarId.value);
}
