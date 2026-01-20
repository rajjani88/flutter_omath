/// Supabase Configuration
/// Replace with your actual Supabase credentials

class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'https://wmxtrrmszbccxgwqsucq.supabase.co';

  // TODO: Replace with your Supabase anon key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndteHRycm1zemJjY3hnd3FzdWNxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njg2MzkzNzcsImV4cCI6MjA4NDIxNTM3N30.e2unzDnkYnY0o6TpEty3FHVXzv5nXXP3ZjiGVhPJhSw';

  // Avatar asset paths (based on avatar_id 0-4)
  static String getAvatarPath(int avatarId) {
    // Clamp to valid range (0-25)
    final id = avatarId.clamp(0, 25);
    return 'assets/avatars/$id.png';
  }

  // Daily Reward amounts based on streak day
  static int getDailyReward(int streakDay) {
    switch (streakDay) {
      case 1:
        return 10;
      case 2:
        return 15;
      case 3:
        return 20;
      case 4:
        return 25;
      case 5:
        return 30;
      case 6:
        return 40;
      case 7:
        return 100; // Big Day 7 reward!
      default:
        return 50; // After week, consistent bonus
    }
  }

  // Share reward (once per day)
  static const int shareRewardCoins = 50;

  // XP rewards
  static const int xpPerCorrectAnswer = 10;
}
