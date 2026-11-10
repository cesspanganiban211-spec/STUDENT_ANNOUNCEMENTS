import 'dart:math' as math;

import 'package:flutter/material.dart';

// ==================== ASCII LILY ====================

/// A dense ASCII lily bouquet that grows on a black screen: grass and
/// stems first, then ten overlapping blossoms — tan, white, gold,
/// crimson, mulberry, magenta and one big cream lily at the heart —
/// opening back to front above a typed `> picked for you_`.
///
/// Laid out against the *measured* monospace cell aspect so the
/// blossoms read round rather than stretched, and drawn with twinkling
/// characters, drifting petal particles and a few margin stars.
class AsciiLilyBouquet extends StatefulWidget {
  const AsciiLilyBouquet({
    super.key,
    this.cols = 84,
    this.rows = 56,
    this.seed = 42,
  });

  /// Grid width in characters.
  final int cols;

  /// Grid height in characters.
  final int rows;

  /// Layout seed — same seed always grows the same flower.
  final int seed;

  @override
  State<AsciiLilyBouquet> createState() => _AsciiLilyBouquetState();
}

class _AsciiLilyBouquetState extends State<AsciiLilyBouquet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
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
    return CustomPaint(
      painter: _BouquetPainter(
        animation: _controller,
        cols: widget.cols,
        rows: widget.rows,
        seed: widget.seed,
      ),
    );
  }
}

// ----------------------------- cell model -----------------------------

class _Cell {
  _Cell(
    this.chars,
    this.color, {
    required this.revealAt,
    this.color2,
    this.vanishAt = double.infinity,
    this.glint = false,
  });

  /// Characters this cell flickers between.
  final List<String> chars;

  /// Base colour and its slightly brighter twinkle partner.
  final Color color;
  final Color? color2;

  /// Seconds after which the cell appears / disappears
  /// (drives the growth phases and the bud melting into the bloom).
  final double revealAt;
  final double vanishAt;

  /// Cells that occasionally flash a bright sparkle.
  final bool glint;
}

class _Bouquet {
  _Bouquet(this.cols, this.rows) : cells = List<_Cell?>.filled(cols * rows, null);

  final int cols;
  final int rows;
  final List<_Cell?> cells;

  bool get inBounds => true;

  void set(int c, int r, _Cell cell) {
    if (c >= 0 && c < cols && r >= 0 && r < rows) {
      cells[r * cols + c] = cell;
    }
  }

  _Cell? at(int c, int r) =>
      (c >= 0 && c < cols && r >= 0 && r < rows) ? cells[r * cols + c] : null;
}

// ----------------------------- geometry ------------------------------

/// One blossom in the bouquet: centre, petal radius and palette.
class _FlowerSpec {
  const _FlowerSpec(
    this.cx,
    this.cy,
    this.r,
    this.base,
    this.tip,
    this.center,
    this.rot,
  );

  final int cx;
  final int cy;
  final int r;
  final Color base;
  final Color tip;
  final Color center;
  final double rot;
}

/// Ten overlapping lilies placed to match the reference bouquet —
/// back blossoms first so the front ones layer over them. Coordinates
/// are design units of a 76x56 grid: `x` as a fraction of the frame
/// width, `r` as the *vertical* petal reach in rows. (Horizontal reach
/// is derived from the real cell aspect at build time, so blossoms stay
/// round on screen instead of tall and skinny.)
List<_FlowerSpec> _flowerSpecs(int cols, int rows) {
  final s = cols / 76;
  final t = rows / 56;
  int c_(double x) => (x * s).round();
  int r_(double y) => (y * t).round();
  int rad(double v) => math.max(3, (v * t).round());

  return [
    _FlowerSpec(c_(38), r_(6), rad(8), const Color(0xFFA3854F),
        const Color(0xFFEBD9B4), const Color(0xFF6B4E2A), 0.2),
    _FlowerSpec(c_(19), r_(11), rad(7), const Color(0xFFBDBDB6),
        const Color(0xFFFFFFFF), const Color(0xFF9E9E7A), 0.5),
    _FlowerSpec(c_(56), r_(8), rad(7), const Color(0xFFD4A017),
        const Color(0xFFFFEE9C), const Color(0xFF8D6E06), 0.1),
    _FlowerSpec(c_(35), r_(13), rad(10), const Color(0xFFB01818),
        const Color(0xFFF0554A), const Color(0xFF4A0505), 0.0),
    _FlowerSpec(c_(12), r_(21), rad(8), const Color(0xFFE0A800),
        const Color(0xFFFFE680), const Color(0xFF8D6E06), 0.35),
    _FlowerSpec(c_(60), r_(19), rad(9), const Color(0xFF8A1A5A),
        const Color(0xFFD65A9E), const Color(0xFF4A0A33), 0.55),
    _FlowerSpec(c_(24), r_(26), rad(8), const Color(0xFFB0176F),
        const Color(0xFFF06AC8), const Color(0xFF6A0B47), 0.25),
    _FlowerSpec(c_(37), r_(33), rad(11), const Color(0xFFD8C4BA),
        const Color(0xFFFFFFFF), const Color(0xFFA1887F), 0.45),
    _FlowerSpec(c_(13), r_(35), rad(7), const Color(0xFFE6C043),
        const Color(0xFFFFF0A0), const Color(0xFF8D6E06), 0.15),
    _FlowerSpec(c_(61), r_(39), rad(9), const Color(0xFF7A1420),
        const Color(0xFFD64550), const Color(0xFF3A0510), 0.65),
  ];
}

