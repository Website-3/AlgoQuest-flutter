import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'game_service.dart';

// ============================================================
// MESIN PETUALANGAN — JELAJAH BEBAS DI LABIRIN
// ============================================================
// Pemain bergerak bebas (analog) di dalam labirin yang sudah
// dibuat MazeCatalog. Labirin adalah kumpulan sel (0 = lantai,
// 1 = dinding). Posisi pemain berupa koordinat sel (pecahan),
// jadi gerakannya halus. Collision memakai lingkaran kecil dan
// gerak per sumbu, sehingga pemain otomatis menempel/menusuri
// dinding tanpa menembusnya.
//
// Mode ini dipakai oleh Mode Petualangan (joystick + kamera
// + minimap). Kelas ini menerbitkan ChangeNotifier supaya
// tampilan ikut repaint tiap frame.

class AdventureService extends ChangeNotifier {
  AdventureService(this.level) {
    _x = level.start.col + 0.5;
    _y = level.start.row + 0.5;
    _facing = level.startDir;
    _markSeen();
  }

  final MazeLevel level;

  /// Jari-jari pemain dalam satuan sel (harus < 0.5 agar muat di lorong).
  static const double radius = 0.34;

  /// Radius pandang (dalam sel): sel di dalamnya terlihat terang.
  static const double visRadius = 2.6;

  /// Radius yang diperlihatkan minimap (lebih luas dari [visRadius]).
  static const double miniRadius = 4.4;

  /// Kecepatan berjalan (sel per detik).
  static const double speed = 4.2;

  /// Posisi pemain (dalam sel, bisa pecahan). Pusat di tengah sel.
  double _x = 1.0;
  double _y = 1.0;

  /// Arah hadap (0 = atas, 1 = kanan, 2 = bawah, 3 = kiri).
  int _facing = 1;

  /// Input analog, panjang maksimal 1.
  Offset _input = Offset.zero;

  /// Sel yang pernah terlihat (dijelajahi). Kunci = row*size+col.
  final Set<int> _seen = <int>{};

  double get x => _x;
  double get y => _y;
  int get facing => _facing;
  bool get moving => _input.distance > 0.05;

  /// Apakah sel pernah terlihat (untuk minimap & area redup).
  bool isSeen(int row, int col) =>
      row >= 0 &&
      col >= 0 &&
      row < level.size &&
      col < level.size &&
      _seen.contains(row * level.size + col);

  /// Setel arah joystick (vektor belum tentu ternormalisasi).
  void setInput(Offset v) {
    if (v.distance > 1) v = v / v.distance;
    _input = v;
    if (_input.distance > 0.05) {
      _facing = _facingFromVector(_input);
    }
  }

  /// Majukan simulasi sebanyak `dt` detik. Panggil tiap frame.
  void update(double dt) {
    if (dt <= 0) return;
    if (_input.distance < 0.05) return;

    final Offset dir = _input / _input.distance;
    final double dist = speed * dt * _input.distance.clamp(0.0, 1.0);

    _facing = _facingFromVector(_input);

    final double nx = _slide(_x, _y, dir.dx * dist, horizontal: true);
    final double ny = _slide(_y, nx, dir.dy * dist, horizontal: false);

    final bool changed = nx != _x || ny != _y;
    _x = nx;
    _y = ny;
    if (changed || _input.distance > 0.05) {
      _markSeen();
    }
    if (changed) notifyListeners();
  }

  /// Catat semua sel di sekitar pemain sebagai sudah terlihat.
  void _markSeen() {
    final int r0 = (_y - visRadius).floor().clamp(0, level.size - 1);
    final int r1 = (_y + visRadius).ceil().clamp(0, level.size - 1);
    final int c0 = (_x - visRadius).floor().clamp(0, level.size - 1);
    final int c1 = (_x + visRadius).ceil().clamp(0, level.size - 1);
    for (int r = r0; r <= r1; r++) {
      for (int c = c0; c <= c1; c++) {
        final double dx = (c + 0.5) - _x;
        final double dy = (r + 0.5) - _y;
        if (dx * dx + dy * dy <= visRadius * visRadius) {
          _seen.add(r * level.size + c);
        }
      }
    }
  }

  /// Kembalikan posisi ke awal (jelajah diulang dari nol).
  void reset() {
    _x = level.start.col + 0.5;
    _y = level.start.row + 0.5;
    _facing = level.startDir;
    _input = Offset.zero;
    _seen.clear();
    _markSeen();
    notifyListeners();
  }

  int _facingFromVector(Offset v) {
    if (v.dx.abs() > v.dy.abs()) {
      return v.dx > 0 ? 1 : 3;
    }
    return v.dy > 0 ? 2 : 0;
  }

  /// Gerakan satu sumbu dengan slide: maju sejauh `delta` sel, tetapi
  /// berhenti persis di tepi dinding terdekat.
  /// [pos] = koordinat yang digerakkan, [other] = koordinat tegak lurus.
  double _slide(double pos, double other, double delta,
      {required bool horizontal}) {
    if (delta == 0) return pos;
    final double target = pos + delta;

    final int minIdx = (other - radius).floor().clamp(0, level.size - 1);
    final int maxIdx = (other + radius).floor().clamp(0, level.size - 1);

    if (delta > 0) {
      // Gerak ke arah indeks bertambah (kanan / bawah).
      final int start = (pos + radius).ceil().clamp(0, level.size);
      double limit = double.infinity;
      for (int i1 = minIdx; i1 <= maxIdx; i1++) {
        for (int i2 = start; i2 <= level.size; i2++) {
          final bool wall = horizontal
              ? level.isWall(i1, i2)
              : level.isWall(i2, i1);
          if (!wall) continue;
          final double stop = i2.toDouble() - radius;
          if (stop < limit) limit = stop;
        }
      }
      final double result = math.min(target, limit);
      return result < pos ? pos : result;
    } else {
      // Gerak ke arah indeks berkurang (kiri / atas).
      final int start = (pos - radius).floor().clamp(-1, level.size - 1);
      double limit = -double.infinity;
      for (int i1 = minIdx; i1 <= maxIdx; i1++) {
        for (int i2 = start; i2 >= -1; i2--) {
          final bool wall = horizontal
              ? level.isWall(i1, i2)
              : level.isWall(i2, i1);
          if (!wall) continue;
          final double stop = (i2 + 1).toDouble() + radius;
          if (stop > limit) limit = stop;
        }
      }
      final double result = math.max(target, limit);
      return result > pos ? pos : result;
    }
  }

  /// Jarak (dalam sel) antara pemain dan monster.
  double get distanceToMonster {
    final double dx = (level.monster.col + 0.5) - _x;
    final double dy = (level.monster.row + 0.5) - _y;
    return math.sqrt(dx * dx + dy * dy);
  }
}