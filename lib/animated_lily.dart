import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// ==================== ANIMATED LILY ====================

/// Color schemes for the three lily varieties.
enum LilyVariant {
  /// Stargazer — white tips, hot-pink throat, dark speckles.
  stargazer,

  /// Casa Blanca — pure white with a soft green-gold throat.
  casaBlanca,

  /// Golden — warm amber petals with burnt-orange speckles.
  golden,
}

class _LilyColors {
  const _LilyColors({
    required this.base,
    required this.mid,
    required this.tip,
    required this.speckle,
    required this.edge,
  });

  final Color base;
  final Color mid;
  final Color tip;
  final Color speckle;
  final Color edge;

  static const stargazer = _LilyColors(
    base: Color(0xFFC2185B),
    mid: Color(0xFFF06292),
    tip: Color(0xFFFFF7FA),
    speckle: Color(0xFF880E4F),
    edge: Color(0xFFFCE4EC),
  );

  static const casaBlanca = _LilyColors(
    base: Color(0xFFE6EFC8),
    mid: Color(0xFFFDFEF9),
    tip: Color(0xFFFFFFFF),
    speckle: Color(0xFFB39B4D),
    edge: Color(0xFFF7F7EF),
  );

  static const golden = _LilyColors(
    base: Color(0xFFEF6C00),
    mid: Color(0xFFFFB300),
    tip: Color(0xFFFFE082),
    speckle: Color(0xFFE65100),
    edge: Color(0xFFFFF3E0),
  );
}

/// A looping animated lily that blooms from a closed bud, holds open,
/// then folds back — with a gentle sway, curving stamens and drifting
/// pollen.
class AnimatedLily extends StatefulWidget {
  const AnimatedLily({
    super.key,
    this.size = 280,
    this.duration = const Duration(seconds: 9),
    this.variant = LilyVariant.stargazer,
    this.showPollen = true,
    this.seed = 11,
  });

  /// Width and height of the square the flower is painted in.
  final double size;

  /// Length of one full bloom → hold → close loop.
  final Duration duration;

  /// Which variety of lily to paint.
  final LilyVariant variant;

  /// Whether glowing pollen specks drift around the flower.
  final bool showPollen;

  /// Seed for the pollen layout, so different flowers look different.
  final int seed;

  @override
  State<AnimatedLily> createState() => _AnimatedLilyState();
}

class _AnimatedLilyState extends State<AnimatedLily>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: CustomPaint(
          painter: _LilyPainter(
            animation: _controller,
            variant: widget.variant,
            showPollen: showPollen,
            seed: widget.seed,
          ),
        ),
      ),
    );
  }

  bool get showPollen => widget.showPollen;
}

class _LilyPainter extends CustomPainter {
  _LilyPainter({
    required this.animation,
    required this.variant,
    required this.showPollen,
    required this.seed,
  }) : super(repaint: animation) {
    final rng = math.Random(seed);
    _pollen = List.generate(
      18,
      (i) => (
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        speed: 1 + rng.nextInt(2), // integer cycles keep the loop seamless
        size: 1.2 + rng.nextDouble() * 2.0,
        pink: i.isOdd,
      ),
    );
  }

  final Animation<double> animation;
  final LilyVariant variant;
  final bool showPollen;
  final int seed;

  late final List<({double x, double y, int speed, double size, bool pink})>
      _pollen;

  static const _anther = Color(0xFFE65100);
  static const _antherDark = Color(0xFFBF360C);
  static const _filament = Color(0xFFFFF1F5);

  _LilyColors get _colors => switch (variant) {
        LilyVariant.stargazer => _LilyColors.stargazer,
        LilyVariant.casaBlanca => _LilyColors.casaBlanca,
        LilyVariant.golden => _LilyColors.golden,
      };

  /// Bloom envelope over the loop: open, hold, close.
  double _bloomAt(double t) {
    const openStart = 0.05;
    const openEnd = 0.40;
    const closeStart = 0.80;
    const closeEnd = 0.99;
    if (t <= openStart) return 0;
    if (t <= openEnd) {
      return Curves.easeInOutCubic.transform(
        (t - openStart) / (openEnd - openStart),
      );
    }
    if (t <= closeStart) return 1;
    if (t <= closeEnd) {
      return 1 -
          Curves.easeInOutCubic.transform(
            (t - closeStart) / (closeEnd - closeStart),
          );
    }
    return 0;
  }

  static double _clamp01(double v) => v.clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final t = animation.value;
    final bloom = _bloomAt(t);
    final r = math.min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final colors = _colors;

