import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;

// ============================================================
// COMBAT SERVICE — PERTEMPURAN REAL-TIME
// ============================================================
// Alur: jelajah (exploring) → ketemu monster → TEMPUR (fighting)
// → menang (won) / kalah (lost). Pemain punya 3 aksi dengan
// cooldown: Serang, Skill, Dodge (jendela kebal singkat). Monster
// punya AI: setiap beberapa detik memberi isyarat lalu menerkam;
// mengelak tepat waktu akan membuat hantaman gagal.

enum FightPhase { exploring, fighting, won, lost }

/// Teks melayang (angka damage / HINDAR!).
class FloatText {
  FloatText({
    required this.text,
    required this.color,
    required this.atMonster,
  });

  final String text;
  final Color color;

  /// true → muncul di posisi monster; false → di posisi pemain.
  final bool atMonster;

  /// Kemajuan 0..1 (naik selama [duration]).
  double t = 0;

  static const double duration = 0.9;
}

class CombatService extends ChangeNotifier {
  CombatService({
    required this.playerMaxHp,
    required this.monsterMaxHp,
    required this.attackDmg,
    required this.skillDmg,
    required this.monsterDmg,
    required this.attackInterval,
  });

  /// Statistik naik sesuai wilayah & level (0..24).
  factory CombatService.forLevel(int region, int level) {
    final int d = region * 5 + level;
    return CombatService(
      playerMaxHp: 100 + d * 2,
      monsterMaxHp: 45 + d * 6,
      attackDmg: 9 + d,
      skillDmg: 22 + d * 2,
      monsterDmg: 7 + (d ~/ 2),
      attackInterval: math.max(1.2, 1.9 - d * 0.02),
    );
  }

  final int playerMaxHp;
  final int monsterMaxHp;
  final int attackDmg;
  final int skillDmg;
  final int monsterDmg;
  final double attackInterval;

  final math.Random _rng = math.Random();

  static const double skillMaxCd = 6; // detik
  static const double dodgeMaxCd = 2.5; // detik
  static const double dodgeDuration = 0.7; // lama kebal saat mengelak
  static const double attackAnim = 0.45; // durasi animasi serangan pemain
  static const double teleDuration = 0.45; // isyarat monster sebelum hantaman
  static const double lungeDuration = 0.32; // durasi menerkam monster

  FightPhase phase = FightPhase.exploring;

  double playerHp = 0;
  double monsterHp = 0;

  double skillCd = 0;
  double dodgeCd = 0;
  double dodgeWindow = 0;

  // Animasi & status serangan pemain.
  double attackT = 0; // 0 = diam, lalu naik ke 1
  bool isSkill = false;
  bool _attackApplied = false;

  // AI monster.
  double monsterTimer = 1.2; // jeda ke isyarat berikutnya
  double teleTimer = 0; // > 0 artinya monster memberi isyarat
  double monsterLungeT = 0; // animasi menerkam

  // Efek saat monster kena.
  double shakeT = 0;
  double flashT = 0;
  bool monsterDefeated = false;

  final List<FloatText> texts = <FloatText>[];

  bool get isFighting => phase == FightPhase.fighting;
  bool get attacking => attackT > 0;
  bool get monsterTelegraphing => teleTimer > 0;

  double get playerHpRatio => playerHp / playerMaxHp;
  double get monsterHpRatio => monsterHp / monsterMaxHp;
  double get skillCdRatio => skillCd / skillMaxCd;
  double get dodgeCdRatio => dodgeCd / dodgeMaxCd;
  bool get skillReady => skillCd <= 0 && attackT <= 0;
  bool get dodgeReady => dodgeCd <= 0;

  // ----------------------------------------------------------
  // Aksi
  // ----------------------------------------------------------
  void startFight() {
    phase = FightPhase.fighting;
    playerHp = playerMaxHp.toDouble();
    monsterHp = monsterMaxHp.toDouble();
    _resetTimers();
    notifyListeners();
  }

  /// Ulangi setelah kalah.
  void rematch() {
    phase = FightPhase.fighting;
    playerHp = playerMaxHp.toDouble();
    monsterHp = monsterMaxHp.toDouble();
    _resetTimers();
    notifyListeners();
  }

