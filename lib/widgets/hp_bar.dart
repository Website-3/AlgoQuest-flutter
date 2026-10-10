import 'package:flutter/material.dart';

// ============================================================
// HP BAR — bilah kesehatan (pemain / monster)
// ============================================================

class HpBar extends StatelessWidget {
  const HpBar({
    super.key,
    required this.label,
    required this.icon,
    required this.ratio,
    required this.color,
    this.valueText,
  });

  final String label;
  final IconData icon;

  /// Nilai 0..1.
  final double ratio;
  final Color color;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final double clamped = ratio.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Row(
          children: <Widget>[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.6,
              ),
            ),
            const Spacer(),
            if (valueText != null)
              Text(
                valueText!,
                style: const TextStyle(
                  color: Color(0xFF8A9795),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            height: 9,
            color: const Color(0xFF0B100F),
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: clamped),
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              builder: (BuildContext context, double v, Widget? child) {
                return FractionallySizedBox(
                  widthFactor: v,
                  alignment: Alignment.centerLeft,
                  child: child,
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[color, color.withValues(alpha: 0.55)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}