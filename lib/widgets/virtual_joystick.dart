import 'package:flutter/material.dart';

import 'package:flutter/gestures.dart' show DragStartBehavior;

// ============================================================
// JOYSTICK VIRTUAL
// ============================================================
// Analog arah untuk Mode Petualangan. Pemain menyeret knob di
// dalam lingkaran; gerakan diterjemahkan menjadi vektor
// ternormalisasi (-1..1) lewat [onChanged].

class VirtualJoystick extends StatefulWidget {
  const VirtualJoystick({
    super.key,
    required this.onChanged,
    this.size = 150,
  });

  /// Dipanggil tiap perubahan arah. `Offset.zero` saat dilepas.
  final ValueChanged<Offset> onChanged;
  final double size;

  @override
  State<VirtualJoystick> createState() => _VirtualJoystickState();
}

class _VirtualJoystickState extends State<VirtualJoystick> {
  /// Posisi knob relatif ke pusat, panjang maks = [_maxR].
  Offset _knob = Offset.zero;
  bool _active = false;

  double get _maxR => widget.size * 0.38;

  void _update(Offset localPos, Size box) {
    final Offset center = Offset(box.width / 2, box.height / 2);
    Offset v = localPos - center;
    if (v.distance > _maxR) v = v / v.distance * _maxR;
    setState(() {
      _knob = v;
      _active = true;
    });
    widget.onChanged(v / _maxR);
  }

  void _release() {
    if (_knob == Offset.zero) return;
    setState(() {
      _knob = Offset.zero;
      _active = false;
    });
    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final double s = widget.size;
    return GestureDetector(
      dragStartBehavior: DragStartBehavior.down,
      onPanStart: (DragStartDetails d) =>
          _update(d.localPosition, Size(s, s)),
      onPanUpdate: (DragUpdateDetails d) => _update(d.localPosition, Size(s, s)),
      onPanEnd: (_) => _release(),
      onPanCancel: _release,
      child: SizedBox(
        width: s,
        height: s,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Lingkaran dasar
            Container(
              width: s,
              height: s,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF101615),
                border: Border.all(
                  color: _active
                      ? const Color(0xFF42CFFF)
                      : const Color(0xFF2A3432),
                  width: 2,
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
            // Garis penunjuk arah
            CustomPaint(
              size: Size(s, s),
              painter: _JoystickGuidePainter(),
            ),
            // Knob
            AnimatedContainer(
              duration: const Duration(milliseconds: 80),
              width: s * 0.42,
              height: s * 0.42,
              transform: Matrix4.translationValues(_knob.dx, _knob.dy, 0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _active
                    ? const Color(0xFF42CFFF)
                    : const Color(0xFF1FA6D6),
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF42CFFF).withValues(alpha: 0.55),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_upward_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Garis silang halus di dasar joystick sebagai petunjuk arah.
class _JoystickGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint paint = Paint()
      ..color = const Color(0xFF2A3432).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final Offset c = Offset(s / 2, s / 2);
    final double r = s * 0.38;

    // Silang horizontal & vertikal (dalam lingkaran).
    canvas.drawLine(Offset(c.dx - r, c.dy), Offset(c.dx + r, c.dy), paint);
    canvas.drawLine(Offset(c.dx, c.dy - r), Offset(c.dx, c.dy + r), paint);
  }

  @override
  bool shouldRepaint(covariant _JoystickGuidePainter oldDelegate) => false;
}