  /// Setelah menang: kembali jelajah (monster sudah dikalahkan).
  void continueExploring() {
    phase = FightPhase.exploring;
    monsterDefeated = true;
    _resetTimers();
    texts.clear();
    notifyListeners();
  }

  void attack() {
    if (!isFighting || attackT > 0) return;
    attackT = 0.0001;
    isSkill = false;
    _attackApplied = false;
    notifyListeners();
  }

  void skill() {
    if (!isFighting || attackT > 0 || !skillReady) return;
    skillCd = skillMaxCd;
    attackT = 0.0001;
    isSkill = true;
    _attackApplied = false;
    notifyListeners();
  }

  void dodge() {
    if (!isFighting || !dodgeReady) return;
    dodgeCd = dodgeMaxCd;
    dodgeWindow = dodgeDuration;
    addText('HINDAR!', const Color(0xFF42CFFF), atMonster: false);
    notifyListeners();
  }

  void addText(String text, Color color, {required bool atMonster}) {
    texts.removeWhere(
        (FloatText t) => t.text == text && t.atMonster == atMonster);
    texts.add(FloatText(text: text, color: color, atMonster: atMonster));
    if (texts.length > 8) texts.removeAt(0);
  }

  // ----------------------------------------------------------
  // Simulasi per detik (dipanggil ticker halaman)
  // ----------------------------------------------------------
  void update(double dt) {
    skillCd = math.max(0.0, skillCd - dt);
    dodgeCd = math.max(0.0, dodgeCd - dt);
    dodgeWindow = math.max(0.0, dodgeWindow - dt);
    shakeT = math.max(0.0, shakeT - dt);
    flashT = math.max(0.0, flashT - dt);

    for (final FloatText t in texts) {
      t.t += dt / FloatText.duration;
    }
    texts.removeWhere((FloatText t) => t.t >= 1);

    if (!isFighting) return;

    // ---- Serangan pemain ----
    if (attackT > 0) {
      attackT += dt / attackAnim;
      if (attackT >= 0.5 && !_attackApplied) {
        _attackApplied = true;
        final int dmg =
            isSkill ? skillDmg : attackDmg + _rng.nextInt(4);
        monsterHp = math.max(0.0, monsterHp - dmg);
        shakeT = 0.24;
        flashT = 0.15;
        addText('-$dmg', const Color(0xFFFF5E5E), atMonster: true);
        if (monsterHp <= 0) {
          phase = FightPhase.won;
          monsterDefeated = true;
          attackT = 0;
          notifyListeners();
          return;
        }
      }
      if (attackT >= 1) attackT = 0;
    }

    // ---- AI monster ----
    if (monsterLungeT > 0) {
      monsterLungeT += dt / lungeDuration;
      if (monsterLungeT >= 1) monsterLungeT = 0;
    } else if (teleTimer > 0) {
      teleTimer -= dt;
      if (teleTimer <= 0) {
        teleTimer = 0;
        monsterLungeT = 0.0001;
        if (dodgeWindow > 0) {
          // Pemain berhasil mengelak!
          addText('HINDAR!', const Color(0xFF42CFFF), atMonster: false);
        } else {
          playerHp = math.max(0.0, playerHp - monsterDmg);
          addText('-$monsterDmg', const Color(0xFFFFB21A), atMonster: false);
          if (playerHp <= 0) {
            phase = FightPhase.lost;
            monsterLungeT = 0;
            notifyListeners();
            return;
          }
        }
        monsterTimer = attackInterval;
      }
    } else {
      monsterTimer -= dt;
      if (monsterTimer <= 0) {
        monsterTimer = 0;
        teleTimer = teleDuration;
      }
    }

    notifyListeners();
  }

  void _resetTimers() {
    skillCd = 0;
    dodgeCd = 0;
    dodgeWindow = 0;
    attackT = 0;
    _attackApplied = false;
    isSkill = false;
    monsterTimer = 1.2;
    teleTimer = 0;
    monsterLungeT = 0;
    shakeT = 0;
    flashT = 0;
    texts.clear();
  }
}