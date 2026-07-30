import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoading = false;
  int _interstitialLoadAttempts = 0;
  static const int _maxFailedAttempts = 3;

  // Interstitial Ad Unit ID
  static const String _interstitialAdUnitId = 'ca-app-pub-3362561286987631/5117468025';

  /// Preloads the Interstitial Ad in the background
  void loadInterstitialAd() {
    if (_interstitialAd != null || _isInterstitialAdLoading) return;

    _isInterstitialAdLoading = true;
    debugPrint('📢 AdService: Loading Interstitial Ad...');

    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          debugPrint('✅ AdService: Interstitial Ad loaded successfully.');
          _interstitialAd = ad;
          _isInterstitialAdLoading = false;
          _interstitialLoadAttempts = 0;

          // Set up ad lifecycle callbacks
          _setAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('❌ AdService: Interstitial Ad failed to load: ${error.message}');
          _interstitialAd = null;
          _isInterstitialAdLoading = false;
          _interstitialLoadAttempts++;

          if (_interstitialLoadAttempts <= _maxFailedAttempts) {
            // Retry loading after a short delay
            Future.delayed(const Duration(seconds: 15), () {
              loadInterstitialAd();
            });
          }
        },
      ),
    );
  }

  void _setAdCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📢 AdService: Interstitial Ad showed full screen.');
      },
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        debugPrint('📢 AdService: Interstitial Ad dismissed.');
        ad.dispose();
        _interstitialAd = null;
        // Reload a new ad for next time
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        debugPrint('❌ AdService: Interstitial Ad failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        // Reload a new ad for next time
        loadInterstitialAd();
      },
    );
  }

  /// Shows the Interstitial Ad if ready, then executes the callback.
  /// If the ad is not loaded, it immediately executes the callback.
  void showInterstitialAd({required VoidCallback onComplete}) {
    if (_interstitialAd != null) {
      debugPrint('📢 AdService: Showing Interstitial Ad...');
      
      // Override the callback to include execution of onComplete when ad is dismissed or fails to show
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (InterstitialAd ad) {
          debugPrint('📢 AdService: Interstitial Ad dismissed by user.');
          ad.dispose();
          _interstitialAd = null;
          onComplete();
          loadInterstitialAd(); // Load next ad
        },
        onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
          debugPrint('❌ AdService: Interstitial Ad failed to show: ${error.message}');
          ad.dispose();
          _interstitialAd = null;
          onComplete();
          loadInterstitialAd(); // Load next ad
        },
      );

      _interstitialAd!.show();
    } else {
      debugPrint('⚠️ AdService: Interstitial Ad not ready, skipping to action.');
      onComplete();
      // Try loading one for next time
      loadInterstitialAd();
    }
  }
}
