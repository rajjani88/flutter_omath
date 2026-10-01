import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

      final currentUserId = _supabase.auth.currentUser?.id;

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
      if (!currentUserInTop50 && currentUserId != null) {
        await _fetchCurrentUserRank(currentUserId);
      } else if (currentUserInTop50) {
        currentUserEntry.value =
            topPlayers.firstWhereOrNull((e) => e.isCurrentUser);
        currentUserRank.value = currentUserEntry.value?.rank ?? 0;
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
          .single();

      final userXp = userData['total_xp'] ?? 0;

      // Count how many players have higher XP
      final countResponse =
          await _supabase.from('profiles').select('id').gt('total_xp', userXp);

      final rank = (countResponse as List).length + 1;

      currentUserRank.value = rank;
      currentUserEntry.value = LeaderboardEntry.fromJson(
        userData,
        rank,
        isCurrentUser: true,
      );
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
