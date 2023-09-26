import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdmobOperations {
  static const AdManagerAdRequest request = AdManagerAdRequest(
    keywords: <String>['flutter', 'chatApp'],
    nonPersonalizedAds: true,
  );

  static int showAdCount = 0;

  static const testID = "ca-app-pub-3940256099942544/6300978111";

  static const banner1ID = "ca-app-pub-8071507614554563/7718115401";

  static admobInitialize() {
    MobileAds.instance.initialize();
  }

  static AdManagerBannerAd buildBannerAd() {
    return AdManagerBannerAd(
      sizes: [AdSize.banner],
      adUnitId: "/6499/example/banner",
      request: request,
      listener: AdManagerBannerAdListener(
        onAdLoaded: (ad) {
        },
      ),
    );
  }

  static interstitialAd() {
    if (showAdCount < 3) {
      return AdManagerInterstitialAd.load(
        adUnitId: "/6499/example/interstitial",
        request: request,
        adLoadCallback: AdManagerInterstitialAdLoadCallback(
          onAdLoaded: (AdManagerInterstitialAd ad) {
            ad.show();
            showAdCount++;
          },
          onAdFailedToLoad: (LoadAdError error) {},
        ),
      );
    }
  }

  static rewardedAd() {
    return RewardedInterstitialAd.loadWithAdManagerAdRequest(
      adUnitId: '/21775744923/example/rewarded_interstitial',
      adManagerRequest: request,
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem rewardItem) {
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
        },
      ),
    );
  }
}
