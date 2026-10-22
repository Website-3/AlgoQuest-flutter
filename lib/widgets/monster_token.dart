import 'package:flutter/material.dart';

// ============================================================
// MONSTER TOKEN â€” IBLIS BERTANDUK (memakai gambar PNG)
// ============================================================
// Bayangan lantai, kilat putih saat terkena serangan, dan mata X saat
// kalah tetap dipertahankan. Tubuh monster berasal dari gambar.
// API widget tidak berubah (size, flash, defeated, tint), jadi dipakai
// bersama Arena Logika tanpa perubahan di sana.

// ---------- SETELAN GAMBAR (ubah di sini) ----------
/// Nama file gambar monster di assets/images/ (ganti sesuai nama file aslimu).
const String _kMonsterAsset = 'assets/images/monster.png';

/// Seberapa besar gambar di dalam kotak (1.0 = penuh).
const double _kImageScale = 1.0;

/// Geser gambar ke atas/bawah (pecahan ukuran). Negatif = naik.
const double _kImageYOffset = 0.0;

/// Warna cahaya api di belakang monster.
const Color _kAura = Color(0xFFFF6A1F);

/// Tampilkan tanda X di mata saat monster kalah.
const bool _kShowDeadEyes = true;

/// Posisi mata di gambar (pecahan 0..1 dari kotak). Geser kalau X
/// tidak pas di atas mata iblisnya.
const Offset _kEyeLeft = Offset(0.42, 0.38);
const Offset _kEyeRight = Offset(0.58, 0.38);

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

  /// Sudah kalah: gambar jadi abu-abu dan mata berubah menjadi X.
  final bool defeated;

  /// Warna pengenal monster (dipakai untuk ikon cadangan).
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final double f = flash.clamp(0.0, 1.0);

    Widget img = Image.asset(
      _kMonsterAsset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, _, _) =>
          Icon(Icons.pest_control, size: size * 0.8, color: tint),
    );

    // Kalah: abu-abu dan agak gelap.
    if (defeated) {
      img = ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.28, 0.55, 0.10, 0, -20, //
          0.28, 0.55, 0.10, 0, -20,
          0.28, 0.55, 0.10, 0, -20,
          0, 0, 0, 1, 0,
        ]),
        child: img,
      );
    }

    // Kilat putih saat terkena serangan (hanya di bentuk monster,
    // bagian transparan tidak ikut putih).
    if (f > 0) {
      img = ColorFiltered(
        colorFilter: ColorFilter.mode(
          Colors.white.withValues(alpha: f * 0.85),
          BlendMode.srcATop,
        ),
        child: img,
      );
    }

    return RepaintBoundary(
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: <Widget>[
            // Cahaya api + bayangan lantai + cincin merah
            Positioned.fill(
              child: CustomPaint(painter: _GroundPainter(defeated: defeated)),
            ),
            // Monster dari gambar
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
            // Tanda seru (!) merah di atas kepala monster (seperti di referensi RPG)
            if (!defeated)
              Positioned(
                top: -size * 0.16,
                child: Container(
                  width: size * 0.22,
                  height: size * 0.22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2A3C),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF2A3C).withValues(alpha: 0.75),
                        blurRadius: 8,
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.14,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            // Mata X saat kalah
            if (defeated && _kShowDeadEyes)
              const Positioned.fill(
                child: CustomPaint(painter: _DeadEyesPainter()),
              ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// BAYANGAN LANTAI + CAHAYA API
// ------------------------------------------------------------
class _GroundPainter extends CustomPainter {
  const _GroundPainter({required this.defeated});

  final bool defeated;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // cahaya api di belakang monster (padam saat kalah)
    if (!defeated) {
      final Offset c = Offset(w * 0.5, h * 0.5);
      canvas.drawCircle(
        c,
        w * 0.5,
        Paint()
          ..isAntiAlias = true
          ..shader = RadialGradient(
            colors: <Color>[
              _kAura.withValues(alpha: 0.22),
              _kAura.withValues(alpha: 0.0),
            ],
          ).createShader(Rect.fromCircle(center: c, radius: w * 0.5)),
      );
    }

    // Cincin lantai merah bercahaya (seperti di referensi RPG)
    if (!defeated) {
      final Offset ringCenter = Offset(w * 0.5, h * 0.92);
      final Rect ringRect = Rect.fromCenter(
        center: ringCenter,
        width: w * 0.72,
        height: w * 0.28,
      );
      // Glow cincin luar
      canvas.drawOval(
        ringRect,
        Paint()
          ..color = const Color(0xFFFF2A3C).withValues(alpha: 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.04
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.035)
          ..isAntiAlias = true,
      );
      // Garis cincin tajam
      canvas.drawOval(
        ringRect,
        Paint()
          ..color = const Color(0xFFFF3B4E).withValues(alpha: 0.95)
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.025
          ..isAntiAlias = true,
      );
    }

    // bayangan di lantai
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.5, h * 0.93),
        width: w * 0.74,
        height: h * 0.15,
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.40)
        ..isAntiAlias = true
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.03),
    );
  }

  @override
  bool shouldRepaint(covariant _GroundPainter oldDelegate) =>
      oldDelegate.defeated != defeated;
}

// ------------------------------------------------------------
// MATA X (saat kalah)
// ------------------------------------------------------------
class _DeadEyesPainter extends CustomPainter {
  const _DeadEyesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double r = w * 0.04;

    final Paint outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;
    final Paint cross = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.025
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    for (final Offset e in <Offset>[_kEyeLeft, _kEyeRight]) {
      final Offset c = Offset(w * e.dx, h * e.dy);
      for (final Paint p in <Paint>[outline, cross]) {
        canvas.drawLine(c.translate(-r, -r), c.translate(r, r), p);
        canvas.drawLine(c.translate(r, -r), c.translate(-r, r), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DeadEyesPainter oldDelegate) => false;
}