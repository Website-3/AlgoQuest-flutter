import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/combat_service.dart';

void main() {
  // Pertarungan uji: pemain 100 HP, monster 50 HP, serangan tepat.
  CombatService make() => CombatService(
        playerMaxHp: 100,
        monsterMaxHp: 50,
        attackDmg: 20,
        skillDmg: 40,
        monsterDmg: 10,
        attackInterval: 1.4,
      );

  group('CombatService', () {
    test('startFight masuk fase tempur dengan HP penuh', () {
      final CombatService c = make();
      expect(c.phase, FightPhase.exploring);
      c.startFight();
      expect(c.phase, FightPhase.fighting);
      expect(c.playerHpRatio, 1.0);
      expect(c.monsterHpRatio, 1.0);
    });

    test('serangan mengurangi HP monster', () {
      final CombatService c = make()..startFight();
      c.attack();
      expect(c.attacking, isTrue);
      for (int i = 0; i < 12; i++) {
        c.update(0.05); // 0.6 dtk: animasi tuntas
      }
      // damage 20 + variasi 0..3
      expect(c.monsterHp, lessThan(50));
      expect(c.monsterHp, greaterThanOrEqualTo(50 - 23));
      expect(c.attacking, isFalse);
    });

    test('skill menimbulkan damage besar dan punya cooldown', () {
      final CombatService c = make()..startFight();
      c.skill();
      expect(c.skillCd, closeTo(CombatService.skillMaxCd, 1e-9));
      for (int i = 0; i < 12; i++) {
        c.update(0.05);
      }
      expect(c.monsterHp, 10); // 50 - 40
      // Saat cooldown, skill tidak menyerang lagi.
      c.skill();
      expect(c.attacking, isFalse);
      expect(c.skillReady, isFalse);
      expect(c.monsterHp, 10);
    });

    test('dodge tepat waktu membuat hantaman monster gagal', () {
      final CombatService c = make()..startFight();
      c.update(1.2); // memicu isyarat monster
      expect(c.monsterTelegraphing, isTrue);
      c.update(0.2); // sisa isyarat ~0.25 dtk
      c.dodge();
      for (int i = 0; i < 6; i++) {
        c.update(0.05); // hantaman mendarat
      }
      expect(c.playerHp, 100);
      expect(c.texts.any((FloatText t) => t.text == 'HINDAR!'), isTrue);
    });

    test('monster bisa mengalahkan pemain', () {
      final CombatService c = make()..startFight();
      for (int i = 0; i < 40 && c.phase == FightPhase.fighting; i++) {
        c.update(1.8);
      }
      expect(c.phase, FightPhase.lost);
      expect(c.playerHp, 0);
    });

    test('menyerang sampai habis membuat pemain menang', () {
      final CombatService c = make()..startFight();
      int guard = 0;
      while (c.phase == FightPhase.fighting && guard < 100) {
        c.attack();
        for (int i = 0; i < 12; i++) {
          c.update(0.05);
        }
        guard++;
      }
      expect(c.phase, FightPhase.won);
      expect(c.monsterHp, 0);
      expect(c.monsterDefeated, isTrue);
    });

    test('rematch mengisi ulang HP setelah kalah', () {
      final CombatService c = make()..startFight();
      for (int i = 0; i < 40 && c.phase == FightPhase.fighting; i++) {
        c.update(1.8);
      }
      expect(c.phase, FightPhase.lost);
      c.rematch();
      expect(c.phase, FightPhase.fighting);
      expect(c.playerHpRatio, 1.0);
      expect(c.monsterHpRatio, 1.0);
    });
  });
}