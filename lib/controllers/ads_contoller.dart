import 'package:flutter_omath/utils/sharedprefs.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_omath/controllers/sound_controller.dart';
import 'package:flutter_omath/utils/ads_const.dart';

class AdsController extends GetxController implements GetxService {
  // Ad instances
  BannerAd? bannerAd;
  InterstitialAd? interstitialAd;
  RewardedAd? rewardedAd;

  // State variables
  var isBannerAdLoaded = false.obs;
  var isInterstitialAdLoaded = false.obs;
  var isRewardedAdLoaded = false.obs;

  // Counters
  var totalAdsShown = 0.obs;
  var coinsEarnedFromAds = 0.obs;
  var levelsCompleted = 0.obs;


  BannerAd? bannerAd1;
  BannerAd? bannerAd2;
  BannerAd? bannerAd3;

  // State variables for each banner ad
  var isBannerAd1Loaded = false.obs;
  var isBannerAd2Loaded = false.obs;
  var isBannerAd3Loaded = false.obs;
  var isBannerAd4Loaded = false.obs;

  final Sharedprefs sp;

  AdsController({required this.sp});

  @override
  void onInit() {
    super.onInit();
    _loadBannerAd1();
    _loadBannerAd2();
    _loadBannerAd3();
    _loadBannerAd4();
    _loadBannerAd();
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  // Load Banner Ad
  void _loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: AdConstants.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAdLoaded.value = true;
          totalAdsShown.value++;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAdLoaded.value = false;
          ad.dispose();
          print("Banner Ad failed to load: $error");
        },
      ),
    )..load();
  }

  // Load Banner Ad 1
  void _loadBannerAd1() {
    bannerAd1 = BannerAd(
      adUnitId: AdConstants.bannerNumberGrid,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAd1Loaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAd1Loaded.value = false;
          ad.dispose();
          print("Banner Ad 1 failed to load: $error");
        },
      ),
    )..load();
  }

  // Load Banner Ad 2
  void _loadBannerAd2() {
    bannerAd2 = BannerAd(
      adUnitId: AdConstants.miniSudokuBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAd2Loaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAd2Loaded.value = false;
          ad.dispose();
          print("Banner Ad 2 failed to load: $error");
        },
      ),
    )..load();
  }

  // Load Banner Ad 3
  void _loadBannerAd3() {
    bannerAd3 = BannerAd(
      adUnitId: AdConstants.trueFalseBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAd3Loaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAd3Loaded.value = false;
          ad.dispose();
          print("Banner Ad 3 failed to load: $error");
        },
      ),
    )..load();
  }

// Load Interstitial Ad
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          isInterstitialAdLoaded.value = true;

          // Handle Ad events
          interstitialAd?.setImmersiveMode(true);
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              Get.find<SoundController>().resumeAudioAfterAd(); // Resume audio
              interstitialAd?.dispose();
              _loadInterstitialAd(); // Preload next interstitial ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              Get.find<SoundController>()
                  .resumeAudioAfterAd(); // Resume if failed
              ad.dispose();
              _loadInterstitialAd(); // Preload next interstitial ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          isInterstitialAdLoaded.value = false;
          print("Interstitial Ad failed to load: $error");
        },
      ),
    );
  }

  // Load Rewarded Ad
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          rewardedAd = ad;
          isRewardedAdLoaded.value = true;

          // Handle Ad events
          rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (_) {
              Get.find<SoundController>().resumeAudioAfterAd(); // Resume audio
              rewardedAd?.dispose();
              _loadRewardedAd(); // Preload next rewarded ad
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              Get.find<SoundController>()
                  .resumeAudioAfterAd(); // Resume if failed
              ad.dispose();
              _loadRewardedAd(); // Preload next rewarded ad
            },
          );
        },
        onAdFailedToLoad: (error) {
          isRewardedAdLoaded.value = false;
          print("Rewarded Ad failed to load: $error");
        },
      ),
    );
  }

  // Show Interstitial Ad
  void showInterstitialAd() {
    if (sp.userType) {
      return;
    }
    if (isInterstitialAdLoaded.value) {
      Get.find<SoundController>().stopAudioForAd(); // Stop audio before show
      interstitialAd?.show();
      isInterstitialAdLoaded.value = false;
      totalAdsShown.value++;
    } else {
      print("Interstitial Ad not loaded yet.");
    }
  }

  // Show Rewarded Ad
  void showRewardedAd({Function()? onRewardGranted}) {
    if (sp.userType) {
      return;
    }
    if (isRewardedAdLoaded.value) {
      Get.find<SoundController>().stopAudioForAd(); // Stop audio before show
      rewardedAd?.show(
        onUserEarnedReward: (ad, reward) {
          coinsEarnedFromAds.value += reward.amount.toInt();
          print("User earned ${reward.amount} coins!");
          onRewardGranted!();
        },
      );
      isRewardedAdLoaded.value = false;
      totalAdsShown.value++;
    } else {
      print("Rewarded Ad not loaded yet.");
    }
  }

  /// Trigger every 2 level completions
  void onLevelCompleted() {
    levelsCompleted.value++;
    if (levelsCompleted.value >= 2) {
      levelsCompleted.value = 0;
      showInterstitialAd();
    }
  }

  // Dispose resources
  @override
  void onClose() {
    bannerAd?.dispose();
    interstitialAd?.dispose();
    rewardedAd?.dispose();

    bannerAd1?.dispose();
    bannerAd2?.dispose();
    bannerAd3?.dispose();
    bannerAd4?.dispose();
    super.onClose();
  }

  BannerAd? bannerAd4;

  void _loadBannerAd4() {
    bannerAd4 = BannerAd(
      adUnitId: AdConstants.arrangeItBanner,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          isBannerAd4Loaded.value = true;
        },
        onAdFailedToLoad: (ad, error) {
          isBannerAd4Loaded.value = false;
          ad.dispose();
          print("Banner Ad 4 failed to load: $error");
        },
      ),
    )..load();
  }
}
