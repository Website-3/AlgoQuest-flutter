import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================
// HERO TOKEN — KSATRIA (memakai gambar PNG)
// ============================================================
// Bayangan lantai, cahaya cyan, dan panah arah tetap dipertahankan.
// Tubuh karakter berasal dari gambar. API widget tidak berubah
// (size, facing, arrowColor, showArrow), jadi adventure_page.dart
// tidak perlu diubah.

const Color _kCyan = Color(0xFF42CFFF);

// ---------- SETELAN GAMBAR (ubah di sini) ----------
/// Nama file gambar hero di assets/images/ (ganti sesuai nama file aslimu).
const String _kHeroAsset = 'assets/images/hero.png';

/// Ksatria ini condong menghadap kiri (pedang di sisi kiri gambar).
/// Kalau saat jalan ke kanan terlihat aneh, ubah jadi true.
const bool _kImageFacesRight = false;

/// Seberapa besar gambar di dalam kotak (1.0 = penuh).
const double _kImageScale = 1.0;

/// Geser gambar ke atas/bawah (pecahan ukuran). Negatif = naik.
const double _kImageYOffset = 0.0;

/// Panah arah di lantai. Ubah ke false kalau terasa mengganggu.
const bool _kShowFacingArrow = true;

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

  /// Sembunyikan panah arah.
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    // Balik gambar saat hero menghadap sisi yang berlawanan
    // dengan arah asli gambar.
    final bool flip = _kImageFacesRight ? facing == 3 : facing == 1;

    Widget img = Image.asset(
      _kHeroAsset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) =>
          Icon(Icons.shield, size: size * 0.8, color: arrowColor),
    );
    if (flip) {
      img = Transform.flip(flipX: true, child: img);
    }

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Bayangan + cahaya cyan di lantai
            const Positioned.fill(
              child: CustomPaint(painter: _GroundPainter()),
            ),
            // Panah arah hadap
            if (showArrow && _kShowFacingArrow)
              Positioned.fill(
                child: Transform.rotate(
                  angle: (facing - 1) * math.pi / 2,
                  child: CustomPaint(
                    isComplex: true,
                    painter: _FacingPainter(color: arrowColor),
                  ),
                ),
              ),
            // Ksatria dari gambar
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(0, size * _kImageYOffset),
                child: Transform.scale(
                  scale: _kImageScale,
                  alignment: Alignment.bottomCenter,
                  child: img,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// BAYANGAN & CAHAYA LANTAI
// ------------------------------------------------------------
class _GroundPainter extends CustomPainter {
  const _GroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;

    // cahaya cyan halus di belakang karakter
    final Offset c = Offset(s * 0.5, s * 0.55);
    canvas.drawCircle(
      c,
      s * 0.42,
      Paint()
        ..isAntiAlias = true
        ..shader = RadialGradient(
          colors: <Color>[
            _kCyan.withValues(alpha: 0.20),
            _kCyan.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromCircle(center: c, radius: s * 0.42)),
    );

    // bayangan lantai (berlapis)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.94),
        width: s * 0.74,
        height: s * 0.17,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..isAntiAlias = true
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.035),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.935),
        width: s * 0.48,
        height: s * 0.09,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.45)
        ..isAntiAlias = true
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.02),
    );
  }

  @override
  bool shouldRepaint(covariant _GroundPainter oldDelegate) => false;
}

// ------------------------------------------------------------
// PANAH ARAH HADAP (sama seperti versi lama)
// ------------------------------------------------------------
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

    // glow lembut
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.15
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.04),
    );
    // garis panah
    canvas.drawPath(
      path,
      Paint()
        ..color = color.withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.10
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
    // highlight tipis di tengah panah
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.025
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..isAntiAlias = true,
    );
  }

  @override
  bool shouldRepaint(covariant _FacingPainter oldDelegate) =>
      oldDelegate.color != color;
}