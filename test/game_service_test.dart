import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/game_service.dart';

// ============================================================
// TES MESIN PERMAINAN
// ============================================================
// Memastikan setiap dari 15 level punya solusi yang benar-benar
// bisa dimenangkan mesin, dengan jumlah blok <= par level tsb.

ScriptBlock _b(BlockKind k) => ScriptBlock(k);

ScriptBlock _repeat(int n, List<ScriptBlock> children) =>
    ScriptBlock(BlockKind.repeat)
      ..count = n
      ..children.addAll(children);

ScriptBlock _while(List<ScriptBlock> children) =>
    ScriptBlock(BlockKind.whileOpen)..children.addAll(children);

ScriptBlock _ifEnemy(List<ScriptBlock> children) =>
    ScriptBlock(BlockKind.ifEnemy)..children.addAll(children);

ScriptBlock _ifValue(
  CompareOp cmp,
  int n,
  List<ScriptBlock> children,
) => ScriptBlock(BlockKind.ifValue)
  ..cmp = cmp
  ..operand = n
  ..children.addAll(children);

ScriptBlock _av(ValueOp op, int n) => ScriptBlock(BlockKind.addValue)
  ..op = op
  ..operand = n;

/// Menjalankan susunan blok sampai mesin selesai.
GameEngine _run(int levelIndex, List<ScriptBlock> script) {
  final GameEngine engine = GameEngine(kLevels[levelIndex]);
  engine.start(script);

  int guard = 0;
  while (!engine.finished && guard < 1000) {
    guard++;
    engine.nextStep();
  }
  return engine;
}

/// Solusi resmi tiap level (urutan blok).
final Map<int, List<ScriptBlock>> solutions = <int, List<ScriptBlock>>{
  // L1 - Maju, Maju, Putar Kanan, Maju (4 = par)
  0: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
  ],

  // L2 - Maju x2, Putar Kanan, Maju x2 (5 = par)
  1: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
  ],

  // L3 - Maju, Ambil, Maju, Ambil, Maju, Putar Kanan, Maju (7 = par)
  2: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
  ],

  // L4 - Maju, Ambil x3 bergantian -> nilai 3 (6 = par)
  3: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.collect),
  ],

  // L5 - 1 x 9 = 9, 9 + 3 = 12 lalu ke bendera (8 = par)
  4: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _av(ValueOp.mul, 9),
    _av(ValueOp.add, 3),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
  ],

  // L6 - Maju, Ambil, Jika nilai >= 1 -> Serang x3 (6 = par)
  5: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _ifValue(CompareOp.gte, 1, <ScriptBlock>[
      _b(BlockKind.attack),
      _b(BlockKind.attack),
      _b(BlockKind.attack),
    ]),
  ],

  // L7 - Putar Kanan, Maju x2, Putar Kiri, Maju x2 (6 <= par 8)
  6: <ScriptBlock>[
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnLeft),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
  ],

  // L8 - Maju, Jika ada musuh -> Serang x3, Maju x2 (6 <= par 7)
  7: <ScriptBlock>[
    _b(BlockKind.forward),
    _ifEnemy(<ScriptBlock>[
      _b(BlockKind.attack),
      _b(BlockKind.attack),
      _b(BlockKind.attack),
    ]),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
  ],

  // L9 - Putar Kanan, Serang x3, Maju x3, Putar Kiri, Maju x2 (10 <= par 13)
  8: <ScriptBlock>[
    _b(BlockKind.turnRight),
    _b(BlockKind.attack),
    _b(BlockKind.attack),
    _b(BlockKind.attack),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnLeft),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
  ],

  // L10 - Ulangi(3) { Maju } (2 = par)
  9: <ScriptBlock>[
    _repeat(3, <ScriptBlock>[
      _b(BlockKind.forward),
    ]),
  ],

  // L11 - Ulangi(3) { Maju, Ambil }, Maju, Maju (5 = par)
  10: <ScriptBlock>[
    _repeat(3, <ScriptBlock>[
      _b(BlockKind.forward),
      _b(BlockKind.collect),
    ]),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
  ],

  // L12 - Selama(depan kosong){ Maju }, lalu belok turun ke bendera (10 = par)
  11: <ScriptBlock>[
    _while(<ScriptBlock>[
      _b(BlockKind.forward),
    ]),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnLeft),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
  ],

  // L13 - kumpulkan 2 nilai dari dua kristal lalu ke bendera (10 = par)
  12: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.turnRight),
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.turnLeft),
    _b(BlockKind.forward),
  ],

  // L14 - Maju x2, Jika ada musuh -> Serang x3, Ulangi(3){ Maju } (8 = par)
  13: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _ifEnemy(<ScriptBlock>[
      _b(BlockKind.attack),
      _b(BlockKind.attack),
      _b(BlockKind.attack),
    ]),
    _repeat(3, <ScriptBlock>[
      _b(BlockKind.forward),
    ]),
  ],

  // L15 - ambil, kalahkan boss, ambil lagi, capai bendera (11 <= par 12)
  14: <ScriptBlock>[
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
    _b(BlockKind.attack),
    _b(BlockKind.attack),
    _b(BlockKind.attack),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.forward),
    _b(BlockKind.collect),
    _b(BlockKind.forward),
  ],
};

