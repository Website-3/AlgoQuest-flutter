import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/game_service.dart';

// ============================================================
// DUNGEON BOARD
// ============================================================
// Pengganti _MazePainter. Hanya menggambar; tidak menyentuh
// logika. Memakai MazeLevel.walls, size, monster, region
// persis seperti sebelumnya, jadi posisi hero/monster tetap
// cocok dengan grid.
//
// Cara pakai di game_page.dart:
//   Positioned.fill(child: DungeonBoard(level: _level))

/// Warna per wilayah (0..4). Tambah wilayah baru = tambah satu entri.
class DungeonTheme {
  final Color floorA;
  final Color floorB;
  final Color wallTop;
  final Color wallFront;
  final Color mortar;
  final Color glow;
  final Color moss;
  final bool hasMoss;

  const DungeonTheme({
    required this.floorA,
    required this.floorB,
    required this.wallTop,
    required this.wallFront,
    required this.mortar,
    required this.glow,
    required this.moss,
    required this.hasMoss,
  });

  static const List<DungeonTheme> _all = <DungeonTheme>[
    // 0 Hutan Algoritma
    DungeonTheme(
      floorA: Color(0xFF2B2E2A),
      floorB: Color(0xFF242722),
      wallTop: Color(0xFF5A5F58),
      wallFront: Color(0xFF3B403B),
      mortar: Color(0xFF151815),
      glow: Color(0xFFFFA23A),
      moss: Color(0xFF4E7A3A),
      hasMoss: true,
    ),
    // 1 Slime / gua teal
    DungeonTheme(
      floorA: Color(0xFF22302F),
      floorB: Color(0xFF1C2827),
      wallTop: Color(0xFF4E6563),
      wallFront: Color(0xFF334544),
      mortar: Color(0xFF111A19),
      glow: Color(0xFF4FE0C8),
      moss: Color(0xFF3FA37A),
      hasMoss: true,
    ),
    // 2 Naga / api
    DungeonTheme(
      floorA: Color(0xFF332824),
      floorB: Color(0xFF2B211E),
      wallTop: Color(0xFF6B534A),
      wallFront: Color(0xFF4A3832),
      mortar: Color(0xFF1A1210),
      glow: Color(0xFFFF6A2A),
      moss: Color(0xFF000000),
      hasMoss: false,
    ),
    // 3 Iblis / ungu
    DungeonTheme(
      floorA: Color(0xFF2A2433),
      floorB: Color(0xFF221D2B),
      wallTop: Color(0xFF5B5170),
      wallFront: Color(0xFF3D3550),
      mortar: Color(0xFF16121D),
      glow: Color(0xFFB36BFF),
      moss: Color(0xFF000000),
      hasMoss: false,
    ),
    // 4 Behemoth / baja biru
    DungeonTheme(
      floorA: Color(0xFF232A33),
      floorB: Color(0xFF1D232B),
      wallTop: Color(0xFF566274),
      wallFront: Color(0xFF3A4452),
      mortar: Color(0xFF12171D),
      glow: Color(0xFF6BB8FF),
      moss: Color(0xFF000000),
      hasMoss: false,
    ),
  ];

  static DungeonTheme forRegion(int region) =>
      _all[region.clamp(0, _all.length - 1)];
}

class DungeonBoard extends StatefulWidget {
  final MazeLevel level;

  /// Matikan kedipan obor (mis. di widget test agar pumpAndSettle selesai).
  final bool animate;

  const DungeonBoard({super.key, required this.level, this.animate = true});

  @override
  State<DungeonBoard> createState() => _DungeonBoardState();
}

class _DungeonBoardState extends State<DungeonBoard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );
    if (widget.animate) _ctrl.repeat();
  }

  @override
  void didUpdateWidget(covariant DungeonBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_ctrl.isAnimating) {
      _ctrl.repeat();
    } else if (!widget.animate && _ctrl.isAnimating) {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _DungeonPainter(
          level: widget.level,
          theme: DungeonTheme.forRegion(widget.level.region),
          time: _ctrl,
        ),
      ),
    );
  }
}

class _DungeonPainter extends CustomPainter {
  final MazeLevel level;
  final DungeonTheme theme;
  final Animation<double> time;

  _DungeonPainter({
    required this.level,
    required this.theme,
    required this.time,
  }) : super(repaint: time);

  // Angka acak deterministik per sel, supaya tekstur tidak berubah
  // tiap repaint dan sama setiap level dimuat.
  double _rnd(int r, int c, int salt) {
    final int h =
        ((r * 73856093) ^ (c * 19349663) ^ (salt * 83492791)) & 0x7fffffff;
    return (h % 1000) / 1000.0;
  }

  bool _wall(int r, int c) => level.isWall(r, c);

