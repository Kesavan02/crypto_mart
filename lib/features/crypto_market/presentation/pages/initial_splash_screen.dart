import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_update_gate.dart';
import 'main_navigation_page.dart';

/// A futuristic, highly-polished initial splash screen showcasing
/// the [bar_chart_loading_anim.json] Lottie animation along with
/// the centered CryptoMart emblem, ambient radar rings, floating particles,
/// and real-time terminal telemetry diagnostics.
///
/// Fully adaptive to both Light and Dark themes, seamlessly persisting
/// the user's appearance preferences across full application restarts.
class InitialSplashScreen extends StatefulWidget {
  const InitialSplashScreen({super.key});

  @override
  State<InitialSplashScreen> createState() => _InitialSplashScreenState();
}

class _InitialSplashScreenState extends State<InitialSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _loadingProgressController;
  late final AnimationController _ringRotationController;

  bool _hasNavigated = false;
  int _currentTelemetryIndex = 0;

  static const List<String> _telemetryMessages = [
    'Connecting to distributed nodes...',
    'Synchronizing live market orderbooks...',
    'Calibrating real-time chart engine...',
    'Market terminal ready • Initializing interface...',
  ];

  @override
  void initState() {
    super.initState();

    // Ambient breathing pulse for glow halos
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Continuous smooth rotation for high-tech ring accents
    _ringRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    // Main loading progress sequence (~3.0 seconds total)
    _loadingProgressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );

    _loadingProgressController.addListener(() {
      final progress = _loadingProgressController.value;
      final newIndex = (progress * _telemetryMessages.length)
          .floor()
          .clamp(0, _telemetryMessages.length - 1);
      if (newIndex != _currentTelemetryIndex) {
        setState(() {
          _currentTelemetryIndex = newIndex;
        });
      }
    });

    _loadingProgressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _proceedToMainScreen();
      }
    });

    _loadingProgressController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _loadingProgressController.dispose();
    _ringRotationController.dispose();
    super.dispose();
  }

  void _proceedToMainScreen() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 650),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const AppUpdateGate(
          child: MainNavigationPage(),
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.96, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF070A12) : AppColors.backgroundLight;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _proceedToMainScreen,
        child: Stack(
          children: [
            // ── 1. Cyber Ambient Background & Glowing Orbs ───────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _CyberBackgroundPainter(
                      pulseValue: _pulseController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // ── 2. Floating Digital Particle Dust ────────────────────────────
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _FloatingParticlesPainter(
                      progress: _pulseController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),
            ),

            // ── 3. Foreground Content ────────────────────────────────────────
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 12),

                        // ── Top Brand Emblem with Orbital Halo ──────────────
                        _buildHeroLogo(isDark),

                        const SizedBox(height: 20),

                        // ── Title & Futuristic Badge ─────────────────────────
                        _buildBrandHeader(isDark),

                        const SizedBox(height: 28),

                        // ── Feature Card: Lottie Chart & Telemetry Pod ──────
                        _buildLottieTelemetryCard(isDark),

                        const SizedBox(height: 32),

                        // ── Animated Loading Progress Bar ────────────────────
                        _buildProgressSection(isDark),

                        const SizedBox(height: 24),

                        // ── Tap to Fast-Forward Prompt ───────────────────────
                        Text(
                          'Tap anywhere to skip',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.35)
                                : const Color(0xFF94A3B8),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the top hero logo badge with concentric pulsing glowing rings
  Widget _buildHeroLogo(bool isDark) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseController, _ringRotationController]),
      builder: (context, child) {
        final pulse = _pulseController.value;
        final rotation = _ringRotationController.value * 2 * math.pi;

        final dashedRingColor = isDark
            ? AppColors.accentCyanBright.withValues(alpha: 0.4 + 0.3 * pulse)
            : AppColors.primaryBlue.withValues(alpha: 0.45 + 0.3 * pulse);

        final innerBorderColor = isDark
            ? AppColors.accentCyanBright.withValues(alpha: 0.6)
            : AppColors.primaryBlue.withValues(alpha: 0.5);

        return SizedBox(
          width: 96,
          height: 96,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer rotating dashed cyber ring
              Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  size: const Size(96, 96),
                  painter: _DashedRingPainter(
                    color: dashedRingColor,
                  ),
                ),
              ),

              // Soft pulsing ambient glow
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isDark
                      ? [
                          BoxShadow(
                            color: AppColors.accentCyanBright.withValues(
                              alpha: 0.25 + 0.2 * pulse,
                            ),
                            blurRadius: 24 + (8 * pulse),
                            spreadRadius: 2 + (3 * pulse),
                          ),
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.3 + 0.2 * pulse,
                            ),
                            blurRadius: 36,
                            spreadRadius: 4,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.20 + 0.15 * pulse,
                            ),
                            blurRadius: 24 + (8 * pulse),
                            spreadRadius: 2 + (2 * pulse),
                          ),
                          BoxShadow(
                            color: AppColors.accentCyan.withValues(
                              alpha: 0.15 + 0.10 * pulse,
                            ),
                            blurRadius: 32,
                            spreadRadius: 3,
                          ),
                        ],
                ),
              ),

              // The updated circular CryptoMart emblem
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: innerBorderColor,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/crypto_mart_logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: isDark ? const Color(0xFF151924) : Colors.white,
                      child: Icon(
                        Icons.candlestick_chart_rounded,
                        color: isDark
                            ? AppColors.accentCyanBright
                            : AppColors.primaryBlue,
                        size: 34,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the brand headline and status pill badge
  Widget _buildBrandHeader(bool isDark) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: isDark
                  ? const [
                      Colors.white,
                      Color(0xFFE0F2FE),
                      AppColors.accentCyanBright,
                    ]
                  : const [
                      Color(0xFF0F172A),
                      Color(0xFF1E3A8A),
                      AppColors.primaryBlue,
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: const Text(
            'CRYPTO MART',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 3.0,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? AppColors.accentCyan.withValues(alpha: 0.3)
                  : AppColors.primaryBlue.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: const Color(0x0C0052FF),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.gainGreen,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gainGreen,
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'LIVE MARKET INTELLIGENCE',
                style: TextStyle(
                  color: isDark
                      ? AppColors.accentCyanBright
                      : AppColors.primaryBlue,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the central glassmorphic card hosting the Lottie animation
  Widget _buildLottieTelemetryCard(bool isDark) {
    final cardBg = isDark
        ? const Color(0xFF0F1523).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.94);

    final cardBorder = isDark
        ? Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.2)
        : Border.all(color: const Color(0xFFE2E8F0), width: 1.2);

    final cardShadows = isDark
        ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
            BoxShadow(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
              blurRadius: 32,
              spreadRadius: -4,
            ),
          ]
        : [
            BoxShadow(
              color: const Color(0x120052FF),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ];

    final highlightColors = isDark
        ? [
            Colors.transparent,
            AppColors.accentCyanBright.withValues(alpha: 0.7),
            Colors.transparent,
          ]
        : [
            Colors.transparent,
            AppColors.primaryBlue.withValues(alpha: 0.4),
            Colors.transparent,
          ];

    final headerTextColor = isDark
        ? Colors.white.withValues(alpha: 0.7)
        : const Color(0xFF334155);

    final headerIconColor = isDark
        ? AppColors.accentCyanBright.withValues(alpha: 0.8)
        : AppColors.primaryBlue;

    final badgeBg = isDark
        ? AppColors.primaryBlue.withValues(alpha: 0.2)
        : AppColors.primaryBlue.withValues(alpha: 0.08);

    final badgeBorder = isDark
        ? Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4))
        : Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.25));

    final badgeTextColor = isDark
        ? AppColors.accentCyanBright
        : AppColors.primaryBlue;

    final telemetryTextColor = isDark
        ? Colors.white.withValues(alpha: 0.75)
        : const Color(0xFF334155);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: cardBorder,
        boxShadow: cardShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Top highlight border
            Positioned(
              top: 0,
              left: 30,
              right: 30,
              height: 1,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: highlightColors,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Column(
                children: [
                  // Card Header: Telemetry indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.show_chart_rounded,
                            size: 16,
                            color: headerIconColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'CHART ENGINE',
                            style: TextStyle(
                              color: headerTextColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(10),
                          border: badgeBorder,
                        ),
                        child: Text(
                          '60 FPS • 12ms',
                          style: TextStyle(
                            color: badgeTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // The requested Lottie animation container
                  Container(
                    width: 170,
                    height: 150,
                    alignment: Alignment.center,
                    child: Lottie.asset(
                      'assets/anim/bar_chart_loading_anim.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: isDark
                                ? AppColors.accentCyanBright
                                : AppColors.primaryBlue,
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Real-time status text crossfade
                  SizedBox(
                    height: 22,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0.0, 0.4),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _telemetryMessages[_currentTelemetryIndex],
                        key: ValueKey<int>(_currentTelemetryIndex),
                        style: TextStyle(
                          color: telemetryTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the animated progress bar and numeric counter
  Widget _buildProgressSection(bool isDark) {
    return AnimatedBuilder(
      animation: _loadingProgressController,
      builder: (context, child) {
        final progress = _loadingProgressController.value;
        final percentage = (progress * 100).toInt();

        final labelColor = isDark
            ? Colors.white.withValues(alpha: 0.45)
            : const Color(0xFF64748B);

        final percentColor = isDark
            ? AppColors.accentCyanBright
            : AppColors.primaryBlue;

        final trackColor = isDark
            ? const Color(0xFF161F30)
            : const Color(0xFFE2E8F0);

        final trackBorder = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : const Color(0xFFCBD5E1);

        final activeGradient = isDark
            ? const LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.accentCyan,
                  AppColors.accentCyanBright,
                ],
              )
            : const LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.accentCyan,
                ],
              );

        final activeGlowColor = isDark
            ? AppColors.accentCyanBright.withValues(alpha: 0.7)
            : AppColors.primaryBlue.withValues(alpha: 0.35);

        return Column(
          children: [
            // Numerical percentage counter with modern monospace feel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SYNCHRONIZATION',
                  style: TextStyle(
                    color: labelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    color: percentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Futuristic glowing progress track
            Container(
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: trackColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: trackBorder,
                  width: 1,
                ),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final activeWidth = constraints.maxWidth * progress;

                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: activeWidth,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: activeGradient,
                        boxShadow: [
                          BoxShadow(
                            color: activeGlowColor,
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Custom painter rendering ambient neon cyber glows and subtle radar rings
class _CyberBackgroundPainter extends CustomPainter {
  final double pulseValue;
  final bool isDark;

  _CyberBackgroundPainter({
    required this.pulseValue,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.42);

    if (isDark) {
      // Dark Mode Cyber Glows
      final primaryGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.18 + (0.08 * pulseValue)),
            const Color(0xFF4F46E5).withValues(alpha: 0.10 + (0.04 * pulseValue)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.75),
        );

      canvas.drawCircle(center, size.width * 0.75, primaryGlow);

      final cyanGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accentCyanBright.withValues(alpha: 0.12 + (0.06 * pulseValue)),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.25),
            radius: size.width * 0.45,
          ),
        );

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.25),
        size.width * 0.45,
        cyanGlow,
      );

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int i = 1; i <= 3; i++) {
        final radius = (size.width * 0.28 * i) + (10 * pulseValue * (i % 2 == 0 ? 1 : -1));
        ringPaint.color = Colors.white.withValues(alpha: 0.025 + (0.015 * pulseValue));
        canvas.drawCircle(center, radius, ringPaint);
      }
    } else {
      // Light Mode Soft Luminous Glows
      final primaryGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primaryBlue.withValues(alpha: 0.08 + (0.03 * pulseValue)),
            AppColors.accentCyan.withValues(alpha: 0.05 + (0.02 * pulseValue)),
            Colors.transparent,
          ],
          stops: const [0.0, 0.50, 1.0],
        ).createShader(
          Rect.fromCircle(center: center, radius: size.width * 0.75),
        );

      canvas.drawCircle(center, size.width * 0.75, primaryGlow);

      final topAccentGlow = Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.accentCyan.withValues(alpha: 0.06 + (0.03 * pulseValue)),
            Colors.transparent,
          ],
        ).createShader(
          Rect.fromCircle(
            center: Offset(size.width * 0.5, size.height * 0.25),
            radius: size.width * 0.45,
          ),
        );

      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.25),
        size.width * 0.45,
        topAccentGlow,
      );

      final ringPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int i = 1; i <= 3; i++) {
        final radius = (size.width * 0.28 * i) + (10 * pulseValue * (i % 2 == 0 ? 1 : -1));
        ringPaint.color = AppColors.primaryBlue.withValues(alpha: 0.04 + (0.02 * pulseValue));
        canvas.drawCircle(center, radius, ringPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CyberBackgroundPainter oldDelegate) {
    return oldDelegate.pulseValue != pulseValue || oldDelegate.isDark != isDark;
  }
}

