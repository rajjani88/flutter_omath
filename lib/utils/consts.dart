class AppConfig {
  // --- BRANDING ---
  static const String appName = "Mathwize";
  static const String appVersion = "1.0.0";

  // --- LINKS & SUPPORT ---
  static const String privacyPolicyUrl =
      'https://sites.google.com/view/brainy-math-app/privacy-policy';
  static const String termsUrl =
      "https://sites.google.com/view/brainy-math-app/terms-and-conditions";
  static const String rateUsUrl = "market://details?id=com.raj.omath";
  static const String rateUsWebUrl =
      "https://play.google.com/store/apps/details?id=com.raj.omath";
  static const String supportEmail = "support@example.com";

  // --- ASSETS ---
  static const String gameMusicPath = "assets/music/game_sound.mp3";
  static const String baseImgPath = 'assets/images';

  // --- ECONOMY ---
  static const int startingCoins = 100;
  static const int coinsPerWin = 20;
  static const int coinsFromAd = 100;
  static const int shareRewardCoins = 50;

  // --- POWER-UPS ---
  static const int costFreeze = 50;
  static const int costSkip = 100;
  static const int costHint = 30;
  static const int durationFreezeSeconds = 10;

  // --- GAMEPLAY CONSTANTS ---
  static const int dailyChallengeTargetLevel = 5;

  // --- ADS CONFIGURATION (AdMob) ---
  // Replace these with REAL IDs for production
  static const String admobAppIdAndroid =
      "ca-app-pub-3940256099942544~3347511713";
  static const String admobAppIdIos = "ca-app-pub-3940256099942544~1458002511";

  static const String bannerAdUnitIdAndroid =
      "ca-app-pub-3940256099942544/6300978111"; // Test ID
  static const String bannerAdUnitIdIos =
      "ca-app-pub-3940256099942544/2934735716"; // Test ID

  static const String rewardedAdUnitIdAndroid =
      "ca-app-pub-3940256099942544/5224354917"; // Test ID
  static const String rewardedAdUnitIdIos =
      "ca-app-pub-3940256099942544/1712485313"; // Test ID
  static const String imgLogo = "assets/images/logo.png";
  static const String imgLogoTr = "assets/images/logo_tr.png"; // Fixed path
  static const String imgNumber = "assets/images/number.png";
  static const String imgMathgrid = "assets/images/math_grid.png";
  static const String imgMathmaze = "assets/images/math_maze.png";
  static const String imgCalculator = "assets/images/calculator.png";
  static const String imgPro = "assets/images/pro.png";
  static const String imgTrueOrFalse = "assets/images/true_false_brain.png";
}

// Backward compatibility (Deprecated - use AppConfig)
const String appName = AppConfig.appName;
const gameMusic = AppConfig.gameMusicPath;
const urlPrivacy = AppConfig.privacyPolicyUrl;
const urlTerms = AppConfig.termsUrl;
const urlRateUs = AppConfig.rateUsUrl;
const urlRateUsWeb = AppConfig.rateUsWebUrl;

const int kStartingCoins = AppConfig.startingCoins;
const int kCoinsPerCorrectAnswer = AppConfig.coinsPerWin;
const int kCoinsFromAd = AppConfig.coinsFromAd;
const int kFreezeCost = AppConfig.costFreeze;
const int kSkipCost = AppConfig.costSkip;
const int kHintCost = AppConfig.costHint;
const int kFreezeDuration = AppConfig.durationFreezeSeconds;

// Restore missing global constants for backward compatibility
const baseImgPath = AppConfig.baseImgPath;
const imgLogo = AppConfig.imgLogo;
const imgLogoTr = AppConfig.imgLogoTr;
const imgNumber = AppConfig.imgNumber;
const imgMathgrid = AppConfig.imgMathgrid;
const imgMathmaze = AppConfig.imgMathmaze;
const imgcalculator = AppConfig.imgCalculator;
const imgPro = AppConfig.imgPro;
const imgTrueOrFalse = AppConfig.imgTrueOrFalse;
