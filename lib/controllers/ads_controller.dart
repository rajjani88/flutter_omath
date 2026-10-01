import 'package:flutter/foundation.dart';
import 'package:flutter_omath/utils/ads_const.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsController extends GetxController {
  RewardedAd? _rewardedAd;
  final RxBool isRewardedAdLoaded = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRewardedAd();
  }

  /// Loads a rewarded ad.
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          _rewardedAd = ad;
          isRewardedAdLoaded.value = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('RewardedAd failed to load: $error');
          _rewardedAd = null;
          isRewardedAdLoaded.value = false;
          // Retry loading after a delay or let it fail gracefully
          Future.delayed(const Duration(seconds: 10), () => loadRewardedAd());
        },
      ),
    );
  }

  /// Shows the rewarded ad if it's loaded. Executes [onRewardGranted] upon success.
  void showRewardedAd({required VoidCallback onRewardGranted}) {
    if (_rewardedAd == null || !isRewardedAdLoaded.value) {
      debugPrint('Warning: attempt to show rewarded ad before loaded.');
      // If ad isn't loaded, we can gracefully fail or provide the reward anyway.
      // For now, let's just trigger the callback so they aren't stuck if ads fail.
      onRewardGranted();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) =>
          debugPrint('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        _rewardedAd = null;
        isRewardedAdLoaded.value = false;
        loadRewardedAd(); // Reload for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        _rewardedAd = null;
        isRewardedAdLoaded.value = false;
        loadRewardedAd();
        // Fallback: grant reward anyway if ad fails to show
        onRewardGranted();
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
      debugPrint('$ad with reward $RewardItem(${reward.amount}, ${reward.type})');
      onRewardGranted();
    });
  }
}
