import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/adventure_service.dart';
import 'package:flutter_application_1/services/game_service.dart';

void main() {
  group('AdventureService', () {
    // Labirin uji 5x5 terbuka (semua lantai) dan yang berisi dinding.
    MazeLevel openLevel({bool rightWall = false}) {
      final List<List<bool>> walls =
          List<List<bool>>.generate(5, (_) => List<bool>.filled(5, false));
      if (rightWall) walls[1][2] = true;
      return MazeLevel(
        region: 0,
        level: 0,
        size: 5,
        walls: walls,
        start: const Pos(1, 1),
        startDir: 1,
        monster: const Pos(3, 3),
        enemyHp: 1,
        par: 2,
        maxBlocks: 3,
        solution: const <GameCommand>[],
        monsterId: 'Uji',
        monsterEn: 'Test',
      );
    }

    test('mulai di tengah sel awal', () {
      final AdventureService s = AdventureService(openLevel());
      expect(s.x, closeTo(1.5, 1e-9));
      expect(s.y, closeTo(1.5, 1e-9));
      expect(s.moving, isFalse);
    });

    test('bergerak ke kanan dan menghadap kanan', () {
      final AdventureService s = AdventureService(openLevel());
      s.setInput(const Offset(1, 0));
      s.update(0.25);
      expect(s.x, greaterThan(1.5));
      expect(s.y, closeTo(1.5, 1e-6));
      expect(s.facing, 1);
    });

    test('dinding menghentikan gerakan', () {
      final AdventureService s = AdventureService(openLevel(rightWall: true));
      s.setInput(const Offset(1, 0));
      s.update(3); // cukup lama, bakal mentok
      // Wall di sel (1,2) mulai dari x=2; lingkaran r=0.34 mentok di
      // sekitar x = 2 - 0.34 = 1.66.
      expect(s.x, lessThan(1.7));
      expect(s.x, greaterThan(1.6));
    });

    test('hadap mengikuti arah input', () {
      final AdventureService s = AdventureService(openLevel());
      s.setInput(const Offset(-1, 0));
      expect(s.facing, 3); // kiri
      s.setInput(const Offset(0, 1));
      expect(s.facing, 2); // bawah
      s.setInput(const Offset(0, -1));
      expect(s.facing, 0); // atas
      s.setInput(const Offset(3, 1)); // diagonal dominan kanan
      expect(s.facing, 1);
    });

    test('setInput membatasi panjang vektor ke 1', () {
      final AdventureService s = AdventureService(openLevel());
      s.setInput(const Offset(5, 0));
      s.update(0.01);
      // Input 5 dinormalisasi ke 1, jadi jarak tempuh <= speed*dt
      // = 4.2 * 0.01 = 0.042 sel.
      expect(s.x - 1.5, lessThanOrEqualTo(0.05));
      expect(s.x, lessThan(1.55));
    });

    test('reset mengembalikan posisi awal', () {
      final AdventureService s = AdventureService(openLevel());
      s.setInput(const Offset(1, 0));
      s.update(0.5);
      s.reset();
      expect(s.x, closeTo(1.5, 1e-9));
      expect(s.y, closeTo(1.5, 1e-9));
    });

    test('fog of war: sel dekat terlihat, yang jauh belum', () {
      final AdventureService s = AdventureService(openLevel());
      // Pemain di pusat sel (1,1). Monster (3,3) berjarak ~2.83 sel
      // > visRadius (2.6) → belum terlihat.
      expect(s.isSeen(1, 1), isTrue);
      expect(s.isSeen(1, 2), isTrue);
      expect(s.isSeen(3, 3), isFalse);
    });

    test('menjelajah memperluas area yang terlihat', () {
      final AdventureService s = AdventureService(openLevel());
      expect(s.isSeen(3, 3), isFalse);
      s.setInput(const Offset(1, 0));
      for (int i = 0; i < 40; i++) {
        s.update(0.05); // ~2 dtk ke kanan
      }
      expect(s.x, greaterThan(3.5));
      expect(s.isSeen(3, 3), isTrue);
    });

    test('reset menghapus area yang sudah dijelajahi', () {
      final AdventureService s = AdventureService(openLevel());
      s.setInput(const Offset(1, 0));
      for (int i = 0; i < 40; i++) {
        s.update(0.05);
      }
      expect(s.isSeen(3, 3), isTrue);
      s.reset();
      expect(s.isSeen(3, 3), isFalse);
    });
  });
}