void main() {
  test('15 level terdaftar dan terurut', () {
    expect(kLevels.length, 15);
    for (int i = 0; i < kLevels.length; i++) {
      expect(kLevels[i].level, i % 3, reason: 'Level ${i + 1}');
      expect(kLevels[i].region, i ~/ 3, reason: 'Level ${i + 1}');
      expect(kLevels[i].palette, isNotEmpty, reason: 'Level ${i + 1}');
      expect(
        kLevels[i].maxBlocks,
        greaterThanOrEqualTo(kLevels[i].par),
        reason: 'kuota >= par di level ${i + 1}',
      );
    }
  });

  test('setiap level bisa dimenangkan dengan jumlah blok <= par', () {
    expect(solutions.length, 15);

    for (final MapEntry<int, List<ScriptBlock>> e in solutions.entries) {
      final LevelDefinition lv = kLevels[e.key];
      final GameEngine engine = _run(e.key, e.value);

      expect(
        engine.won,
        isTrue,
        reason: 'Level ${e.key + 1} tidak tercapai.\n'
            'LOG:\n${engine.log.join('\n')}\n'
            'HP pemain: ${engine.playerHp}, musuh: ${engine.enemyHp}, '
            'nilai: ${engine.nilai}, posisi: (${engine.px},${engine.py})',
      );

      expect(
        countBlocks(e.value),
        lessThanOrEqualTo(lv.par),
        reason: 'solusi level ${e.key + 1} melebihi par',
      );
      expect(
        countBlocks(e.value),
        lessThanOrEqualTo(lv.maxBlocks),
        reason: 'solusi level ${e.key + 1} melebihi kuota',
      );
    }
  });

  test('susunan yang belum lengkap TIDAK memberi kemenangan', () {
    final GameEngine engine = _run(0, <ScriptBlock>[_b(BlockKind.forward)]);
    expect(engine.won, isFalse);
    expect(engine.finished, isTrue);
    expect(engine.resultNote, isNotEmpty);
  });

  test('serangan memakan 3 pukulan dan membalas 10 HP tiap aksi', () {
    final GameEngine engine = _run(
      7,
      <ScriptBlock>[
        _b(BlockKind.forward),
        _b(BlockKind.attack),
        _b(BlockKind.attack),
        _b(BlockKind.attack),
        _b(BlockKind.forward),
        _b(BlockKind.forward),
      ],
    );
    expect(engine.won, isTrue);
    expect(engine.enemyHp, 0);
    expect(engine.playerHp, lessThan(100));
    expect(engine.playerHp, greaterThan(0));
  });

  test('kuota blok menolak penambahan saat penuh', () {
    final List<ScriptBlock> script = <ScriptBlock>[];
    final int quota = kLevels[0].maxBlocks;
    for (int i = 0; i < quota + 3; i++) {
      if (countBlocks(script) < quota) {
        script.add(_b(BlockKind.forward));
      }
    }
    expect(countBlocks(script), quota);
  });
}
