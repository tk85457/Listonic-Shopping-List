import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A persistent, zero-flicker banner ad widget that:
/// - Uses adaptive sizing based on screen width
/// - Checks network before loading
/// - Observes app lifecycle (pauses retry when backgrounded)
/// - Never overlaps any UI element (returns SizedBox.shrink when no ad)
/// - Retries with exponential backoff on failure
class AdBanner extends StatefulWidget {
  final String? adUnitId;
  const AdBanner({super.key, this.adUnitId});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> with WidgetsBindingObserver {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isLoadingAd = false;
  Timer? _retryTimer;
  AdSize? _resolvedSize;
  int _retryCount = 0;
  static const int _maxRetries = 5;

  // ── Real Production Ad Unit ID ──
  static const String _defaultBannerId =
      'ca-app-pub-3362561286987631/7469470052';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay load slightly so MediaQuery is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAd();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _retryTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      if (!_isAdLoaded || _bannerAd == null) {
        _loadAd();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _retryTimer?.cancel();
    try {
      _bannerAd?.dispose();
    } catch (e) {
      debugPrint('AdBanner dispose error: $e');
    }
    _bannerAd = null;
    super.dispose();
  }

  Future<void> _loadAd() async {
    if (kIsWeb) return;
    if (_isLoadingAd) return;
    _isLoadingAd = true;
    _retryTimer?.cancel();

    // ── Resolve adaptive ad size based on screen width ──
    if (_resolvedSize == null && mounted) {
      final screenWidth = MediaQuery.of(context).size.width.truncate();
      final adaptive =
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
              screenWidth);
      _resolvedSize = adaptive ?? AdSize.banner;
    }

    if (!mounted) {
      _isLoadingAd = false;
      return;
    }

    // ── Network connectivity check ──
    try {
      final lookup = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (lookup.isEmpty || lookup[0].rawAddress.isEmpty) {
        _isLoadingAd = false;
        _scheduleRetry();
        return;
      }
    } catch (_) {
      _isLoadingAd = false;
      _scheduleRetry();
      return;
    }

    if (!mounted) {
      _isLoadingAd = false;
      return;
    }

    final unitId = widget.adUnitId ?? _defaultBannerId;
    final size = _resolvedSize ?? AdSize.banner;

    BannerAd(
      adUnitId: unitId,
      request: const AdRequest(),
      size: size,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          final old = _bannerAd;
          setState(() {
            _bannerAd = ad as BannerAd;
            _isAdLoaded = true;
            _isLoadingAd = false;
            _retryCount = 0;
          });
          old?.dispose();
          _retryTimer?.cancel();
          _retryTimer = null;
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('❌ AdBanner failed: ${err.message} (Code: ${err.code})');
          ad.dispose();
          if (!mounted) return;
          _isLoadingAd = false;
          // If we already have a loaded banner, keep showing it
          if (_bannerAd != null && _isAdLoaded) return;
          setState(() {
            _isAdLoaded = false;
            _bannerAd = null;
          });
          _scheduleRetry();
        },
        onAdOpened: (ad) => debugPrint('📢 AdBanner: Ad opened.'),
        onAdClosed: (ad) => debugPrint('📢 AdBanner: Ad closed.'),
        onAdImpression: (ad) =>
            debugPrint('📢 AdBanner: Ad impression recorded.'),
        onAdClicked: (ad) => debugPrint('📢 AdBanner: Ad clicked.'),
      ),
    ).load();
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    if (_isAdLoaded && _bannerAd != null) return;
    if (_retryCount >= _maxRetries) {
      // After max retries, wait 5 minutes and reset
      _retryTimer = Timer(const Duration(minutes: 5), () {
        if (mounted) {
          _retryCount = 0;
          _loadAd();
        }
      });
      return;
    }
    _retryCount++;
    final delay = Duration(seconds: _retryCount * 10);
    _retryTimer = Timer(delay, () {
      if (mounted && !_isAdLoaded) {
        _loadAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink(); // Zero space when no ad — NO UI overlap
    }
    return SafeArea(
      top: false,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        width: double.infinity,
        height: _bannerAd!.size.height.toDouble(),
        alignment: Alignment.center,
        child: AdWidget(
          key: ValueKey(_bannerAd.hashCode),
          ad: _bannerAd!,
        ),
      ),
    );
  }
}
