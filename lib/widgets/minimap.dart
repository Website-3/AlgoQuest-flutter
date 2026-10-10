import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/adventure_service.dart';

// ============================================================
// MINIMAP — PETUNJUK LOKAL
// ============================================================
// Menampilkan bagian labirin di sekitar pemain dalam radius
// [AdventureService.miniRadius] (lebih luas daripada area
// pandang, tetapi tidak seluruh peta). Sel yang belum pernah
// dijelajahi tetap gelap; monster hanya muncul bila sudah
// pernah terlihat. Posisi & arah pemain ditandai panah.

const Color _kLine = Color(0xFF2A3432);
const Color _kCyan = Color(0xFF42CFFF);
const Color _kYellow = Color(0xFFFFB21A);
const Color _kRed = Color(0xFFB02A32);
const Color _kFloor = Color(0xFF18211F);
const Color _kWall = Color(0xFF3A4A46);

class Minimap extends StatelessWidget {
  const Minimap({
    super.key,
    required this.service,
    this.cellPx = 8,
    this.showMonster = true,
  });

  final AdventureService service;
  final double cellPx;

  /// false bila monster sudah dikalahkan.
  final bool showMonster;

  @override
  Widget build(BuildContext context) {
    final double half = AdventureService.miniRadius;
    final int sizeCells = (2 * half + 2).ceil();
    final double size = sizeCells * cellPx;
    return CustomPaint(
      size: Size.square(size),
      painter: _MinimapPainter(
        service: service,
        cellPx: cellPx,
        showMonster: showMonster,
      ),
    );
  }
}

class _MinimapPainter extends CustomPainter {
  const _MinimapPainter({
    required this.service,
    required this.cellPx,
    required this.showMonster,
  });

  final AdventureService service;
  final double cellPx;
  final bool showMonster;

  @override
  void paint(Canvas canvas, Size size) {
    final double half = AdventureService.miniRadius;

    // Latar minimap.
    final RRect bg = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(10),
    );
    canvas.drawRRect(
      bg,
      Paint()..color = const Color(0xFF0B100F).withValues(alpha: 0.88),
    );

    final int c0 = (service.x - half).floor();
    final int c1 = (service.x + half).ceil();
    final int r0 = (service.y - half).floor();
    final int r1 = (service.y + half).ceil();

    final Paint floorPaint = Paint()..color = _kFloor;
    final Paint wallPaint = Paint()..color = _kWall;

    for (int r = math.max(0, r0); r <= math.min(service.level.size - 1, r1); r++) {
      for (int c = math.max(0, c0);
          c <= math.min(service.level.size - 1, c1);
          c++) {
        if (!service.isSeen(r, c)) continue;
        final Rect cell = Rect.fromLTWH(
          (c - c0) * cellPx,
          (r - r0) * cellPx,
          cellPx,
          cellPx,
        );
        canvas.drawRect(
          cell.deflate(0.6),
          service.level.walls[r][c] ? wallPaint : floorPaint,
        );
      }
    }

    // Monster (hanya kalau pernah terlihat & belum dikalahkan).
    final int mRow = service.level.monster.row;
    final int mCol = service.level.monster.col;
    if (showMonster && service.isSeen(mRow, mCol)) {
      final Offset mCenter = Offset(
        (mCol - c0 + 0.5) * cellPx,
        (mRow - r0 + 0.5) * cellPx,
      );
      canvas.drawCircle(mCenter, cellPx * 0.34, Paint()..color = _kRed);
      canvas.drawCircle(
        mCenter,
        cellPx * 0.34,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );
    }

    // Pemain (panah arah).
    final Offset pCenter = Offset(
      (service.x - c0) * cellPx,
      (service.y - r0) * cellPx,
    );
    canvas.save();
    canvas.translate(pCenter.dx, pCenter.dy);
    canvas.rotate((service.facing - 1) * math.pi / 2);
    final Path arrow = Path()
      ..moveTo(0, -cellPx * 0.42)
      ..lineTo(cellPx * 0.4, 0)
      ..lineTo(0, cellPx * 0.42)
      ..lineTo(-cellPx * 0.18, 0)
      ..close();
    canvas.drawPath(arrow, Paint()..color = _kYellow);
    canvas.drawCircle(
        Offset.zero, cellPx * 0.3, Paint()..color = _kCyan);
    canvas.drawCircle(
      Offset.zero,
      cellPx * 0.3,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
    canvas.restore();

    // Bingkai.
    canvas.drawRRect(
      bg,
      Paint()
        ..color = _kLine
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6,
    );
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter oldDelegate) =>
      oldDelegate.service != service ||
      oldDelegate.cellPx != cellPx ||
      oldDelegate.showMonster != showMonster;
}