  @override
  void paint(Canvas canvas, Size size) {
    final int n = level.size;
    final double cell = size.width / n;
    final RRect clip = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    canvas.save();
    canvas.clipRRect(clip);
    canvas.drawRect(Offset.zero & size, Paint()..color = theme.mortar);

    _paintFloor(canvas, cell, n);
    _paintShadows(canvas, cell, n);
    final List<Offset> torches = _paintWalls(canvas, cell, n);
    _paintMonsterMark(canvas, cell);
    _paintTorchGlow(canvas, cell, torches);
    _paintVignette(canvas, size);

    canvas.restore();

    canvas.drawRRect(
      clip,
      Paint()
        ..color = const Color(0xFFC9A24A).withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  // ---------- Lantai ubin ----------
  void _paintFloor(Canvas canvas, double cell, int n) {
    final Paint tile = Paint();
    final Paint hi = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint crack = Paint()
      ..color = Colors.black.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (_wall(r, c)) continue;
        final Rect rect = Rect.fromLTWH(c * cell, r * cell, cell, cell)
            .deflate(cell * 0.03);
        final double v = _rnd(r, c, 1);
        tile.color = Color.lerp(theme.floorA, theme.floorB, v)!;
        final RRect rr =
            RRect.fromRectAndRadius(rect, Radius.circular(cell * 0.08));
        canvas.drawRRect(rr, tile);
        // Highlight tepi atas-kiri.
        canvas.drawLine(
          rect.topLeft + Offset(cell * 0.08, 0.5),
          rect.topRight + Offset(-cell * 0.08, 0.5),
          hi,
        );
        if (_rnd(r, c, 2) > 0.7) {
          final Offset a = rect.topLeft +
              Offset(cell * (0.2 + 0.4 * _rnd(r, c, 3)), cell * 0.15);
          final Path p = Path()
            ..moveTo(a.dx, a.dy)
            ..lineTo(a.dx + cell * 0.12, a.dy + cell * 0.25)
            ..lineTo(a.dx + cell * 0.04, a.dy + cell * 0.45);
          canvas.drawPath(p, crack);
        }
      }
    }
  }