    // Soft glow behind the blossom.
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          colors.mid.withValues(alpha: 0.28),
          colors.mid.withValues(alpha: 0.10),
          colors.mid.withValues(alpha: 0),
        ],
        stops: const [0, 0.55, 1],
      ).createShader(Rect.fromCircle(center: center, radius: r));
    canvas.drawCircle(center, r * 0.98, glow);

    // Whole-flower sway + gentle bob (integer cycle counts keep it looping).
    final sway = math.sin(t * math.pi * 6) * 0.045;
    final bob = math.sin(t * math.pi * 4 + 1) * r * 0.02;

    canvas.save();
    canvas.translate(center.dx, center.dy + bob);
    canvas.rotate(sway);

    final lenOuter = r * 0.86;
    final lenInner = r * 0.80;

    // Outer tepals first (behind), then inner tepals on top.
    for (var k = 0; k < 6; k++) {
      if (k.isOdd) continue;
      _drawPetal(
        canvas,
        index: k,
        angle: k * math.pi / 3,
        bloom: bloom,
        length: lenOuter,
        halfWidth: r * 0.19,
        stagger: (k ~/ 2) * 0.05,
        colors: colors,
        t: t,
      );
    }
    for (var k = 1; k < 6; k += 2) {
      _drawPetal(
        canvas,
        index: k,
        angle: k * math.pi / 3,
        bloom: bloom,
        length: lenInner,
        halfWidth: r * 0.17,
        stagger: 0.10 + ((k - 1) ~/ 2) * 0.05,
        colors: colors,
        t: t,
      );
    }

    // Stamens and pistil rise as the flower opens.
    final stamenBloom = Curves.easeOutCubic.transform(
      _clamp01((bloom - 0.25) / 0.6),
    );
    _drawStamens(canvas, t: t, bloom: stamenBloom, len: lenOuter, r: r);
    _drawPistil(canvas, bloom: stamenBloom, r: r);

    canvas.restore();

    if (showPollen) _drawPollen(canvas, t: t, size: size, r: r, bloom: bloom);
  }

  void _drawPetal(
    Canvas canvas, {
    required int index,
    required double angle,
    required double bloom,
    required double length,
    required double halfWidth,
    required double stagger,
    required _LilyColors colors,
    required double t,
  }) {
    // Staggered unfurling: this petal starts slightly after `stagger`.
    final b = _clamp01((bloom - stagger) / (1 - stagger));
    final eased = Curves.easeOutCubic.transform(b);

    canvas.save();
    // Petals fan out from the bud; a tiny breathing wobble once open.
    final wobble = math.sin(t * math.pi * 4 + index * 1.3) * 0.02 * eased;
    canvas.rotate(angle * eased + wobble);

    final len = length * (0.72 + 0.28 * eased);
    final wid = halfWidth * (0.30 + 0.70 * eased);

    final path = _petalPath(len, wid);
    final fill = Paint()
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(0, -len),
        [
          colors.base,
          Color.lerp(colors.base, colors.mid, 0.55)!,
          colors.mid,
          Color.lerp(colors.mid, colors.tip, 0.7)!,
          colors.tip,
        ],
        const [0, 0.22, 0.45, 0.78, 1],
      );
    canvas.drawPath(path, fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = colors.edge.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(0.8, halfWidth * 0.05),
    );

    // Midrib down the centre of the petal.
    canvas.drawLine(
      Offset(0, -len * 0.06),
      Offset(0, -len * 0.88),
      Paint()
        ..color = colors.edge.withValues(alpha: 0.35 * eased)
        ..strokeWidth = math.max(0.8, halfWidth * 0.06),
    );

    // Speckles near the throat, appearing with the bloom.
    if (eased > 0.35) {
      final rng = math.Random(seed * 31 + index);
      final specklePaint = Paint()
        ..color = colors.speckle.withValues(alpha: 0.55 * ((eased - 0.35) / 0.65));
      for (var s = 0; s < 7; s++) {
        final sx = (rng.nextDouble() * 2 - 1) * wid * 0.55;
        final sy = -len * (0.12 + rng.nextDouble() * 0.42);
        canvas.drawCircle(Offset(sx, sy), math.max(0.7, wid * 0.07), specklePaint);
      }
    }

    canvas.restore();
  }

  /// Slender lily tepal pointing up (tip at -length), widest near the middle.
  Path _petalPath(double len, double wid) {
    final p = Path()..moveTo(0, 0);
    p.cubicTo(-wid * 0.95, -len * 0.22, -wid * 0.88, -len * 0.62, -wid * 0.10, -len);
    p.quadraticBezierTo(0, -len * 1.04, wid * 0.10, -len);
    p.cubicTo(wid * 0.88, -len * 0.62, wid * 0.95, -len * 0.22, 0, 0);
    p.close();
    return p;
  }

  void _drawStamens(
    Canvas canvas, {
    required double t,
    required double bloom,
    required double len,
    required double r,
  }) {
    if (bloom <= 0.01) return;
    final reach = len * 0.50 * bloom;
    final filamentPaint = Paint()
      ..color = _filament
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.2, r * 0.014);

    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3 + math.pi / 6 +
          math.sin(t * math.pi * 4 + i) * 0.03 * bloom;
      final dir = Offset(math.sin(a), -math.cos(a));
      final perp = Offset(-dir.dy, dir.dx);
      final tip = dir * reach + perp * reach * 0.14 * math.sin(i * 1.7);
      final control = dir * reach * 0.55 + perp * reach * 0.22 * math.sin(i * 1.7);

      final filament = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(control.dx, control.dy, tip.dx, tip.dy);
      canvas.drawPath(filament, filamentPaint);

      // Anther: a pollen-heavy oval nodding off the tip of each filament.
      canvas.save();
      canvas.translate(tip.dx, tip.dy);
      canvas.rotate(a + 0.9);
      final w = r * 0.085 * bloom;
      final h = r * 0.030 * bloom;
      final antherRect = Rect.fromCenter(center: Offset.zero, width: w, height: h);
      canvas.drawOval(
        antherRect,
        Paint()..color = _anther,
      );
      canvas.drawOval(
        antherRect,
        Paint()
          ..color = _antherDark
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(0.6, r * 0.005),
      );
      // Pollen glints on the anther.
      canvas.drawCircle(
        Offset(-w * 0.18, -h * 0.12),
        math.max(0.5, h * 0.22),
        Paint()..color = const Color(0xFFFFCC80).withValues(alpha: 0.9),
      );
      canvas.restore();
    }
  }

  void _drawPistil(Canvas canvas, {required double bloom, required double r}) {
    if (bloom <= 0.01) return;
    // Soft throat glow.
    canvas.drawCircle(
      Offset.zero,
      r * 0.13 * bloom,
      Paint()
        ..shader = RadialGradient(
          colors: [
            const Color(0xFFFFF9C4).withValues(alpha: 0.75 * bloom),
            const Color(0xFFFFF9C4).withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r * 0.13)),
    );
    // Three-lobed stigma.
    final lobePaint = Paint()..color = const Color(0xFFDCE775).withValues(alpha: 0.95 * bloom);
    for (var i = 0; i < 3; i++) {
      final a = i * math.pi * 2 / 3 - math.pi / 2;
      canvas.drawCircle(
        Offset(math.cos(a), math.sin(a)) * r * 0.020 * bloom,
        math.max(1.0, r * 0.022 * bloom),
        lobePaint,
      );
    }
  }

  void _drawPollen(
    Canvas canvas, {
    required double t,
    required Size size,
    required double r,
    required double bloom,
  }) {
    for (final p in _pollen) {
      final phase = (p.y + t * p.speed) % 1;
      final x = size.width * p.x + math.sin(t * math.pi * 4 + p.x * 9) * r * 0.06;
      final y = size.height * 1.1 - phase * size.height * 1.25;
      final alpha =
          math.sin(phase * math.pi) * 0.75 * (0.35 + 0.65 * bloom);
      if (alpha <= 0.02) continue;
      final color = p.pink ? const Color(0xFFF8BBD0) : const Color(0xFFE2A33B);
      final pos = Offset(x, y);
      canvas.drawCircle(
        pos,
        p.size * 2.4,
        Paint()..color = color.withValues(alpha: alpha * 0.22),
      );
      canvas.drawCircle(
        pos,
        p.size * 0.8,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(_LilyPainter old) =>
      old.animation != animation ||
      old.variant != variant ||
      old.showPollen != showPollen ||
      old.seed != seed;
}

// ==================== DEMO SCREEN ====================

/// Full-screen preview of the lily animation with a variety switcher.
class LilyDemoScreen extends StatefulWidget {
  const LilyDemoScreen({super.key});

  @override
  State<LilyDemoScreen> createState() => _LilyDemoScreenState();
}

class _LilyDemoScreenState extends State<LilyDemoScreen> {
  LilyVariant _variant = LilyVariant.stargazer;

  static const _labels = {
    LilyVariant.stargazer: 'Stargazer',
    LilyVariant.casaBlanca: 'Casa Blanca',
    LilyVariant.golden: 'Golden',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animated Lily')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1D3B61), Color(0xFF12263F), Color(0xFF0A1729)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text(
                'Stargazer Lily',
                style: TextStyle(
                  color: Color(0xFFFCF6E7),
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'blooms on a gentle loop',
                style: TextStyle(
                  color: const Color(0xFFFCF6E7).withValues(alpha: 0.55),
                  fontSize: 13,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 20),
              AnimatedLily(size: 320, variant: _variant),
              const Spacer(flex: 2),
              SegmentedButton<LilyVariant>(
                segments: [
                  for (final v in LilyVariant.values)
                    ButtonSegment(value: v, label: Text(_labels[v]!)),
                ],
                selected: {_variant},
                onSelectionChanged: (s) => setState(() => _variant = s.first),
                style: ButtonStyle(
                  foregroundColor: WidgetStatePropertyAll(
                    const Color(0xFFFCF6E7).withValues(alpha: 0.85),
                  ),
                  backgroundColor: const WidgetStatePropertyAll(
                    Color(0xFF070F1C),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
