import 'dart:math' as math;

import 'package:flutter/material.dart';

// ============================================================
// ACTION BUTTON — tombol aksi (Serang/Skill/Dodge) + cooldown
// ============================================================

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.cooldown = 0,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  /// Sisa cooldown (0..1); 0 = siap.
  final double cooldown;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final double cd = cooldown.clamp(0.0, 1.0);
    final bool ready = enabled && cd <= 0;
    return GestureDetector(
      onTap: ready ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: 62,
            height: 62,
            child: CustomPaint(
              painter: _CooldownPainter(
                color: color,
                cooldown: cd,
                faded: !ready,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 27,
                  color: ready ? color : color.withValues(alpha: 0.28),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: ready
                  ? const Color(0xFFDDE7E9)
                  : const Color(0xFF8A9795),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CooldownPainter extends CustomPainter {
  const _CooldownPainter({
    required this.color,
    required this.cooldown,
    required this.faded,
  });

  final Color color;
  final double cooldown;
  final bool faded;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset c = size.center(Offset.zero);
    final double r = size.shortestSide / 2 - 3;

    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = const Color(0xFF101615).withValues(alpha: 0.96)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = color.withValues(alpha: faded ? 0.22 : 0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    if (cooldown > 0) {
      // Sapuan kelabu menandakan sisa waktu cooldown (berputar searah jarum).
      final Rect ring = Rect.fromCircle(center: c, radius: r);
      canvas.drawArc(
        ring,
        -math.pi / 2,
        cooldown * 2 * math.pi,
        false,
        Paint()
          ..color = const Color(0xFF3A4442).withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CooldownPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cooldown != cooldown ||
      oldDelegate.faded != faded;
}