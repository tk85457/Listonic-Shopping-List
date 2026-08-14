import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdBanner extends StatefulWidget {
  final String? customAdUnitId;
  final String? customBackupAdUnitId;
  final AdSize adSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;

  const AdBanner({
    super.key,
    this.customAdUnitId,
    this.customBackupAdUnitId,
    this.adSize = AdSize.banner,
    this.margin,
    this.padding,
    this.backgroundColor,
  });

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
  static const String _defaultPrimaryAdUnitId =
      'ca-app-pub-3362561286987631/7469470052';
  static const String _defaultBackupAdUnitId =
      'ca-app-pub-3362561286987631/7469470052';

  bool _useBackupAdUnit = false;

  String get _primaryId => widget.customAdUnitId ?? _defaultPrimaryAdUnitId;
  String get _backupId =>
      widget.customBackupAdUnitId ?? widget.customAdUnitId ?? _defaultBackupAdUnitId;

  String get _adUnitId {
    if (Platform.isAndroid || Platform.isIOS) {
      return _useBackupAdUnit ? _backupId : _primaryId;
    }
    return _useBackupAdUnit ? _backupId : _primaryId;
  }

  @override
  void initState() {
    super.initState();
    _loadAd();

    // Auto-refresh banner ad every 30 seconds (minimum safe limit per AdMob policy)
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _isLoaded) {
        debugPrint('📢 AdBanner: Auto-refreshing banner ad...');
        _loadAd();
      }
    });
  }

  void _loadAd() {
    if (kIsWeb) return;

    try {
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
        size: widget.adSize,
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
            debugPrint(
              '❌ AdBanner: Failed to load: ${err.message} (Code: ${err.code})',
            );
            try {
              ad.dispose();
            } catch (e) {
              debugPrint('AdBanner: Error disposing failed ad: $e');
            }
            _bannerAd = null;
            if (mounted) {
              setState(() {
                _isLoaded = false;
              });
            }

            // If primary failed, switch to backup ad unit immediately
            if (!_useBackupAdUnit) {
              debugPrint(
                '⚠️ AdBanner: Primary ad unit failed. Switching to backup ad unit.',
              );
              if (mounted) {
                setState(() {
                  _useBackupAdUnit = true;
                });
                _loadAd();
              }
              return;
            }

            _useBackupAdUnit = false;

            // Retry with exponential backoff
            if (_retryCount < _maxRetries) {
              _retryCount++;
              final delay = Duration(seconds: _retryCount * 15);
              _retryTimer?.cancel();
              _retryTimer = Timer(delay, () {
                if (mounted) _loadAd();
              });
            } else {
              _retryTimer?.cancel();
              _retryTimer = Timer(const Duration(minutes: 5), () {
                if (mounted) {
                  _retryCount = 0;
                  _loadAd();
                }
              });
            }
          },
          onAdOpened: (ad) => debugPrint('📢 AdBanner: Ad opened.'),
          onAdClosed: (ad) => debugPrint('📢 AdBanner: Ad closed.'),
          onAdImpression: (ad) =>
              debugPrint('📢 AdBanner: Ad impression recorded.'),
          onAdClicked: (ad) => debugPrint('📢 AdBanner: Ad clicked.'),
        ),
      )..load();
    } catch (e) {
      debugPrint('❌ AdBanner load exception: $e');
      if (mounted) {
        setState(() {
          _isLoaded = false;
          _bannerAd = null;
        });
      }
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _retryTimer?.cancel();
    try {
      _bannerAd?.dispose();
    } catch (e) {
      debugPrint('AdBanner dispose error: $e');
    }
    _bannerAd = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoaded && _bannerAd != null) {
      return Container(
        margin: widget.margin,
        padding: widget.padding,
        color:
            widget.backgroundColor ??
            Theme.of(context).scaffoldBackgroundColor,
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    return const SizedBox.shrink();
  }
}
