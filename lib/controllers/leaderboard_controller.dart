import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_omath/controllers/user_controller.dart';


/// Leaderboard entry model
class LeaderboardEntry {
  final String odUsername;
  final int avatarId;
  final int totalXp;
  final int rank;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.odUsername,
    required this.avatarId,
    required this.totalXp,
    required this.rank,
    this.isCurrentUser = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, int rank,
      {bool isCurrentUser = false}) {
    return LeaderboardEntry(
      odUsername: json['username'] ?? 'Player',
      avatarId: json['avatar_id'] ?? 0,
      totalXp: json['total_xp'] ?? 0,
      rank: rank,
      isCurrentUser: isCurrentUser,
    );
  }
}

/// LeaderboardController: Fetches and displays top players
class LeaderboardController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final RxList<LeaderboardEntry> topPlayers = <LeaderboardEntry>[].obs;
  final Rx<LeaderboardEntry?> currentUserEntry = Rx<LeaderboardEntry?>(null);
  final RxInt currentUserRank = 0.obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaderboard();
  }

  /// Fetch Top 50 players by XP
  Future<void> fetchLeaderboard() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      // Fetch top 50
      final response = await _supabase
          .from('profiles')
          .select('username, avatar_id, total_xp, id')
          .order('total_xp', ascending: false)
          .limit(50);

      final currentUserId = Get.isRegistered<UserController>()
          ? Get.find<UserController>().effectiveUserId
          : _supabase.auth.currentUser?.id;

      topPlayers.clear();
      int rank = 0;
      bool currentUserInTop50 = false;

      for (var data in response) {
        rank++;
        final isCurrentUser = data['id'] == currentUserId;
        if (isCurrentUser) currentUserInTop50 = true;

        topPlayers.add(LeaderboardEntry.fromJson(
          data,
          rank,
          isCurrentUser: isCurrentUser,
        ));
      }

      // Fetch current user's rank if not in top 50
      if (!currentUserInTop50 && currentUserId != null && currentUserId.isNotEmpty) {
        await _fetchCurrentUserRank(currentUserId);
      } else if (currentUserInTop50) {
        currentUserEntry.value =
            topPlayers.firstWhereOrNull((e) => e.isCurrentUser);
        currentUserRank.value = currentUserEntry.value?.rank ?? 0;
      }

      // Fallback: If user entry is not found in cloud, show local profile badge
      if (currentUserEntry.value == null && Get.isRegistered<UserController>()) {
        final userCtrl = Get.find<UserController>();
        currentUserEntry.value = LeaderboardEntry(
          odUsername: userCtrl.odUsername.value,
          avatarId: userCtrl.avatarId.value,
          totalXp: userCtrl.totalXp.value,
          rank: currentUserRank.value > 0 ? currentUserRank.value : topPlayers.length + 1,
          isCurrentUser: true,
        );
      }

      isLoading.value = false;
    } catch (e) {
      debugPrint('Leaderboard fetch error: $e');
      hasError.value = true;
      isLoading.value = false;
    }
  }

  /// Fetch current user's exact rank
  Future<void> _fetchCurrentUserRank(String userId) async {
    try {
      // Get current user profile
      final userData = await _supabase
          .from('profiles')
          .select('username, avatar_id, total_xp')
          .eq('id', userId)
          .maybeSingle();

      int userXp = 0;
      if (userData != null) {
        userXp = (userData['total_xp'] as num?)?.toInt() ?? 0;
      } else if (Get.isRegistered<UserController>()) {
        userXp = Get.find<UserController>().totalXp.value;
      }

      // Count how many players have higher XP
      final countResponse =
          await _supabase.from('profiles').select('id').gt('total_xp', userXp);

      final rank = (countResponse as List).length + 1;

      currentUserRank.value = rank;
      if (userData != null) {
        currentUserEntry.value = LeaderboardEntry.fromJson(
          userData,
          rank,
          isCurrentUser: true,
        );
      } else if (Get.isRegistered<UserController>()) {
        final u = Get.find<UserController>();
        currentUserEntry.value = LeaderboardEntry(
          odUsername: u.odUsername.value,
          avatarId: u.avatarId.value,
          totalXp: userXp,
          rank: rank,
          isCurrentUser: true,
        );
      }
    } catch (e) {
      debugPrint('Fetch user rank error: $e');
    }
  }



  /// Refresh leaderboard
  Future<void> refresh() async {
    await fetchLeaderboard();
  }

  /// Check if current user is in top 50
  bool get isCurrentUserInTop50 => topPlayers.any((e) => e.isCurrentUser);
}