/// Custom painter for the rotating dashed ring surrounding the logo
class _DashedRingPainter extends CustomPainter {
  final Color color;

  _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const count = 12;
    const sweep = (2 * math.pi) / count;
    const dashLength = sweep * 0.55;

    for (int i = 0; i < count; i++) {
      final startAngle = i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

/// Custom painter for floating micro-particles simulating live network nodes
class _FloatingParticlesPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _FloatingParticlesPainter({
    required this.progress,
    required this.isDark,
  });

  // Deterministic particle coordinates
  static final List<_Particle> _particles = List.generate(24, (i) {
    final random = math.Random(i * 777);
    return _Particle(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 1.0 + random.nextDouble() * 2.0,
      baseAlpha: 0.15 + random.nextDouble() * 0.35,
      speed: 0.5 + random.nextDouble() * 1.5,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final p in _particles) {
      final currentY = (p.y - (progress * 0.08 * p.speed)) % 1.0;
      final alpha = (p.baseAlpha + (0.2 * math.sin(progress * 2 * math.pi * p.speed)))
          .clamp(0.05, 0.6);

      final color = isDark
          ? AppColors.accentCyanBright.withValues(alpha: alpha)
          : AppColors.primaryBlue.withValues(alpha: alpha * 0.65);

      paint.color = color;
      canvas.drawCircle(
        Offset(p.x * size.width, currentY * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FloatingParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double baseAlpha;
  final double speed;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.baseAlpha,
    required this.speed,
  });
}