/// Index of the big cream lily at the bouquet's heart — the falling
/// petals drift down from it.
const _creamIndex = 7;

// ----------------------------- painter -------------------------------

class _BouquetPainter extends CustomPainter {
  _BouquetPainter({
    required this.animation,
    required this.cols,
    required this.rows,
    required this.seed,
  }) : super(repaint: animation);

  final AnimationController animation;
  final int cols;
  final int rows;
  final int seed;

  /// Built lazily on the first paint so the flower geometry can be
  /// laid out against the *measured* cell aspect (Consolas cells are
  /// ~0.55 wide, the Ahem test font's are square).
  _Bouquet? _bouquet;

  double? _ratioW;
  double? _ratioH;

  static const _fontFamily = 'Consolas';
  static const _fontFallback = <String>[
    'Courier New',
    'DejaVu Sans Mono',
    'monospace',
  ];

  static const _message = '> picked for you';

  TextStyle _style(double fontSize, Color color) => TextStyle(
        color: color,
        fontSize: fontSize,
        height: 1.0,
        fontFamily: _fontFamily,
        fontFamilyFallback: _fontFallback,
      );

  void _measure() {
    if (_ratioW != null) return;
    final w = TextPainter(
      text: TextSpan(text: 'MMMM', style: _style(100, Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    final h = TextPainter(
      text: TextSpan(text: 'M', style: _style(100, Colors.white)),
      textDirection: TextDirection.ltr,
    )..layout();
    _ratioW = w.width / 4 / 100;
    _ratioH = h.height / 100;
    w.dispose();
    h.dispose();
  }

  @override
  void paint(Canvas canvas, Size size) {
    _measure();
    _bouquet ??=
        _buildBouquet(cols, rows, seed, k: _ratioW! / _ratioH!);

    final elapsedMs = animation.lastElapsedDuration?.inMilliseconds ?? 0;
    final sec = elapsedMs / 1000.0;
    final tick = elapsedMs ~/ 90;

    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF050507));

    final availW = math.max(40.0, size.width - 24);
    final availH = math.max(40.0, size.height - 24);
    var fontSize = math.min(
      availW / (cols * _ratioW!),
      availH / (rows * _ratioH!),
    );
    if (!fontSize.isFinite || fontSize <= 0) fontSize = 12;

    final charW = _ratioW! * fontSize;
    final charH = _ratioH! * fontSize;
    final gridW = cols * charW;
    final gridH = rows * charH;
    final origin = Offset(
      (size.width - gridW) / 2,
      (size.height - gridH) / 2,
    );

    final base = _style(fontSize, Colors.white);

    for (var r = 0; r < rows; r++) {
      final spans = <TextSpan>[];
      final buf = StringBuffer();
      Color? runColor;

      void flush() {
        if (buf.isEmpty) return;
        spans.add(
          TextSpan(
            text: buf.toString(),
            style: base.copyWith(color: runColor ?? const Color(0x00000000)),
          ),
        );
        buf.clear();
      }

      for (var c = 0; c < cols; c++) {
        final idx = r * cols + c;
        final cell = _bouquet!.cells[idx];
        Color? color;
        var ch = ' ';
        if (cell != null) {
          final resolved = _resolve(cell, idx, sec, tick);
          if (resolved != null) {
            ch = resolved.$1;
            color = resolved.$2;
          }
        }
        if (color != runColor) {
          flush();
          runColor = color;
        }
        buf.write(ch);
      }
      flush();

      if (spans.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(children: spans, style: base),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      painter.paint(canvas, Offset(origin.dx, origin.dy + r * charH));
      painter.dispose();
    }

    _paintDriftingPetals(canvas, origin: origin, charW: charW, charH: charH, fontSize: fontSize, sec: sec, tick: tick);
    _paintMessage(canvas, origin: origin, charH: charH, fontSize: fontSize, sec: sec);
  }

  /// Picks the twinkling character/colour for one visible cell.
  (String, Color)? _resolve(_Cell cell, int idx, double sec, int tick) {
    if (sec < cell.revealAt || sec >= cell.vanishAt) return null;
    final h = _hash(idx + seed * 7919);
    final speed = (h & 1) == 0 ? 1 : 2;
    var ch = cell.chars[((tick ~/ speed) + h) % cell.chars.length];
    var color = ((tick + h) & 1) == 0
        ? cell.color
        : (cell.color2 ?? cell.color);
    if (cell.glint && (((h >> 7) + tick) % 97) == 0) {
      ch = '*';
      color = const Color(0xFFFFFDE7);
    }
    return (ch, color);
  }

  /// Loose petals tumbling down from the bloom.
  void _paintDriftingPetals(
    Canvas canvas, {
    required Offset origin,
    required double charW,
    required double charH,
    required double fontSize,
    required double sec,
    required int tick,
  }) {
    if (sec < 4.2) return;
    const dirs = [
      (-1.05, -0.55),
      (-0.45, -1.15),
      (0.40, -1.10),
      (1.00, -0.50),
      (1.20, 0.35),
      (-1.15, 0.30),
    ];
    const palette = [Color(0xFFF8BBD0), Color(0xFFFCE4EC), Color(0xFFFFE082)];
    final hero = _flowerSpecs(cols, rows)[_creamIndex];
    final cx = hero.cx;
    final cy = hero.cy;
    final L = hero.r;
    const period = 7.0;
    final k = _ratioW! / _ratioH!;

    for (var i = 0; i < dirs.length; i++) {
      final local = ((sec - 4.2) + i * 1.9) % period;
      final (ux, uy) = dirs[i];
      final startX = cx + ux * (L + 2) / k;
      final startY = cy + uy * (L + 2);
      final x = startX + math.sin(local * 1.1 + i * 2.0) * 1.8 / k;
      final y = startY + local * 1.7;
      final alpha = math.sin((local / period) * math.pi) * 0.85;
      if (alpha <= 0.04) continue;
      final ch = ['~', "'", '*', '.'][(tick + i) % 4];
      final color = palette[i % palette.length].withValues(alpha: alpha);
      final tp = TextPainter(
        text: TextSpan(text: ch, style: _style(fontSize, color)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(origin.dx + x * charW, origin.dy + y * charH),
      );
      tp.dispose();
    }
  }

  /// A terminal-style dedication that types itself, holds, erases and
  /// repeats along the bottom row, with a blinking cursor.
  void _paintMessage(
    Canvas canvas, {
    required Offset origin,
    required double charH,
    required double fontSize,
    required double sec,
  }) {
    final since = sec - 5.0;
    if (since <= 0) return;
    final cycle = since % 9.0;
    int shown;
    if (cycle < 1.6) {
      shown = (cycle / 1.6 * _message.length).ceil();
    } else if (cycle < 6.5) {
      shown = _message.length;
    } else if (cycle < 7.5) {
      shown = (_message.length * (1 - (cycle - 6.5))).floor();
    } else {
      return; // blank pause before the next pass
    }
    shown = shown.clamp(0, _message.length);
    final cursorOn = (sec * 2).floor().isEven;
    final text = _message.substring(0, shown) + (cursorOn ? '_' : ' ');
    final color = const Color(0xFF81C784).withValues(alpha: 0.92);

    final tp = TextPainter(
      text: TextSpan(text: text, style: _style(fontSize, color)),
      textDirection: TextDirection.ltr,
    )..layout();
    final y = origin.dy + (rows - 1) * charH;
    // Clear the grass behind the command line so it reads like a prompt.
    canvas.drawRect(
      Rect.fromLTWH(origin.dx, y, tp.width + charH * 0.4, charH),
      Paint()..color = const Color(0xFF050507),
    );
    tp.paint(canvas, Offset(origin.dx, y));
    tp.dispose();
  }

  static int _hash(int n) {
    var x = n;
    x = (x ^ (x >> 16)) * 0x45d9f3b;
    x = (x ^ (x >> 16)) * 0x45d9f3b;
    return (x ^ (x >> 16)) & 0x7fffffff;
  }

  @override
  bool shouldRepaint(_BouquetPainter old) =>
      old.cols != cols || old.rows != rows || old.seed != seed;
}

// --------------------------- layout builder --------------------------

/// Lays the whole bouquet out on the cell grid. [k] is the measured
/// cell aspect (char width / char height), so blossoms drawn here come
/// out round in real pixels rather than stretched.
_Bouquet _buildBouquet(int cols, int rows, int seed, {required double k}) {
  final rng = math.Random(seed);
  final g = _Bouquet(cols, rows);
  final specs = _flowerSpecs(cols, rows);
  final grassRoot = (36 * cols / 76).round();

  _addStars(g, rng, specs, k);
  _addGrass(g, rng, rootCol: grassRoot);

  // Stems climb from the grass and stop just under each blossom's
  // skirt, where the lowest petals cover the tip — they mostly hide,
  // showing through only in the gaps.
  for (var j = 0; j < specs.length; j++) {
    final spec = specs[j];
    _addStem(
      g,
      rng,
      rootCol: grassRoot + ((j % 3) - 1) * (6 * cols / 76).round(),
      rootRow: rows - 3,
      topCol: spec.cx,
      topRow: spec.cy + (spec.r * 0.85).round(),
      start: 0.9 + j * 0.08,
      dur: 0.9,
      curve: (rng.nextDouble() * 2 - 1) * 1.6,
    );
  }

  // A tiny bud peeking over the very top of the frame, between the
  // tan lily and the gold one.
  _addBud(
    g,
    rng,
    (51 * cols / 76).round(),
    0,
    size: 3,
    start: 1.9,
    dark: const Color(0xFF7A0B4E),
    light: const Color(0xFFD81B9B),
  );

  // Blossoms bloom back to front, so the front lilies layer over them.
  for (var i = 0; i < specs.length; i++) {
    _addFlower(g, rng, specs[i], order: i, k: k);
  }

  return g;
}

void _addStars(
    _Bouquet g, math.Random rng, List<_FlowerSpec> specs, double k) {
  for (var i = 0; i < 150; i++) {
    final c = rng.nextInt(g.cols);
    final r = rng.nextInt(g.rows);
    final nearBloom = specs.any((f) {
      final dx = (c - f.cx) * k;
      final d = math.sqrt(dx * dx + (r - f.cy) * (r - f.cy));
      return d < f.r + 3;
    });
    if (nearBloom) continue; // stars live in the margins of the bouquet
    final bright = rng.nextDouble() < 0.16;
    g.set(
      c,
      r,
      _Cell(
        const ['.', '`', '*'],
        const Color(0xFFCFD8DC).withValues(alpha: bright ? 0.85 : 0.42),
        revealAt: (i % 20) * 0.04,
        color2: const Color(0xFFCFD8DC).withValues(alpha: bright ? 0.30 : 0.10),
      ),
    );
  }
}

List<(int, int)> _addStem(
  _Bouquet g,
  math.Random rng, {
  required int rootCol,
  required int rootRow,
  required int topCol,
  required int topRow,
  required double start,
  required double dur,
  double curve = 0,
}) {
  const greens = [
    Color(0xFF1B5E20),
    Color(0xFF2E7D32),
    Color(0xFF43A047),
    Color(0xFF66BB6A),
  ];
  final steps = math.max(1, rootRow - topRow);
  final path = <(int, int)>[];
  var prevCol = rootCol;
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final r = rootRow - i;
    final col = (rootCol +
            (topCol - rootCol) * t +
            math.sin(t * math.pi) * curve)
        .round();
    final slope = col - prevCol;
    final ch = slope > 0 ? '/' : slope < 0 ? r'\' : '|';
    final color = Color.lerp(greens[0], greens[3], t.clamp(0.0, 1.0))!;
    g.set(
      col,
      r,
      _Cell([ch, '|', ':'], color, revealAt: start + t * dur),
    );
    path.add((col, r));
    prevCol = col;
  }
  return path;
}

void _addGrass(_Bouquet g, math.Random rng, {required int rootCol}) {
  const greens = [
    Color(0xFF2E7D32),
    Color(0xFF43A047),
    Color(0xFF66BB6A),
    Color(0xFF8BC34A),
    Color(0xFFAED581),
  ];
  const verticals = ['|', ':', '"', "'", ';', 'i'];
  final rootRow = g.rows - 1;
  // A fan: roots clustered, tips spreading wide with black between.
  for (var i = 0; i < 26; i++) {
    final root = rootCol + (rng.nextDouble() * 2 - 1) * 13;
    final h = 7 + rng.nextInt(9);
    final lean = (rng.nextDouble() * 2 - 1) * 9;
    final start = 0.1 + i * 0.024;
    var prevCol = root.round();
    for (var s = 0; s <= h; s++) {
      final t = s / h;
      final col = (root + lean * t * t + math.sin(s * 0.9 + i) * 0.7).round();
      final slope = col - prevCol;
      final ch = slope > 0
          ? '/'
          : slope < 0
              ? r'\'
              : verticals[rng.nextInt(verticals.length)];
      final color = Color.lerp(greens[0], greens[4], t.clamp(0.0, 1.0))!;
      g.set(
        col,
        rootRow - s,
        _Cell(
          [ch, verticals[rng.nextInt(4)]],
          color,
          revealAt: start + t * 0.5,
        ),
      );
      prevCol = col;
    }
  }
}

void _addBud(
  _Bouquet g,
  math.Random rng,
  int bx,
  int by, {
  required int size,
  required double start,
  double Function(int c, int r)? vanish,
  Color dark = const Color(0xFF5C1019),
  Color light = const Color(0xFFC1402C),
}) {
  for (var i = 0; i < size; i++) {
    final r = by + i;
    final halfW = i == 0 ? 0 : math.min(2, 1 + i ~/ 2);
    for (var dc = -halfW; dc <= halfW; dc++) {
      final color = Color.lerp(light, dark, i / math.max(1, size - 1))!;
      final ch = ['&', '%', '#', '8', '@'][rng.nextInt(5)];
      g.set(
        bx + dc,
        r,
        _Cell(
          [ch, '#', '8'],
          color,
          revealAt: start + i * 0.07,
          vanishAt: vanish?.call(bx + dc, r) ?? double.infinity,
        ),
      );
    }
  }
}

/// Draws one six-petalled lily: a dark throat flecked with gold, then
/// dense petals that soften at the edges, blooming outward from the
/// centre once [order]'s turn comes. All geometry is done in pixel
/// space — [k] (char width / char height) stretches the x axis — so
/// the blossom measures round on screen instead of tall and skinny.
void _addFlower(
  _Bouquet g,
  math.Random rng,
  _FlowerSpec f, {
  required int order,
  required double k,
}) {
  final bloom = 2.2 + order * 0.12;
  final L = f.r.toDouble();
  // Vertical reach is L rows; horizontally a blossom spans ~L / k
  // cells so its pixel width matches its pixel height.
  final haloY = (L + 1).ceil();
  final haloX = ((L + 1) / k).ceil();
  final centerR = L * 0.24;

  for (var r = f.cy - haloY; r <= f.cy + haloY; r++) {
    for (var c = f.cx - haloX; c <= f.cx + haloX; c++) {
      final dx = (c - f.cx) * k;
      final dy = r - f.cy;
      final d = math.sqrt(dx * dx + dy * dy);
      if (d > L + 0.5) continue;

      final h = _BouquetPainter._hash(c * 31 + r * 17 + f.cx * 7);

      if (d < centerR) {
        // Rich dark throat with a scattering of gold pollen flecks.
        if (d < centerR * 0.7 && h % 3 == 0) {
          g.set(
            c,
            r,
            _Cell(
              const ['+', '*', '.'],
              const Color(0xFFFDD835),
              revealAt: bloom + 0.8,
              color2: const Color(0xFFFFF176),
              glint: true,
            ),
          );
        } else {
          final cc = Color.lerp(f.center, const Color(0xFFFFFFFF),
              (h % 5) * 0.03)!;
          g.set(
            c,
            r,
            _Cell(
              const ['@', '%', '#', '8'],
              cc,
              revealAt: bloom + 0.05,
              color2: Color.lerp(cc, f.base, 0.4)!,
            ),
          );
        }
        continue;
      }

      final phi = math.atan2(dy, dx);
      final v = d / L;
      var bestU = 1e9;
      var bestK = 0;
      for (var k = 0; k < 6; k++) {
        final th = f.rot + k * math.pi / 3;
        var delta = phi - th;
        while (delta > math.pi) {
          delta -= 2 * math.pi;
        }
        while (delta < -math.pi) {
          delta += 2 * math.pi;
        }
        final halfW =
            0.34 * math.pow(math.sin(math.pi * math.min(v, 0.98)), 0.65) + 0.05;
        final u = delta.abs() / halfW;
        if (u < bestU) {
          bestU = u;
          bestK = k;
        }
      }
      if (bestU > 1.0) {
        // The petals join at the base — fill the throat's outer ring so
        // no black seam opens between the dark centre and the arms.
        if (v >= centerR / L && v < 0.34) {
          g.set(
            c,
            r,
            _Cell(
              const ['#', '&', '%'],
              Color.lerp(f.center, f.base, 0.5)!,
              revealAt: bloom + 0.1,
              color2: f.center,
            ),
          );
        }
        continue;
      }

      // A solid petal body that softens only near the very edges —
      // reference bouquets read as dense masses of text, not sprays.
      final s = (1 - bestU * 0.60) * (1 - v * 0.25);
      var color = Color.lerp(f.base, f.tip, (v * 1.1).clamp(0.0, 1.0))!;
      color = Color.lerp(color, const Color(0xFF000000), bestU * 0.10)!;

      List<String> chars = s > 0.68
          ? const ['#', '%', '&', '@']
          : s > 0.52
              ? const ['*', '+', '=', 'x']
              : s > 0.36
                  ? const ['o', '~', 'h', '-']
                  : s > 0.22
                      ? const ['-', '~', '"']
                      : const ['.', ':', "'", ','];

      Color? color2;
      var glint = false;
      if (v > 0.26 && v < 0.60 && h % 5 == 0) {
        // Speckles leading down into the throat.
        chars = const ['x', '%', '&'];
        color = Color.lerp(f.center, f.base, 0.45)!;
        color2 = f.center;
      } else {
        if ((h & 3) == 0) {
          color = Color.lerp(color, const Color(0xFFFFFFFF), 0.14)!;
        }
        color2 = Color.lerp(color, const Color(0xFFFFFFFF), 0.16)!;
        glint = (h & 7) == 0;
      }

      g.set(
        c,
        r,
        _Cell(
          chars,
          color,
          revealAt: bloom + v * 0.85 + bestK * 0.04,
          color2: color2,
          glint: glint,
        ),
      );
    }
  }
}

// ==================== DEMO SCREEN ====================

/// Full-screen showcase of the blooming ASCII lily with a dedication
/// caption and a button that replays the growth animation.
class AsciiLilyScreen extends StatefulWidget {
  const AsciiLilyScreen({super.key});

  @override
  State<AsciiLilyScreen> createState() => _AsciiLilyScreenState();
}

class _AsciiLilyScreenState extends State<AsciiLilyScreen> {
  int _generation = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050507),
      body: SafeArea(
        child: Column(
          children: [
            if (Navigator.canPop(context))
              const Align(
                alignment: Alignment.centerLeft,
                child: BackButton(color: Colors.white70),
              )
            else
              const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontFamilyFallback: ['Times New Roman', 'serif'],
                    fontSize: 24,
                    height: 1.25,
                    color: Color(0xFFF5E6C8),
                  ),
                  children: [
                    TextSpan(text: "I couldn't send real flowers,\n"),
                    TextSpan(
                      text: 'so I grew you one in code.',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final w = math.min(constraints.maxWidth - 24, 470.0);
                    final h = math.min(constraints.maxHeight - 8, w * 1.22);
                    return SizedBox(
                      width: w,
                      height: h,
                      child: AsciiLilyBouquet(key: ValueKey(_generation)),
                    );
                  },
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.refresh, size: 18, color: Colors.white38),
                const SizedBox(width: 6),
                TextButton(
                  onPressed: () => setState(() => _generation++),
                  child: const Text(
                    'replay bloom',
                    style: TextStyle(color: Color(0xFFF48FB1), fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
