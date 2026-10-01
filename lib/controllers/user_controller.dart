import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_omath/controllers/currency_controller.dart';
import 'package:flutter_omath/controllers/leaderboard_controller.dart';
import 'package:flutter_omath/utils/supabase_config.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// UserController: Manages authentication, profile, daily rewards, and social sharing
class UserController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Persistent device user ID
  String _deviceId = '';
  String get effectiveUserId => currentUser.value?.id ?? _deviceId;

  // User state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isLoggedIn = false.obs;
  final RxBool isOffline = false.obs;

  // Profile data
  final RxString odUsername = 'Player'.obs;
  final RxInt avatarId = 0.obs;
  final RxInt totalXp = 0.obs;
  final RxInt loginStreak = 1.obs;
  final Rx<DateTime?> lastLogin = Rx<DateTime?>(null);
  final Rx<DateTime?> lastShareDate = Rx<DateTime?>(null);

  // Daily reward state
  final RxBool hasDailyReward = false.obs;
  final RxInt dailyRewardAmount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadLocalData();
    // Initialize cloud profile
    Future.delayed(const Duration(milliseconds: 500), () {
      _initAuth();
    });
  }

  /// Load device ID and cached profile from SharedPreferences
  Future<void> _loadLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _deviceId = prefs.getString('DEVICE_ID') ?? '';
      if (_deviceId.isEmpty) {
        _deviceId = _generateUuidV4();
        await prefs.setString('DEVICE_ID', _deviceId);
      }

      final savedName = prefs.getString('DEVICE_USERNAME');
      if (savedName != null && savedName.isNotEmpty) {
        odUsername.value = savedName;
      }

      totalXp.value = prefs.getInt('SAVED_TOTAL_XP') ?? 0;
      avatarId.value = prefs.getInt('SAVED_AVATAR_ID') ?? 0;
      loginStreak.value = prefs.getInt('SAVED_LOGIN_STREAK') ?? 1;

      final lastLoginStr = prefs.getString('SAVED_LAST_LOGIN');
      if (lastLoginStr != null) {
        lastLogin.value = DateTime.tryParse(lastLoginStr);
      }

      final lastShareStr = prefs.getString('SAVED_LAST_SHARE');
      if (lastShareStr != null) {
        lastShareDate.value = DateTime.tryParse(lastShareStr);
      }
    } catch (e) {
      debugPrint('Error loading local user data: $e');
    }
  }

  /// Generate RFC4122 v4 UUID without external dependencies
  static String _generateUuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40; // Version 4
    bytes[8] = (bytes[8] & 0x3f) | 0x80; // Variant 10
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }

  /// Initialize authentication & cloud profile
  Future<void> _initAuth() async {
    isLoading.value = true;

    // Check existing Supabase session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      currentUser.value = session.user;
      isLoggedIn.value = true;
    } else {
      await signInAnonymously();
    }

    // Ensure we have a unique default username if this is a new install
    await _ensureDefaultUniqueUsername();

    // Sync profile with cloud
    await _loadProfile();

    isLoading.value = false;
  }

  /// Anonymous sign-in attempt
  Future<void> signInAnonymously() async {
    try {
      final response = await _supabase.auth.signInAnonymously();
      if (response.user != null) {
        currentUser.value = response.user;
        isLoggedIn.value = true;
      }
    } catch (e) {
      debugPrint('Anonymous login error (using device ID): $e');
      isLoggedIn.value = false;
    }
  }

  /// Generate a unique default username per device
  Future<void> _ensureDefaultUniqueUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final existingName = prefs.getString('DEVICE_USERNAME');
    if (existingName != null && existingName.isNotEmpty) {
      odUsername.value = existingName;
      return;
    }

    // List of math/puzzle themed prefixes
    const prefixes = [
      'MathWhiz',
      'NumberNinja',
      'EulerPrime',
      'MatrixMaster',
      'Brainiac',
      'QuantumSolver',
      'LogicPro',
      'CalcMaster',
      'Pythagoras',
      'VectorKing',
      'MathWizard',
      'AlphaSolver'
    ];

    final rng = Random();
    String candidate = '';
    bool isUnique = false;
    int attempts = 0;

    while (!isUnique && attempts < 10) {
      attempts++;
      final prefix = prefixes[rng.nextInt(prefixes.length)];
      final suffix = 1000 + rng.nextInt(9000);
      candidate = '${prefix}_$suffix';

      // Check against Supabase
      try {
        final existing = await _supabase
            .from('profiles')
            .select('id')
            .ilike('username', candidate)
            .maybeSingle();

        if (existing == null) {
          isUnique = true;
        }
      } catch (e) {
        // If network issue, accept generated candidate
        isUnique = true;
      }
    }

    if (candidate.isEmpty) {
      candidate = 'Player_${1000 + rng.nextInt(9000)}';
    }

    odUsername.value = candidate;
    await prefs.setString('DEVICE_USERNAME', candidate);
  }

  /// Load user profile from Supabase and sync with local
  Future<void> _loadProfile() async {
    final userId = effectiveUserId;
    if (userId.isEmpty) return;

    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        // Create initial profile in cloud
        final newProfile = {
          'id': userId,
          'username': odUsername.value,
          'avatar_id': avatarId.value,
          'total_xp': totalXp.value,
          'coin_balance': Get.find<CurrencyController>().coinBalance.value,
          'login_streak': loginStreak.value,
          'last_login': DateTime.now().toUtc().toIso8601String(),
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        };

        await _supabase.from('profiles').upsert(newProfile);
        await _checkDailyLogin();
        return;
      }

      // Existing cloud profile: sync values
      if (data['username'] != null && data['username'].toString().trim().isNotEmpty) {
        odUsername.value = data['username'].toString().trim();
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('DEVICE_USERNAME', odUsername.value);
      }

      avatarId.value = (data['avatar_id'] as num?)?.toInt() ?? avatarId.value;

      final cloudXp = (data['total_xp'] as num?)?.toInt() ?? 0;
      if (cloudXp > totalXp.value) {
        totalXp.value = cloudXp;
      } else if (totalXp.value > cloudXp) {
        // Local XP is higher, update cloud
        await _updateProfile({'total_xp': totalXp.value});
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('SAVED_TOTAL_XP', totalXp.value);
      await prefs.setInt('SAVED_AVATAR_ID', avatarId.value);

      loginStreak.value = (data['login_streak'] as num?)?.toInt() ?? loginStreak.value;

      if (data['last_login'] != null) {
        lastLogin.value = DateTime.tryParse(data['last_login']);
      }
      if (data['last_share_date'] != null) {
        lastShareDate.value = DateTime.tryParse(data['last_share_date']);
      }

      // Sync coins (use higher value)
      await _syncCoins((data['coin_balance'] as num?)?.toInt() ?? 100);

      // Check daily login
      await _checkDailyLogin();
    } catch (e) {
      debugPrint('Load profile error: $e');
    }
  }

  /// Sync coins between local and cloud (use higher value)
  Future<void> _syncCoins(int cloudCoins) async {
    final currencyController = Get.find<CurrencyController>();
    final localCoins = currencyController.coinBalance.value;

    final syncedCoins = localCoins > cloudCoins ? localCoins : cloudCoins;

    if (syncedCoins != localCoins) {
      currencyController.setCoins(syncedCoins);
    }

    if (localCoins > cloudCoins) {
      await _updateProfile({'coin_balance': syncedCoins});
    }
  }

  /// Check daily login and award streak bonus
  Future<void> _checkDailyLogin() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastLogin.value == null) {
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
        hasDailyReward.value = false;
      } else if (difference == 1) {
        loginStreak.value++;
        hasDailyReward.value = true;
        dailyRewardAmount.value =
            SupabaseConfig.getDailyReward(loginStreak.value);
      } else {
        loginStreak.value = 1;
        hasDailyReward.value = true;
        dailyRewardAmount.value = SupabaseConfig.getDailyReward(1);
      }
    }

    lastLogin.value = now;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('SAVED_LAST_LOGIN', now.toIso8601String());
    await prefs.setInt('SAVED_LOGIN_STREAK', loginStreak.value);
    await _updateProfile({'last_login': now.toUtc().toIso8601String(), 'login_streak': loginStreak.value});
  }

  /// Claim daily reward
  Future<void> claimDailyReward() async {
    if (!hasDailyReward.value) return;

    final amount = dailyRewardAmount.value;
    Get.find<CurrencyController>().addCoins(amount);

    hasDailyReward.value = false;

    await _updateProfile({
      'login_streak': loginStreak.value,
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar(
        "🎁 Daily Reward!",
        "+$amount Coins (Day ${loginStreak.value} Streak)",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.withValues(alpha: 0.9),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    });
  }

  /// Check if username is available (excluding current device/user)
  Future<dynamic> isUsernameAvailable(String username) async {
    try {
      final trimmed = username.trim();
      if (trimmed.isEmpty || trimmed.length < 3) return false;

      // If user kept the same name, it's valid
      if (trimmed.toLowerCase() == odUsername.value.toLowerCase()) return true;

      final result = await _supabase
          .from('profiles')
          .select('id')
          .ilike('username', trimmed)
          .neq('id', effectiveUserId)
          .maybeSingle();

      // If result is null, username is not taken
      return result == null;
    } catch (e) {
      debugPrint('Username check error: $e');
      return "OFFLINE";
    }
  }

  /// Update username (with uniqueness validation)
  Future<void> updateUsername(String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed.length < 3) return;

    final result = await isUsernameAvailable(trimmed);

    if (result == "OFFLINE") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "📡 Connection Error",
          "Could not verify username. Please check your internet connection.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      });
      return;
    }

    if (result == false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.snackbar(
          "❌ Error",
          "Username '$trimmed' is already taken! Try another.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
        );
      });
      return;
    }

    // Username is available, proceed with update
    odUsername.value = trimmed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('DEVICE_USERNAME', trimmed);
    await _updateProfile({'username': odUsername.value});

    // Refresh leaderboard so new name displays immediately
    if (Get.isRegistered<LeaderboardController>()) {
      Get.find<LeaderboardController>().refresh();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.snackbar("✅ Updated", "Username changed to ${odUsername.value}",
          snackPosition: SnackPosition.TOP);
    });
  }

  /// Update avatar
  Future<void> updateAvatar(int newAvatarId) async {
    avatarId.value = newAvatarId.clamp(0, 25);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('SAVED_AVATAR_ID', avatarId.value);
    await _updateProfile({'avatar_id': avatarId.value});
    if (Get.isRegistered<LeaderboardController>()) {
      Get.find<LeaderboardController>().refresh();
    }
  }

  /// Add XP (called from any game controller when user solves or wins)
  Future<void> addXp(int amount) async {
    totalXp.value += amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('SAVED_TOTAL_XP', totalXp.value);
    await _updateProfile({'total_xp': totalXp.value});

    // Refresh leaderboard live
    if (Get.isRegistered<LeaderboardController>()) {
      Get.find<LeaderboardController>().refresh();
    }
  }

  /// Update cloud coins (called from CurrencyController)
  Future<void> updateCloudCoins(int coins) async {
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
          if (Get.context != null) {
            ScaffoldMessenger.of(Get.context!).showSnackBar(
              const SnackBar(
                content: Text(
                    "You've already earned your share reward today!"),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
          return;
        }
      }

      final result = await Share.share(
        "🧠 Challenge your brain with OMath Puzzle! Can you beat my score? Download now!",
        subject: "OMath Puzzle Game",
      );

      if (result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed) {
        lastShareDate.value = now;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('SAVED_LAST_SHARE', now.toIso8601String());
        await _updateProfile({'last_share_date': now.toUtc().toIso8601String()});

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

  /// Helper: Upsert profile in Supabase
  Future<void> _updateProfile(Map<String, dynamic> data) async {
    final userId = effectiveUserId;
    if (userId.isEmpty) return;

    try {
      data['updated_at'] = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('profiles').upsert({
        'id': userId,
        'username': odUsername.value,
        'avatar_id': avatarId.value,
        'total_xp': totalXp.value,
        ...data,
      });
    } catch (e) {
      debugPrint('Update profile error: $e');
    }
  }

  /// Get avatar asset path
  String get avatarPath => SupabaseConfig.getAvatarPath(avatarId.value);
}