  // ---------- Bayangan dinding jatuh ke lantai ----------
  void _paintShadows(Canvas canvas, double cell, int n) {
    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (_wall(r, c)) continue;
        // Bayangan dari dinding di atas.
        if (_wall(r - 1, c)) {
          final Rect s = Rect.fromLTWH(c * cell, r * cell, cell, cell * 0.5);
          canvas.drawRect(
            s,
            Paint()
              ..shader = LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.5),
                  Colors.transparent,
                ],
              ).createShader(s),
          );
        }
        // Bayangan dari dinding di kiri.
        if (_wall(r, c - 1)) {
          final Rect s = Rect.fromLTWH(c * cell, r * cell, cell * 0.35, cell);
          canvas.drawRect(
            s,
            Paint()
              ..shader = LinearGradient(
                colors: <Color>[
                  Colors.black.withValues(alpha: 0.32),
                  Colors.transparent,
                ],
              ).createShader(s),
          );
        }
      }
    }
  }

  // ---------- Dinding 3/4 (sisi atas + sisi depan) ----------
  // Semua gambar tetap di dalam kotak selnya, jadi tidak ada
  // yang bergeser dari grid.
  List<Offset> _paintWalls(Canvas canvas, double cell, int n) {
    final List<Offset> torches = <Offset>[];
    final Paint p = Paint();
    final Paint line = Paint()
      ..color = theme.mortar.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint topHi = Paint()
      ..color = Colors.white.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;

    for (var r = 0; r < n; r++) {
      for (var c = 0; c < n; c++) {
        if (!_wall(r, c)) continue;
        final bool exposed = r + 1 < n && !_wall(r + 1, c);
        final double frontH = exposed ? cell * 0.32 : 0;
        final Rect base = Rect.fromLTWH(c * cell, r * cell, cell, cell)
            .deflate(cell * 0.02);
        final Rect top = Rect.fromLTRB(
          base.left,
          base.top,
          base.right,
          base.bottom - frontH,
        );

        // Sisi depan
        if (exposed) {
          final Rect front = Rect.fromLTRB(
            base.left,
            top.bottom,
            base.right,
            base.bottom,
          );
          p.color = Color.lerp(theme.wallFront, Colors.black,
              0.1 * _rnd(r, c, 4))!;
          canvas.drawRRect(
            RRect.fromRectAndCorners(
              front,
              bottomLeft: Radius.circular(cell * 0.08),
              bottomRight: Radius.circular(cell * 0.08),
            ),
            p,
          );
          // Susunan bata
          final double my = front.top + front.height * 0.5;
          canvas.drawLine(Offset(front.left, my), Offset(front.right, my), line);
          final double off = _rnd(r, c, 5) * 0.4 + 0.3;
          canvas.drawLine(
            Offset(front.left + front.width * off, front.top),
            Offset(front.left + front.width * off, my),
            line,
          );
          canvas.drawLine(
            Offset(front.left + front.width * (1 - off), my),
            Offset(front.left + front.width * (1 - off), front.bottom),
            line,
          );
          // Obor: sebagian dinding yang menghadap lantai.
          if (_rnd(r, c, 6) > 0.62) {
            torches.add(Offset(front.center.dx, front.top + front.height * 0.45));
          }
        }

        // Sisi atas
        p.color = Color.lerp(theme.wallTop, Colors.black,
            0.14 * _rnd(r, c, 7))!;
        final RRect topRR = RRect.fromRectAndCorners(
          top,
          topLeft: Radius.circular(cell * 0.12),
          topRight: Radius.circular(cell * 0.12),
          bottomLeft: Radius.circular(exposed ? 0 : cell * 0.12),
          bottomRight: Radius.circular(exposed ? 0 : cell * 0.12),
        );
        canvas.drawRRect(topRR, p);
        canvas.drawRRect(topRR, line);
        canvas.drawLine(
          Offset(top.left + cell * 0.14, top.top + 2),
          Offset(top.right - cell * 0.14, top.top + 2),
          topHi,
        );
        // Retakan batu di sisi atas
        if (_rnd(r, c, 8) > 0.55) {
          final double x = top.left + top.width * (0.25 + 0.5 * _rnd(r, c, 9));
          canvas.drawLine(
            Offset(x, top.top + 3),
            Offset(x + cell * 0.06, top.bottom - 3),
            line,
          );
        }
        // Lumut
        if (theme.hasMoss && _rnd(r, c, 10) > 0.6) {
          final Paint m = Paint()..color = theme.moss.withValues(alpha: 0.55);
          final Offset o = Offset(
            top.left + top.width * (0.2 + 0.6 * _rnd(r, c, 11)),
            top.top + top.height * 0.25,
          );
          canvas.drawOval(
            Rect.fromCenter(
              center: o,
              width: cell * 0.34,
              height: cell * 0.2,
            ),
            m,
          );
        }
      }
    }
    return torches;
  }

  // ---------- Penanda monster ----------
  void _paintMonsterMark(Canvas canvas, double cell) {
    final Offset c = Offset(
      (level.monster.col + 0.5) * cell,
      (level.monster.row + 0.5) * cell,
    );
    final Paint ring = Paint()
      ..color = const Color(0xFFFF4D5E).withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.5, cell * 0.04);
    canvas.drawOval(
      Rect.fromCenter(
        center: c.translate(0, cell * 0.22),
        width: cell * 0.9,
        height: cell * 0.4,
      ),
      ring,
    );
  }

  // ---------- Obor + cahaya hangat berkedip ----------
  void _paintTorchGlow(Canvas canvas, double cell, List<Offset> torches) {
    final double t = time.value * math.pi * 2;
    for (var i = 0; i < torches.length; i++) {
      final Offset o = torches[i];
      final double f = 0.82 +
          0.18 * math.sin(t * 2 + i * 1.7) * math.cos(t * 3 + i * 0.9);

      // Cahaya di lantai (additive).
      final Offset lightC = o.translate(0, cell * 0.55);
      final double radius = cell * 1.7;
      canvas.drawCircle(
        lightC,
        radius,
        Paint()
          ..blendMode = BlendMode.plus
          ..shader = RadialGradient(
            colors: <Color>[
              theme.glow.withValues(alpha: 0.30 * f),
              theme.glow.withValues(alpha: 0.10 * f),
              Colors.transparent,
            ],
            stops: const <double>[0, 0.45, 1],
          ).createShader(Rect.fromCircle(center: lightC, radius: radius)),
      );

      // Braket
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: o.translate(0, cell * 0.07),
            width: cell * 0.1,
            height: cell * 0.18,
          ),
          Radius.circular(cell * 0.03),
        ),
        Paint()..color = const Color(0xFF2A2018),
      );

      // Api
      final double w = cell * 0.1 * f;
      final double h = cell * 0.2 * f;
      final Offset fc = o.translate(0, -cell * 0.04);
      Path flame(double s) => Path()
        ..moveTo(fc.dx, fc.dy - h * s)
        ..quadraticBezierTo(fc.dx + w * s, fc.dy - h * 0.1 * s, fc.dx,
            fc.dy + h * 0.45 * s)
        ..quadraticBezierTo(fc.dx - w * s, fc.dy - h * 0.1 * s, fc.dx,
            fc.dy - h * s);
      canvas.drawPath(flame(1), Paint()..color = const Color(0xFFFF8A1F));
      canvas.drawPath(flame(0.6), Paint()..color = const Color(0xFFFFE07A));
    }
  }

  // ---------- Vignette tepi ----------
  void _paintVignette(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          radius: 0.85,
          colors: <Color>[
            Colors.transparent,
            Colors.black.withValues(alpha: 0.45),
          ],
          stops: const <double>[0.6, 1],
        ).createShader(r),
    );
  }

  @override
  bool shouldRepaint(covariant _DungeonPainter oldDelegate) =>
      oldDelegate.level != level || oldDelegate.theme != theme;
}