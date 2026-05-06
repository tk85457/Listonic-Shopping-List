import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:grocerylist/controllers/auth_controller.dart';
import 'package:grocerylist/core/network/ai_service.dart';
import 'package:grocerylist/core/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();

  // Saved theme color — loaded from SharedPreferences before first frame
  Color _themeColor = const Color(0xFF7C4DFF); // default Deep Purple

  late AnimationController _logoCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;

  late AnimationController _glowCtrl;
  late Animation<double> _glowRadius;

  late AnimationController _waveCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _spinCtrl;

  late AnimationController _ringCtrl;
  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;

  static const int _dotCount = 4;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeOut),
      ),
    );

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _glowRadius = Tween<double>(
      begin: 18,
      end: 50,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _ringScale = Tween<double>(
      begin: 1.0,
      end: 1.55,
    ).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut));
    _ringOpacity = Tween<double>(
      begin: 0.45,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _ringCtrl, curve: Curves.easeIn));

    _boot();
  }

  Future<void> _boot() async {
    // ── Load saved theme color BEFORE showing any UI ──────────────────
    // This runs before AIService so the color is ready at first paint
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorName = prefs.getString('theme_color') ?? 'Deep Purple';
      final savedColor = AppTheme.getThemeColor(colorName);
      if (mounted) setState(() => _themeColor = savedColor);
    } catch (_) {}

    await AIService.initializeMLModel();
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2800));
    if (mounted) Get.offAllNamed('/auth-check');
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _glowCtrl.dispose();
    _waveCtrl.dispose();
    _particleCtrl.dispose();
    _spinCtrl.dispose();
    _ringCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use locally loaded color — NOT Theme.of(context).colorScheme.primary
    // because ThemeController may not be fully loaded yet at splash time
    final primary = _themeColor;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: const [0.0, 0.45, 1.0],
            colors: [
              const Color(0xFF0A0E1A),
              Color.lerp(const Color(0xFF0A0E1A), primary, 0.22)!,
              const Color(0xFF060810),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Star field ─────────────────────────────────────────
            ..._buildStars(size),

            // ── Nebula glow blob (top-right) ───────────────────────
            Positioned(
              top: -size.height * 0.12,
              right: -size.width * 0.20,
              child: AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: size.width * 0.85,
                  height: size.width * 0.85,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        primary.withValues(
                          alpha: 0.10 + 0.06 * _glowCtrl.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Nebula glow blob (bottom-left) ─────────────────────
            Positioned(
              bottom: -size.height * 0.15,
              left: -size.width * 0.25,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: size.width * 0.75,
                height: size.width * 0.75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      primary.withValues(alpha: 0.07),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // ── Decorative orbit rings ──────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _OrbitPainter(primary)),
            ),

            // ── Floating particles ─────────────────────────────────
            ..._buildParticles(size, primary),

            // ── Main content ───────────────────────────────────────
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoCtrl,
                      _glowCtrl,
                      _spinCtrl,
                      _ringCtrl,
                    ]),
                    builder: (_, _) {
                      return FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: SizedBox(
                            width: 180,
                            height: 180,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Ripple ring
                                Transform.scale(
                                  scale: _ringScale.value,
                                  child: Container(
                                    width: 132,
                                    height: 132,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: primary.withValues(
                                          alpha: _ringOpacity.value,
                                        ),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                // Outer glow halo
                                Container(
                                  width: 148,
                                  height: 148,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: primary.withValues(
                                          alpha: 0.28 + 0.14 * _glowCtrl.value,
                                        ),
                                        blurRadius: _glowRadius.value,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),

                                // Spinning hexagon frame
                                Transform.rotate(
                                  angle: _spinCtrl.value * 2 * math.pi,
                                  child: CustomPaint(
                                    size: const Size(148, 148),
                                    painter: _HexFramePainter(primary),
                                  ),
                                ),

                                // Icon container — squircle
                                Container(
                                  width: 108,
                                  height: 108,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(36),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white,
                                        Color.lerp(
                                          Colors.white,
                                          primary,
                                          0.08,
                                        )!,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 32,
                                        offset: const Offset(0, 12),
                                      ),
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(36),
                                    child: Image.asset(
                                      'assets/icon/app_icon.png',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Icon(
                                        Icons.shopping_basket_rounded,
                                        size: 52,
                                        color: primary,
                                      ),
                                    ),
                                  ),
                                ),

                                // Corner accent dots
                                ..._cornerDots(primary),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 44),

                  Text(
                        'Listonic - Shopping List',
                        style: GoogleFonts.outfit(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 700.ms)
                      .slideY(begin: 0.2, curve: Curves.easeOut),

                  const SizedBox(height: 10),

                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _line(),
                      const SizedBox(width: 12),
                      Text(
                        'AI-POWERED LISTS',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.55),
                          letterSpacing: 3.5,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _line(),
                    ],
                  ).animate().fadeIn(delay: 900.ms, duration: 600.ms),
                ],
              ),
            ),

            // ── Wave dots loader ───────────────────────────────────
            Positioned(
              bottom: 56,
              left: 0,
              right: 0,
              child: Center(
                child: _WaveDotsLoader(
                  controller: _waveCtrl,
                  dotCount: _dotCount,
                  primary: primary,
                ),
              ).animate().fadeIn(delay: 1200.ms),
            ),
          ],
        ),
      ),
    );
  }

  Widget _line() => Container(
    width: 28,
    height: 1.5,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(1),
    ),
  );

  List<Widget> _cornerDots(Color primary) {
    const r = 70.0;
    final angles = [0.0, math.pi / 2, math.pi, 3 * math.pi / 2];
    return angles.map((a) {
      final dx = r * math.cos(a - math.pi / 2);
      final dy = r * math.sin(a - math.pi / 2);
      return Positioned(
        left: 90 + dx - 4,
        top: 90 + dy - 4,
        child: Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.75),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.5), blurRadius: 6),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildStars(Size size) {
    final rng = math.Random(7);
    return List.generate(60, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = 0.8 + rng.nextDouble() * 2.2;
      final alpha = 0.15 + rng.nextDouble() * 0.55;
      return Positioned(
        left: x,
        top: y,
        child: Container(
          width: s,
          height: s,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: alpha),
            shape: BoxShape.circle,
          ),
        ),
      );
    });
  }

  List<Widget> _buildParticles(Size size, Color primary) {
    final rng = math.Random(42);
    return List.generate(10, (i) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = 3.0 + rng.nextDouble() * 6;
      final delay = rng.nextDouble();
      final useColor = i % 3 == 0;

      return Positioned(
        left: x,
        top: y,
        child: AnimatedBuilder(
          animation: _particleCtrl,
          builder: (_, _) {
            final t = ((_particleCtrl.value + delay) % 1.0);
            final opacity = math.sin(t * math.pi) * 0.30;
            final dy = -40 * t;
            return Transform.translate(
              offset: Offset(0, dy),
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  width: s,
                  height: s,
                  decoration: BoxDecoration(
                    color: useColor
                        ? primary.withValues(alpha: 0.9)
                        : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: useColor
                        ? [
                            BoxShadow(
                              color: primary.withValues(alpha: 0.6),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HexFramePainter extends CustomPainter {
  final Color primary;
  _HexFramePainter(this.primary);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 2;

    final dashPaint = Paint()
      ..color = primary.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 6; i++) {
      final a1 = (i * math.pi / 3) - math.pi / 6;
      final a2 = ((i + 0.7) * math.pi / 3) - math.pi / 6;
      final seg = Path();
      seg.moveTo(cx + r * math.cos(a1), cy + r * math.sin(a1));
      seg.lineTo(cx + r * math.cos(a2), cy + r * math.sin(a2));
      canvas.drawPath(seg, dashPaint);
    }

    final dotPaint = Paint()
      ..color = primary.withValues(alpha: 0.80)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      final angle = (i * math.pi / 3) - math.pi / 6;
      canvas.drawCircle(
        Offset(cx + r * math.cos(angle), cy + r * math.sin(angle)),
        3.2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_HexFramePainter old) => old.primary != primary;
}

// ─────────────────────────────────────────────────────────────────────────────
class _OrbitPainter extends CustomPainter {
  final Color primary;
  _OrbitPainter(this.primary);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    paint.color = Colors.white.withValues(alpha: 0.04);
    canvas.drawCircle(Offset(size.width + 50, -80), 260, paint);
    canvas.drawCircle(Offset(-70, size.height + 80), 220, paint);

    paint.color = primary.withValues(alpha: 0.07);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 90, paint);

    paint.color = Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 55, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
class _WaveDotsLoader extends StatelessWidget {
  final AnimationController controller;
  final int dotCount;
  final Color primary;

  const _WaveDotsLoader({
    required this.controller,
    required this.dotCount,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(dotCount, (i) {
            final phase = (controller.value - (i / dotCount)) % 1.0;
            final t = math.sin(phase * 2 * math.pi);
            final dy = -10.0 * ((t + 1) / 2);
            final opacity = 0.4 + 0.6 * ((t + 1) / 2);
            final color = i % 2 == 0 ? Colors.white : primary;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.translate(
                offset: Offset(0, dy),
                child: Opacity(
                  opacity: opacity.clamp(0.0, 1.0),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
