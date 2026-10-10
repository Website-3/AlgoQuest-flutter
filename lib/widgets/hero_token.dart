import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================
// HERO TOKEN — KARAKTER PEMAIN
// ============================================================
// Gambar karakter berupa orang (bukan kursor) lengkap dengan
// helm, mata, badan, lengan, kaki, dan pedang. Ada juga panah
// arah hadap ("") di lantai yang ikut berputar sesuai arah
// karakter menghadap (0 = atas, 1 = kanan, 2 = bawah, 3 = kiri).
// Widget ini dipakai bersama oleh Mode Petualangan dan
// Mode Arena Logika supaya tampilannya konsisten.

const Color _kCyan = Color(0xFF42CFFF);

class HeroToken extends StatelessWidget {
  const HeroToken({
    super.key,
    required this.size,
    this.facing = 1,
    this.arrowColor = _kCyan,
    this.showArrow = true,
  });

  /// Ukuran sisi kotak karakter (persegi).
  final double size;

  /// 0 = atas, 1 = kanan, 2 = bawah, 3 = kiri.
  final int facing;

  /// Warna panah penunjuk arah.
  final Color arrowColor;

  /// Sembunyikan panah arah (misal saat bertarung).
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          if (showArrow)
            Positioned.fill(
              child: Transform.rotate(
                angle: (facing - 1) * math.pi / 2,
                child: CustomPaint(
                  painter: _FacingPainter(
                    color: arrowColor.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: CustomPaint(painter: const _HeroPainter()),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// PELUKIS KARAKTER
// ------------------------------------------------------------
class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;

    // Bayangan di lantai
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.94),
        width: s * 0.64,
        height: s * 0.15,
      ),
      Paint()..color = Colors.black.withValues(alpha: 0.38),
    );

    // Garis tepi gelap (membuat karakter menonjol dari latar).
    final Paint outline = Paint()
      ..color = const Color(0xFF0C1522)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.026
      ..strokeJoin = StrokeJoin.round;

    // Jubah di belakang badan.
    final Path cape = Path()
      ..moveTo(s * 0.30, s * 0.44)
      ..quadraticBezierTo(s * 0.16, s * 0.68, s * 0.24, s * 0.85)
      ..lineTo(s * 0.76, s * 0.85)
      ..quadraticBezierTo(s * 0.84, s * 0.68, s * 0.70, s * 0.44)
      ..close();
    canvas.drawPath(cape, Paint()..color = const Color(0xFF1C5470));
    canvas.drawPath(
      cape,
      Paint()
        ..color = const Color(0xFF0C1522)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.02
        ..strokeJoin = StrokeJoin.round,
    );

    // Kaki
    final Paint leg = Paint()..color = const Color(0xFF23324C);
    final RRect legL = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.35, s * 0.64, s * 0.12, s * 0.26),
      Radius.circular(s * 0.05),
    );
    final RRect legR = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.53, s * 0.64, s * 0.12, s * 0.26),
      Radius.circular(s * 0.05),
    );
    canvas.drawRRect(legL, leg);
    canvas.drawRRect(legR, leg);
    canvas.drawRRect(legL, outline);
    canvas.drawRRect(legR, outline);

    // Pedang (di sisi kanan)
    final RRect blade = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.79, s * 0.14, s * 0.055, s * 0.34),
      Radius.circular(s * 0.03),
    );
    canvas.drawRRect(
      blade,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFFFFFFFF), Color(0xFF9FB4BE)],
        ).createShader(Rect.fromLTWH(s * 0.79, s * 0.14, s * 0.055, s * 0.34)),
    );
    canvas.drawRRect(blade, outline..strokeWidth = s * 0.018);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.72, s * 0.46, s * 0.19, s * 0.05),
        Radius.circular(s * 0.02),
      ),
      Paint()..color = const Color(0xFFC08A2E),
    );

    // Lengan
    final Paint arm = Paint()..color = const Color(0xFF2F8FC4);
    final RRect armL = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.17, s * 0.45, s * 0.14, s * 0.24),
      Radius.circular(s * 0.07),
    );
    final RRect armR = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.69, s * 0.45, s * 0.14, s * 0.24),
      Radius.circular(s * 0.07),
    );
    canvas.drawRRect(armL, arm);
    canvas.drawRRect(armR, arm);
    canvas.drawRRect(armL, outline..strokeWidth = s * 0.022);
    canvas.drawRRect(armR, outline);

    // Badan (bergradasi agar terlihat bervolume)
    final RRect bodyRR = RRect.fromRectAndRadius(
      Rect.fromLTWH(s * 0.29, s * 0.42, s * 0.42, s * 0.29),
      Radius.circular(s * 0.1),
    );
    canvas.drawRRect(
      bodyRR,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF6FDFFF), Color(0xFF2E9FCF)],
        ).createShader(Rect.fromLTWH(s * 0.29, s * 0.42, s * 0.42, s * 0.29)),
    );
    canvas.drawRRect(bodyRR, outline..strokeWidth = s * 0.024);
    // Kilau badan
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(s * 0.34, s * 0.45, s * 0.12, s * 0.06),
        Radius.circular(s * 0.03),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    // Sabuk
    canvas.drawRect(
      Rect.fromLTWH(s * 0.29, s * 0.635, s * 0.42, s * 0.04),
      Paint()..color = const Color(0xFF1B6E8C),
    );

    // Kepala
    final Offset head = Offset(s * 0.5, s * 0.29);
    canvas.drawCircle(
      head,
      s * 0.19,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.3, -0.4),
          radius: 0.95,
          colors: <Color>[Color(0xFFFFE4C6), Color(0xFFF0C296)],
        ).createShader(Rect.fromCircle(center: head, radius: s * 0.19)),
    );
    canvas.drawCircle(
      head,
      s * 0.19,
      Paint()
        ..color = const Color(0xFF0C1522)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.024,
    );
    // Helm / rambut
    canvas.drawArc(
      Rect.fromCircle(center: head, radius: s * 0.19),
      math.pi * 1.02,
      math.pi * 0.96,
      true,
      Paint()..color = const Color(0xFF22314A),
    );
    // Mata
    final Paint eye = Paint()..color = const Color(0xFF14232E);
    canvas.drawCircle(Offset(s * 0.435, s * 0.30), s * 0.028, eye);
    canvas.drawCircle(Offset(s * 0.565, s * 0.30), s * 0.028, eye);
    // Senyum
    canvas.drawArc(
      Rect.fromCircle(center: Offset(s * 0.5, s * 0.345), radius: s * 0.06),
      0.25,
      math.pi - 0.5,
      false,
      Paint()
        ..color = const Color(0xFF14232E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.022
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _HeroPainter oldDelegate) => false;
}

/// Panah penunjuk arah hadap karakter (di atas lantai).
class _FacingPainter extends CustomPainter {
  final Color color;

  _FacingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Path path = Path()
      ..moveTo(s * 0.24, s * 0.16)
      ..lineTo(s * 0.84, s * 0.5)
      ..lineTo(s * 0.24, s * 0.84);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.13
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _FacingPainter oldDelegate) =>
      oldDelegate.color != color;
}