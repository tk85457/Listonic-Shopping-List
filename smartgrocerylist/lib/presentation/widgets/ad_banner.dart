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
  Timer? _refreshTimer;

  // Real Ad Unit IDs — production ready
  static const String _primaryAdUnitId = 'ca-app-pub-3362561286987631/7469470052';
  static const String _backupAdUnitId = 'ca-app-pub-3362561286987631/7469470052';

  bool _useBackupAdUnit = false;

  String get _adUnitId {
    if (Platform.isAndroid) {
      return _useBackupAdUnit ? _backupAdUnitId : _primaryAdUnitId;
    } else {
      return _useBackupAdUnit ? _backupAdUnitId : _primaryAdUnitId; // Same for iOS for now
    }
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
    
    // AdMob Policy strictly requires refresh rate to be at least 30-60 seconds.
    // Setting it to 30 seconds (minimum safe limit) to prevent instant account ban.
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isLoaded) {
        debugPrint('📢 AdBanner: Auto-refreshing banner ad...');
        _loadAd();
      }
    });
  }

  void _loadAd() {
    _bannerAd?.dispose();
    _bannerAd = null;

    if (mounted) {
      setState(() {
        _isLoaded = false;
      });
    }

    final currentUnitId = _adUnitId;
    debugPrint('📢 AdBanner: Attempting to load ad with unit ID: $currentUnitId');

    _bannerAd = BannerAd(
      adUnitId: currentUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ AdBanner: Ad loaded successfully.');
          _retryCount = 0;
          if (mounted) {
            setState(() {
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ AdBanner: Failed to load: ${err.message} (Code: ${err.code})');
          ad.dispose();
          _bannerAd = null;

          // If the primary ad unit failed, immediately switch to the backup ad unit and try loading it.
          if (!_useBackupAdUnit) {
            debugPrint('⚠️ AdBanner: Primary ad unit failed. Switching to backup ad unit.');
            if (mounted) {
              setState(() {
                _useBackupAdUnit = true;
              });
              _loadAd();
            }
            return;
          }

          // If we are already on backup ad unit and it failed too, fall back to the retry timer with backoff.
          // Reset backup ad unit choice for the next cycle of retries.
          _useBackupAdUnit = false;

          // Retry with backoff
          if (_retryCount < _maxRetries) {
            _retryCount++;
            final delay = Duration(seconds: _retryCount * 15);
            _retryTimer?.cancel();
            _retryTimer = Timer(delay, () {
              if (mounted) _loadAd();
            });
          } else {
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
      ),
    )..load();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
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
