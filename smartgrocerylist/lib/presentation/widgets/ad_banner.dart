import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  Timer? _retryTimer;

  // Real Ad Unit IDs — production ready
  String get _adUnitId {
    return Platform.isAndroid
        ? 'ca-app-pub-3362561286987631/4408118092'
        : 'ca-app-pub-3362561286987631/4408118092'; // Same for iOS for now
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd?.dispose();
    _bannerAd = null;

    if (mounted) {
      setState(() {
        _isLoaded = false;
      });
    }

    debugPrint('🔄 AdBanner: Loading ad (attempt ${_retryCount + 1})...');

    _bannerAd = BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ AdBanner: Ad loaded successfully!');
          _retryCount = 0;
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ AdBanner failed to load: ${err.message} (code: ${err.code})');
          ad.dispose();
          _bannerAd = null;

          // Retry with backoff
          if (_retryCount < _maxRetries) {
            _retryCount++;
            final delay = Duration(seconds: _retryCount * 15); // 15s, 30s, 45s, 60s, 75s
            debugPrint('🔄 AdBanner: Retrying in ${delay.inSeconds}s (attempt $_retryCount/$_maxRetries)...');
            _retryTimer?.cancel();
            _retryTimer = Timer(delay, () {
              if (mounted) _loadAd();
            });
          } else {
            debugPrint('⚠️ AdBanner: Max retries reached. Will try again later.');
            // Final retry after 5 minutes
            _retryTimer?.cancel();
            _retryTimer = Timer(const Duration(minutes: 5), () {
              if (mounted) {
                _retryCount = 0;
                _loadAd();
              }
            });
          }
        },
        onAdOpened: (ad) => debugPrint('📱 AdBanner: Ad opened.'),
        onAdClosed: (ad) => debugPrint('📱 AdBanner: Ad closed.'),
        onAdImpression: (ad) => debugPrint('📱 AdBanner: Ad impression recorded.'),
      ),
    )..load();
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
