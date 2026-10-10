import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================
// MONSTER TOKEN — MAKHLUK YANG DIGAMBAR
// ============================================================
// Digambar penuh dengan kode (bukan ikon) supaya bergaya satu dengan
// [HeroToken]: badan bergradasi + garis tepi, tanduk, mata marah, dan
// mulut bergigi. Dipakai bersama Mode Petualangan & Arena Logika.

class MonsterToken extends StatelessWidget {
  const MonsterToken({
    super.key,
    required this.size,
    this.flash = 0.0,
    this.defeated = false,
    this.tint = const Color(0xFFC0392B),
  });

  /// Ukuran sisi kotak (persegi).
  final double size;

  /// Kilat putih saat terkena serangan (0..1).
  final double flash;

  /// Sudah kalah: mata berubah menjadi tanda silang (X).
  final bool defeated;

  /// Warna dasar tubuh monster.
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MonsterPainter(
          flash: flash.clamp(0.0, 1.0),
          defeated: defeated,
          tint: tint,
        ),
      ),
    );
  }
}

class _MonsterPainter extends CustomPainter {
  _MonsterPainter({
    required this.flash,
    required this.defeated,
    required this.tint,
  });

  final double flash;
  final bool defeated;
  final Color tint;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Bayangan di lantai.
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.9),
        width: w * 0.74,
        height: h * 0.15,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.35),
    );

    // Badan (blob).
    final Path body = Path()
      ..moveTo(w * 0.15, h * 0.80)
      ..quadraticBezierTo(w * 0.02, h * 0.48, w * 0.27, h * 0.31)
      ..quadraticBezierTo(w * 0.40, h * 0.19, w * 0.50, h * 0.20)
      ..quadraticBezierTo(w * 0.60, h * 0.19, w * 0.73, h * 0.31)
      ..quadraticBezierTo(w * 0.98, h * 0.48, w * 0.85, h * 0.80)
      ..quadraticBezierTo(w * 0.68, h * 0.93, w * 0.50, h * 0.93)
      ..quadraticBezierTo(w * 0.32, h * 0.93, w * 0.15, h * 0.80)
      ..close();

    final Paint bodyFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color.lerp(tint, Colors.white, 0.30)!,
          tint,
          Color.lerp(tint, Colors.black, 0.38)!,
        ],
        stops: const <double>[0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawPath(body, bodyFill);
    canvas.drawPath(
      body,
      Paint()
        ..color = const Color(0xFF160A0C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.04
        ..strokeJoin = StrokeJoin.round,
    );

    // Tanduk di atas kepala.
    final Paint horn = Paint()
      ..color = Color.lerp(tint, Colors.black, 0.2)!;
    for (final double c in <double>[0.30, 0.50, 0.70]) {
      final Path spike = Path()
        ..moveTo(w * (c - 0.07), h * 0.31)
        ..lineTo(w * c, h * 0.09)
        ..lineTo(w * (c + 0.07), h * 0.31)
        ..close();
      canvas.drawPath(spike, horn);
      canvas.drawPath(
        spike,
        Paint()
          ..color = const Color(0xFF160A0C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.02
          ..strokeJoin = StrokeJoin.round,
      );
    }

    if (defeated) {
      _drawDeadEyes(canvas, w, h);
    } else {
      _drawEyes(canvas, w, h);
    }
    _drawMouth(canvas, w, h);

    // Kilat putih saat terkena serangan.
    if (flash > 0) {
      canvas.drawPath(
        body,
        Paint()..color = Colors.white.withValues(alpha: flash * 0.8),
      );
    }
  }

  void _drawEyes(Canvas canvas, double w, double h) {
    final Paint white = Paint()..color = Colors.white;
    final Paint pupil = Paint()..color = const Color(0xFF160A0C);
    final double ey = h * 0.52;
    for (final double dx in <double>[-0.15, 0.15]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(w * (0.5 + dx), ey),
          width: w * 0.24,
          height: h * 0.21,
        ),
        white,
      );
      canvas.drawCircle(
        Offset(w * (0.5 + dx * 0.7), ey + h * 0.015),
        w * 0.058,
        pupil,
      );
    }
    // Alis marah.
    final Paint brow = Paint()
      ..color = const Color(0xFF160A0C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(w * 0.32, h * 0.40), Offset(w * 0.44, h * 0.46), brow);
    canvas.drawLine(Offset(w * 0.68, h * 0.40), Offset(w * 0.56, h * 0.46), brow);
  }

  void _drawDeadEyes(Canvas canvas, double w, double h) {
    final Paint stroke = Paint()
      ..color = const Color(0xFF160A0C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.05
      ..strokeCap = StrokeCap.round;
    final double ey = h * 0.53;
    for (final double dx in <double>[-0.15, 0.15]) {
      final Offset c = Offset(w * (0.5 + dx), ey);
      final double r = w * 0.08;
      canvas.drawLine(c.translate(-r, -r), c.translate(r, r), stroke);
      canvas.drawLine(c.translate(r, -r), c.translate(-r, r), stroke);
    }
  }

  void _drawMouth(Canvas canvas, double w, double h) {
    final Rect mouth = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.68),
      width: w * 0.46,
      height: h * 0.26,
    );
    canvas.drawArc(
      mouth,
      math.pi * 0.06,
      math.pi * 0.88,
      true,
      Paint()..color = const Color(0xFF270A0E),
    );
    final Paint tooth = Paint()..color = Colors.white;
    for (final double dx in <double>[-0.15, 0.0, 0.15]) {
      final Path t = Path()
        ..moveTo(w * (0.5 + dx - 0.045), h * 0.63)
        ..lineTo(w * (0.5 + dx), h * 0.72)
        ..lineTo(w * (0.5 + dx + 0.045), h * 0.63)
        ..close();
      canvas.drawPath(t, tooth);
    }
  }

  @override
  bool shouldRepaint(covariant _MonsterPainter oldDelegate) =>
      oldDelegate.flash != flash ||
      oldDelegate.defeated != defeated ||
      oldDelegate.tint != tint;
}
