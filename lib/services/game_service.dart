import 'package:flutter/material.dart';

// ============================================================
// GAME SERVICE
// ============================================================
// Berisi:
//   1. Blok perintah (BlockType) yang bisa disusun pemain.
//   2. Definisi 15 level / 5 wilayah sesuai materi AlgoQuest.
//   3. Mesin eksekusi (GameEngine) yang menjalankan susunan blok
//      langkah demi langkah agar bisa dianimasikan di layar.
//
// Peta memakai karakter:
//   #  dinding          .  jalur kosong
//   S  titik mulai      ^ > v <  titik mulai + arah hadap
//   G  gerbang/tujuan   E  musuh/boss
//   *  kristal (variabel)

// ------------------------------------------------------------
// ARAH HADAP KARAKTER
// ------------------------------------------------------------
enum Direction { up, right, down, left }

extension DirectionX on Direction {
  Direction get turnRight => Direction.values[(index + 1) % 4];
  Direction get turnLeft => Direction.values[(index + 3) % 4];

  /// (baris, kolom) langkah ke arah hadap.
  (int, int) get vector {
    if (this == Direction.up) return (0, -1);
    if (this == Direction.right) return (1, 0);
    if (this == Direction.down) return (0, 1);
    return (-1, 0);
  }

  /// Sudut putar ikon panah (rad).
  double get angle {
    if (this == Direction.right) return 1.5708;
    if (this == Direction.down) return 3.14159;
    if (this == Direction.left) return -1.5708;
    return 0;
  }

  String nameId(bool en) {
    if (this == Direction.up) return en ? 'North' : 'Utara';
    if (this == Direction.right) return en ? 'East' : 'Timur';
    if (this == Direction.down) return en ? 'South' : 'Selatan';
    return en ? 'West' : 'Barat';
  }
}

// ------------------------------------------------------------
// OPERATOR ARITMATIKA & PERBANDINGAN
// ------------------------------------------------------------
enum ValueOp { add, sub, mul, div }

extension ValueOpX on ValueOp {
  String get symbol {
    if (this == ValueOp.add) return '+';
    if (this == ValueOp.sub) return '-';
    if (this == ValueOp.mul) return '×';
    return '÷';
  }

  ValueOp get next => ValueOp.values[(index + 1) % 4];

  int apply(int a, int b) {
    if (this == ValueOp.add) return a + b;
    if (this == ValueOp.sub) return a - b;
    if (this == ValueOp.mul) return a * b;
    if (b == 0) return a;
    return a ~/ b;
  }
}

enum CompareOp { gte, lte, eq }

extension CompareOpX on CompareOp {
  String get symbol {
    if (this == CompareOp.gte) return '≥';
    if (this == CompareOp.lte) return '≤';
    return '=';
  }

  CompareOp get next => CompareOp.values[(index + 1) % 4];

  bool test(int a, int b) {
    if (this == CompareOp.gte) return a >= b;
    if (this == CompareOp.lte) return a <= b;
    return a == b;
  }
}

// ------------------------------------------------------------
// JENIS BLOK PERINTAH
// ------------------------------------------------------------
enum BlockKind {
  forward, // Maju()
  backward, // Mundur()
  turnRight, // Putar(Kanan)
  turnLeft, // Putar(Kiri)
  attack, // Serang()
  collect, // Ambil()
  addValue, // nilai = nilai + n
  repeat, // Ulangi(n) { }
  whileOpen, // Selama(depan kosong) { }
  ifOpen, // Jika(depan kosong) { } else { }
  ifEnemy, // Jika(ada musuh) { } else { }
  ifValue, // Jika(nilai >= n) { } else { }
}

/// Deskripsi tampilan satu jenis blok.
class BlockType {
  final BlockKind kind;
  final String codeId;
  final String codeEn;
  final Color color;
  final IconData icon;
  final bool container;

  const BlockType({
    required this.kind,
    required this.codeId,
    required this.codeEn,
    required this.color,
    required this.icon,
    this.container = false,
  });

  String code(bool en) => en ? codeEn : codeId;
}

const Map<BlockKind, BlockType> kBlockTypes = <BlockKind, BlockType>{
  BlockKind.forward: BlockType(
    kind: BlockKind.forward,
    codeId: 'Maju()',
    codeEn: 'Move()',
    color: Color(0xFF42CFFF),
    icon: Icons.arrow_upward,
  ),
  BlockKind.backward: BlockType(
    kind: BlockKind.backward,
    codeId: 'Mundur()',
    codeEn: 'Back()',
    color: Color(0xFF08A9C8),
    icon: Icons.arrow_downward,
  ),
  BlockKind.turnRight: BlockType(
    kind: BlockKind.turnRight,
    codeId: 'Putar(Kanan)',
    codeEn: 'Turn(Right)',
    color: Color(0xFF42CFFF),
    icon: Icons.rotate_right,
  ),
  BlockKind.turnLeft: BlockType(
    kind: BlockKind.turnLeft,
    codeId: 'Putar(Kiri)',
    codeEn: 'Turn(Left)',
    color: Color(0xFF42CFFF),
    icon: Icons.rotate_left,
  ),
  BlockKind.attack: BlockType(
    kind: BlockKind.attack,
    codeId: 'Serang()',
    codeEn: 'Attack()',
    color: Color(0xFFFF6B4A),
    icon: Icons.gps_fixed,
  ),
  BlockKind.collect: BlockType(
    kind: BlockKind.collect,
    codeId: 'Ambil()',
    codeEn: 'Collect()',
    color: Color(0xFF59C36A),
    icon: Icons.diamond,
  ),
  BlockKind.addValue: BlockType(
    kind: BlockKind.addValue,
    codeId: 'Ubah Nilai',
    codeEn: 'Change Var',
    color: Color(0xFF08A9C8),
    icon: Icons.calculate,
  ),
  BlockKind.repeat: BlockType(
    kind: BlockKind.repeat,
    codeId: 'Ulangi',
    codeEn: 'Repeat',
    color: Color(0xFFB07CFF),
    icon: Icons.repeat,
    container: true,
  ),
  BlockKind.whileOpen: BlockType(
    kind: BlockKind.whileOpen,
    codeId: 'Selama(depan kosong)',
    codeEn: 'While(open)',
    color: Color(0xFF9B6BFF),
    icon: Icons.all_inclusive,
    container: true,
  ),
  BlockKind.ifOpen: BlockType(
    kind: BlockKind.ifOpen,
    codeId: 'Jika(depan kosong)',
    codeEn: 'If(open)',
    color: Color(0xFFFFB21A),
    icon: Icons.alt_route,
    container: true,
  ),
  BlockKind.ifEnemy: BlockType(
    kind: BlockKind.ifEnemy,
    codeId: 'Jika(ada musuh)',
    codeEn: 'If(enemy)',
    color: Color(0xFFFFB21A),
    icon: Icons.whatshot,
    container: true,
  ),
  BlockKind.ifValue: BlockType(
    kind: BlockKind.ifValue,
    codeId: 'Jika(nilai)',
    codeEn: 'If(var)',
    color: Color(0xFFFFB21A),
    icon: Icons.compare_arrows,
    container: true,
  ),
};

// ------------------------------------------------------------
// BLOK DALAM SUSUNAN (INSTANCE)
// ------------------------------------------------------------
class ScriptBlock {
  ScriptBlock(this.kind) : type = kBlockTypes[kind]! {
    if (kind == BlockKind.repeat) count = 3;
    if (kind == BlockKind.ifValue) operand = 2;
  }

  final BlockKind kind;
  final BlockType type;

  /// Jumlah pengulangan (repeat).
  int count = 1;

  /// Operand operator (nilai) / ambang perbandingan.
  int operand = 1;
  ValueOp op = ValueOp.add;
  CompareOp cmp = CompareOp.gte;

  final List<ScriptBlock> children = <ScriptBlock>[];
  final List<ScriptBlock> elseChildren = <ScriptBlock>[];

  bool get hasElse =>
      kind == BlockKind.ifOpen ||
      kind == BlockKind.ifEnemy ||
      kind == BlockKind.ifValue;

  /// Teks blok berbahasa Indonesia.
  String codeId() => _code(false);

  /// Teks blok berbahasa Inggris.
  String codeEn() => _code(true);

  String _code(bool en) {
    switch (kind) {
      case BlockKind.repeat:
        return en ? 'Repeat($count)' : 'Ulangi($count)';
      case BlockKind.addValue:
        return 'nilai = nilai ${op.symbol} $operand';
      case BlockKind.ifValue:
        return en
            ? 'If(var ${cmp.symbol} $operand)'
            : 'Jika(nilai ${cmp.symbol} $operand)';
      case BlockKind.whileOpen:
        return en ? 'While(open)' : 'Selama(depan kosong)';
      case BlockKind.ifOpen:
        return en ? 'If(open)' : 'Jika(depan kosong)';
      case BlockKind.ifEnemy:
        return en ? 'If(enemy)' : 'Jika(ada musuh)';
      default:
        return type.code(en);
    }
  }

  /// Label baris daftar: "Maju() / Move".
  String label() {
    final String id = codeId();
    final String en = codeEn();
    return id == en ? id : '$id / $en';
  }
}

/// Menghitung total blok (termasuk blok di dalam kurung).
int countBlocks(List<ScriptBlock> list) {
  int total = 0;
  for (final ScriptBlock b in list) {
    total += 1 + countBlocks(b.children) + countBlocks(b.elseChildren);
  }
  return total;
}

// ------------------------------------------------------------
// DEFINISI LEVEL
// ------------------------------------------------------------
class LevelDefinition {
  final int region;
  final int level;
  final String materiId;
  final String materiEn;
  final String goalId;
  final String goalEn;
  final String tipId;
  final String tipEn;
  final List<String> map;
  final List<BlockKind> palette;
  final int maxBlocks;
  final int par;
  final int enemyHp;
  final int crystalValue;
  final int targetValue;
  final bool needGoal;
  final bool needCrystals;
  final bool needEnemy;

  const LevelDefinition({
    required this.region,
    required this.level,
    required this.materiId,
    required this.materiEn,
    required this.goalId,
    required this.goalEn,
    required this.tipId,
    required this.tipEn,
    required this.map,
    required this.palette,
    required this.maxBlocks,
    required this.par,
    this.enemyHp = 0,
    this.crystalValue = 1,
    this.targetValue = 0,
    this.needGoal = false,
    this.needCrystals = false,
    this.needEnemy = false,
  });

  String materi(bool en) => en ? materiEn : materiId;
  String goal(bool en) => en ? goalEn : goalId;
  String tip(bool en) => en ? tipEn : tipId;
}

const List<LevelDefinition> kLevels = <LevelDefinition>[
  // ===== WILAYAH 1 — HUTAN ALGORITMA =====
  LevelDefinition(
    region: 0,
    level: 0,
    materiId: 'Pengenalan Algoritma',
    materiEn: 'Introduction to Algorithms',
    goalId: 'Bawa karakter sampai ke bendera dengan urutan langkah yang benar.',
    goalEn: 'Bring the character to the flag with the right step order.',
    tipId: 'Algoritma = daftar langkah berurutan. Coba jalur paling singkat '
        'dulu: maju, maju, baru belok.',
    tipEn: 'An algorithm = an ordered list of steps. Try the shortest path '
        'first: move, move, then turn.',
    map: <String>[
      '#####',
      '#S..#',
      '#.#G#',
      '#...#',
      '#####',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.turnRight,
      BlockKind.turnLeft,
    ],
    maxBlocks: 8,
    par: 4,
    needGoal: true,
  ),
  LevelDefinition(
    region: 0,
    level: 1,
    materiId: 'Urutan Instruksi',
    materiEn: 'Instruction Sequence',
    goalId: 'Susun langkah yang masih acak menjadi urutan yang benar '
        'hingga mencapai tujuan.',
    goalEn: 'Arrange the random steps into the correct order to reach the goal.',
    tipId: 'Perhatikan arah hadap karakter. Satu putaran putar = 90 derajat, '
        'jadi maju dua kali sebelum belok agar tidak meleset.',
    tipEn: 'Watch the facing direction. One turn = 90 degrees, so move twice '
        'before turning.',
    map: <String>[
      '#####',
      '#S..#',
      '##..#',
      '#..G#',
      '#####',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.backward,
      BlockKind.turnRight,
      BlockKind.turnLeft,
    ],
    maxBlocks: 10,
    par: 5,
    needGoal: true,
  ),
  LevelDefinition(
    region: 0,
    level: 2,
    materiId: 'Algoritma dalam Kehidupan Sehari-hari',
    materiEn: 'Algorithms in Daily Life',
    goalId: 'Ambil semua kristal lalu capai bendera — seperti mengikuti '
        'resep memasak.',
    goalEn: 'Collect every crystal then reach the flag — like following a recipe.',
    tipId: 'Ambil() hanya bekerja saat karakter berdiri di atas kristal.',
    tipEn: 'Collect() only works while standing on a crystal.',
    map: <String>[
      '######',
      '#S**.#',
      '#...G#',
      '######',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.collect,
    ],
    maxBlocks: 12,
    par: 7,
    needGoal: true,
    needCrystals: true,
  ),

  // ===== WILAYAH 2 — LEMBAH VARIABEL =====
  LevelDefinition(
    region: 1,
    level: 0,
    materiId: 'Pengenalan Variabel',
    materiEn: 'Introduction to Variables',
    goalId: 'Simpan kristal ke dalam variabel "nilai" hingga nilai ≥ 3.',
    goalEn: 'Store crystals into the variable "nilai" until nilai >= 3.',
    tipId: 'Variabel = kotak penyimpan nilai. Tiap Ambil() menambah 1 ke '
        'variabel bernama nilai.',
    tipEn: 'A variable = a box holding a value. Each Collect() adds 1 to the '
        'variable named nilai.',
    map: <String>[
      '######',
      '#S***#',
      '#....#',
      '######',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.collect,
      BlockKind.turnRight,
    ],
    maxBlocks: 10,
    par: 6,
    targetValue: 3,
  ),
  LevelDefinition(
    region: 1,
    level: 1,
    materiId: 'Operator Aritmatika',
    materiEn: 'Arithmetic Operators',
    goalId: 'Buat variabel "nilai" menjadi ≥ 12 memakai +, -, ×, ÷ '
        'lalu capai bendera.',
    goalEn: 'Make "nilai" reach 12 using +, -, x, / then reach the flag.',
    tipId: 'Ketuk kotak operator untuk mengganti +, -, ×, ÷ dan ketuk angka '
        'untuk mengubah operand.',
    tipEn: 'Tap the operator box to switch +, -, x, / and tap the number to '
        'change the operand.',
    map: <String>[
      '######',
      '#S*..#',
      '#...G#',
      '######',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.collect,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.addValue,
    ],
    maxBlocks: 14,
    par: 8,
    targetValue: 12,
    needGoal: true,
  ),
  LevelDefinition(
    region: 1,
    level: 2,
    materiId: 'Operator Perbandingan & Logika',
    materiEn: 'Comparison & Logic Operators',
    goalId: 'Ambil kristal, lalu serang musuh hanya jika nilai ≥ 1.',
    goalEn: 'Collect the crystal, then attack only if nilai >= 1.',
    tipId: 'Blok Jika(nilai ≥ n) mengecek perbandingan. Bila benar, blok '
        'di dalamnya dijalankan.',
    tipEn: 'The If(var >= n) block checks a comparison. When true, the blocks '
        'inside run.',
    map: <String>[
      '#####',
      '#S*E#',
      '#...#',
      '#####',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.collect,
      BlockKind.attack,
      BlockKind.ifValue,
      BlockKind.turnRight,
    ],
    maxBlocks: 11,
    par: 6,
    enemyHp: 100,
    needEnemy: true,
  ),

  // ===== WILAYAH 3 — GERBANG PERCABANGAN =====
  LevelDefinition(
    region: 2,
    level: 0,
    materiId: 'Konsep Kondisi',
    materiEn: 'Understanding Conditions',
    goalId: 'Gunakan kondisi "depan kosong" untuk memilih maju atau belok.',
    goalEn: 'Use the "front is open" condition to choose move or turn.',
    tipId: 'Kondisi bernilai benar/salah. Kalau depan tembok, cabang ELSE '
        'yang dijalankan.',
    tipEn: 'A condition is true/false. If the front is a wall, the ELSE branch '
        'runs instead.',
    map: <String>[
      '#####',
      '#S#.#',
      '#...#',
      '#..G#',
      '#####',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.ifOpen,
      BlockKind.repeat,
    ],
    maxBlocks: 13,
    par: 8,
    needGoal: true,
  ),
  LevelDefinition(
    region: 2,
    level: 1,
    materiId: 'If–Else',
    materiEn: 'If–Else',
    goalId: 'Kalau ada musuh di depan maka serang, kalau tidak maju, '
        'lalu capai bendera.',
    goalEn: 'If an enemy is ahead then attack, otherwise move, then reach the flag.',
    tipId: 'Susun blok di dalam LAKUKAN (IF) dan SELAINNYA (ELSE) dengan '
        'mengetuk zona putus-putus.',
    tipEn: 'Place blocks inside THEN (IF) and ELSE by tapping the dashed zone.',
    map: <String>[
      '######',
      '#S.EG#',
      '#.####',
      '#....#',
      '######',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.attack,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.ifEnemy,
      BlockKind.collect,
    ],
    maxBlocks: 12,
    par: 7,
    enemyHp: 100,
    needEnemy: true,
    needGoal: true,
  ),
  LevelDefinition(
    region: 2,
    level: 2,
    materiId: 'Percabangan Bertingkat',
    materiEn: 'Nested Branching',
    goalId: 'Gabungkan dua kondisi: jika bebas maju, jika tidak periksa musuh.',
    goalEn: 'Combine two conditions: if open move, otherwise check for an enemy.',
    tipId: 'Percabangan bertingkat = kondisi di dalam kondisi. Letakkan blok '
        'Jika ke dalam cabang ELSE.',
    tipEn: 'Nested branching = a condition inside a condition. Place an If '
        'block into the ELSE branch.',
    map: <String>[
      '#####',
      '#S#.#',
      '#E..#',
      '#...#',
      '#..G#',
      '#####',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.attack,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.ifOpen,
      BlockKind.ifEnemy,
    ],
    maxBlocks: 18,
    par: 13,
    enemyHp: 100,
    needEnemy: true,
    needGoal: true,
  ),

  // ===== WILAYAH 4 — LABIRIN PERULANGAN =====
  LevelDefinition(
    region: 3,
    level: 0,
    materiId: 'Konsep Perulangan',
    materiEn: 'The Idea of Loops',
    goalId: 'Ulangi langkah yang sama sampai sampai tujuan.',
    goalEn: 'Repeat the same step until you reach the goal.',
    tipId: 'Alih-alih menulis Maju() lima kali, bungkus dengan Ulangi(n).',
    tipEn: 'Instead of writing Move() five times, wrap it in Repeat(n).',
    map: <String>[
      '######',
      '#S..G#',
      '######',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.repeat,
      BlockKind.turnRight,
    ],
    maxBlocks: 6,
    par: 2,
    needGoal: true,
  ),
  LevelDefinition(
    region: 3,
    level: 1,
    materiId: 'For / Perulangan Terhitung',
    materiEn: 'For / Counted Loops',
    goalId: 'Tentukan jumlah pengulangan yang tepat untuk mengambil 2 kristal '
        'dan sampai ke bendera.',
    goalEn: 'Pick the exact repeat count to grab 2 crystals and reach the flag.',
    tipId: 'Perulangan terhitung berhenti sendiri setelah jumlahnya terpenuhi.',
    tipEn: 'A counted loop stops by itself once the count is met.',
    map: <String>[
      '########',
      '#S*.*.G#',
      '########',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.collect,
      BlockKind.repeat,
      BlockKind.turnRight,
    ],
    maxBlocks: 10,
    par: 5,
    needGoal: true,
    needCrystals: true,
  ),
  LevelDefinition(
    region: 3,
    level: 2,
    materiId: 'While / Perulangan Berdasarkan Kondisi',
    materiEn: 'While / Condition Loops',
    goalId: 'Berjalan selama depan masih kosong, lalu temukan jalan ke bendera.',
    goalEn: 'Keep walking while the front is open, then find the way to the flag.',
    tipId: 'While berhenti saat kondisi menjadi salah — di sini saat depan '
        'menjemput tembok.',
    tipEn: 'While stops when the condition turns false — here when a wall is ahead.',
    map: <String>[
      '#########',
      '#S....#.#',
      '#......##',
      '###.#####',
      '#..G....#',
      '#########',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.whileOpen,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.repeat,
    ],
    maxBlocks: 14,
    par: 10,
    needGoal: true,
  ),

  // ===== WILAYAH 5 — BENTENG LOGIKA =====
  LevelDefinition(
    region: 4,
    level: 0,
    materiId: 'Kombinasi Algoritma + Variabel',
    materiEn: 'Algorithms + Variables',
    goalId: 'Kumpulkan nilai ≥ 2 dari dua kristal sambil menuju bendera.',
    goalEn: 'Gather nilai >= 2 from two crystals while heading to the flag.',
    tipId: 'Rencanakan dulu: berapa langkah, di mana ambil kristal, kapan '
        'belok.',
    tipEn: 'Plan first: how many steps, where to collect, when to turn.',
    map: <String>[
      '######',
      '#S*..#',
      '#.#*.#',
      '#....#',
      '#...G#',
      '######',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.collect,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.addValue,
    ],
    maxBlocks: 15,
    par: 10,
    targetValue: 2,
    needGoal: true,
  ),
  LevelDefinition(
    region: 4,
    level: 1,
    materiId: 'Kombinasi Percabangan + Perulangan',
    materiEn: 'Branching + Loops',
    goalId: 'Mendekati musuh dengan perulangan, lalu serang dengan kondisi, '
        'kemudian capai bendera.',
    goalEn: 'Approach with a loop, attack with a condition, then reach the flag.',
    tipId: 'Ulangi untuk mengulang aksi serupa, Jika untuk memutuskan aksi '
        'tepat.',
    tipEn: 'Repeat re-runs similar actions, If picks the right action.',
    map: <String>[
      '########',
      '#S..E.G#',
      '###..###',
      '########',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.attack,
      BlockKind.repeat,
      BlockKind.ifEnemy,
      BlockKind.turnRight,
      BlockKind.turnLeft,
    ],
    maxBlocks: 12,
    par: 8,
    enemyHp: 100,
    needEnemy: true,
    needGoal: true,
  ),
  LevelDefinition(
    region: 4,
    level: 2,
    materiId: 'Final Challenge: Logika Pemrograman',
    materiEn: 'Final Challenge: Programming Logic',
    goalId: 'Kalahkan boss, kumpulkan nilai ≥ 2, lalu capai bendera.',
    goalEn: 'Defeat the boss, gather nilai >= 2, then reach the flag.',
    tipId: 'Gunakan semua yang sudah dipelajari: urutan, variabel, kondisi, '
        'dan perulangan.',
    tipEn: 'Use everything you learned: sequence, variables, conditions and loops.',
    map: <String>[
      '#########',
      '#S*.E.*G#',
      '###.#.###',
      '#.......#',
      '#########',
    ],
    palette: <BlockKind>[
      BlockKind.forward,
      BlockKind.backward,
      BlockKind.turnRight,
      BlockKind.turnLeft,
      BlockKind.attack,
      BlockKind.collect,
      BlockKind.addValue,
      BlockKind.repeat,
      BlockKind.ifEnemy,
      BlockKind.ifValue,
    ],
    maxBlocks: 18,
    par: 12,
    enemyHp: 100,
    targetValue: 2,
    needGoal: true,
    needEnemy: true,
  ),
];

// ------------------------------------------------------------
// HASIL SATU LANGKAH EKSEKUSI
// ------------------------------------------------------------
class GameStep {
  final BlockKind kind;
  final String message;
  final bool ok;
  final bool attacked; // pemain menghantam musuh
  final bool hitPlayer; // musuh membalas
  final bool moved;

  const GameStep({
    required this.kind,
    required this.message,
    required this.ok,
    this.attacked = false,
    this.hitPlayer = false,
    this.moved = false,
  });
}

// ------------------------------------------------------------
// MESIN EKSEKUSI
// ------------------------------------------------------------
class _Frame {
  _Frame(this.blocks, {this.limit, this.whileCond});

  final List<ScriptBlock> blocks;
  final int? limit;
  final bool Function(GameEngine engine)? whileCond;
  int i = 0;
  int iteration = 1;
}

class GameEngine {
  GameEngine(this.level);

  final LevelDefinition level;

  // --- papan ---
  late int cols;
  late int rows;
  late List<List<bool>> wall;
  late List<List<bool>> goal;
  final Set<int> crystals = <int>{};
  late int startX;
  late int startY;
  late Direction startDir;

  // --- status ---
  int px = 0;
  int py = 0;
  Direction dir = Direction.right;
  int playerHp = 100;
  int enemyHp = 0;
  int enemyX = -1;
  int enemyY = -1;
  bool enemyAlive = false;
  int nilai = 0;
  int steps = 0;
  int crystalsTaken = 0;
  int crystalsTotal = 0;

  bool finished = false;
  bool won = false;
  bool lost = false;
  String resultNote = '';

  final List<String> log = <String>[];
  final List<_Frame> _stack = <_Frame>[];

  static const int maxSteps = 250;
  static const int maxDepth = 60;
  static const int damage = 34;
  static const int enemyDamage = 10;

  // ----------------------------------------------------------
  // BACA PETA
  // ----------------------------------------------------------
  void _loadBoard() {
    rows = level.map.length;
    cols = level.map.first.length;
    wall = List<List<bool>>.generate(
      rows,
      (int y) => List<bool>.filled(cols, false),
    );
    goal = List<List<bool>>.generate(
      rows,
      (int y) => List<bool>.filled(cols, false),
    );
    crystals.clear();
    startX = 1;
    startY = 1;
    startDir = Direction.right;
    enemyX = -1;
    enemyY = -1;
    enemyAlive = false;
    crystalsTaken = 0;
    crystalsTotal = 0;

    for (int y = 0; y < rows; y++) {
      final String row = level.map[y];
      for (int x = 0; x < cols; x++) {
        final String c = x < row.length ? row[x] : '#';
        if (c == '#') {
          wall[y][x] = true;
        } else if (c == 'G') {
          goal[y][x] = true;
        } else if (c == '*') {
          crystals.add(y * cols + x);
        } else if (c == 'E') {
          enemyX = x;
          enemyY = y;
          enemyAlive = true;
        } else if (c == 'S' || c == '^' || c == '>' || c == 'v' || c == '<') {
          startX = x;
          startY = y;
          if (c == '^') startDir = Direction.up;
          if (c == '>') startDir = Direction.right;
          if (c == 'v') startDir = Direction.down;
          if (c == '<') startDir = Direction.left;
        }
      }
    }
    crystalsTotal = crystals.length;
    enemyHp = level.enemyHp;
  }

  // ----------------------------------------------------------
  // MULAI EKSEKUSI
  // ----------------------------------------------------------
  void start(List<ScriptBlock> script) {
    _loadBoard();
    px = startX;
    py = startY;
    dir = startDir;
    playerHp = 100;
    nilai = 0;
    steps = 0;
    finished = false;
    won = false;
    lost = false;
    resultNote = '';
    log
      ..clear()
      ..add('> Eksekusi dimulai...');
    _stack
      ..clear()
      ..add(_Frame(script));
  }

  // ----------------------------------------------------------
  // PENGECEKAN TUJUAN
  // ----------------------------------------------------------
  bool get onGoal => goal[py][px];

  bool get goalOk => !level.needGoal || onGoal;

  bool get enemyOk => !level.needEnemy || !enemyAlive;

  bool get valueOk =>
      level.targetValue <= 0 || nilai >= level.targetValue;

  bool get crystalOk =>
      !level.needCrystals || crystalsTaken == crystalsTotal;

  bool get allOk => goalOk && enemyOk && valueOk && crystalOk;

  // ----------------------------------------------------------
  // INFORMASI UNTUK UI
  // ----------------------------------------------------------
  bool get hasEnemy => enemyX >= 0 && level.enemyHp > 0;

  int get crystalsLeft => crystalsTotal - crystalsTaken;

  void _say(String msg) {
    log.add(msg);
    if (log.length > 60) log.removeAt(0);
  }

  void _win(String msg) {
    won = true;
    finished = true;
    resultNote = msg;
    _say('✔ $msg');
  }

  void _fail(String msg) {
    lost = true;
    finished = true;
    resultNote = msg;
    _say('✘ $msg');
  }

  // ----------------------------------------------------------
  // BANTU KONDISI
  // ----------------------------------------------------------
  (int, int) _aheadCell() {
    final (int dx, int dy) = dir.vector;
    return (px + dx, py + dy);
  }

  bool _inBounds(int x, int y) => x >= 0 && y >= 0 && x < cols && y < rows;

  bool _isWall(int x, int y) => !_inBounds(x, y) || wall[y][x];

  bool _enemyAt(int x, int y) => enemyAlive && enemyX == x && enemyY == y;

  bool get aheadOpen {
    final (int x, int y) = _aheadCell();
    return !_isWall(x, y) && !_enemyAt(x, y);
  }

  bool get enemyAhead {
    final (int x, int y) = _aheadCell();
    return enemyAlive && enemyX == x && enemyY == y;
  }

  // ----------------------------------------------------------
  // LANGKAH BERIKUTNYA
  // ----------------------------------------------------------
  GameStep? nextStep() {
    if (finished) return null;

    if (steps >= maxSteps) {
      _fail('Melebihi batas $maxSteps langkah.');
      return null;
    }

    while (_stack.isNotEmpty) {
      final _Frame f = _stack.last;

      if (f.i >= f.blocks.length) {
        // Perulangan terhitung: ulang lagi bila masih ada sisa.
        if (f.limit != null && f.iteration < f.limit!) {
          f.i = 0;
          f.iteration++;
          continue;
        }
        // Perulangan berbasis kondisi: cek ulang kondisinya.
        if (f.whileCond != null) {
          if (f.whileCond!(this)) {
            f.i = 0;
            continue;
          }
        }
        _stack.removeLast();
        continue;
      }

      final ScriptBlock b = f.blocks[f.i];
      f.i++;

      if (b.kind == BlockKind.repeat) {
        if (b.count > 0 && b.children.isNotEmpty) {
          _push(_Frame(b.children, limit: b.count));
        }
        continue;
      }
      if (b.kind == BlockKind.whileOpen) {
        if (aheadOpen && b.children.isNotEmpty) {
          _push(
            _Frame(b.children, whileCond: (GameEngine e) => e.aheadOpen),
          );
        }
        continue;
      }
      if (b.kind == BlockKind.ifOpen) {
        _pushBranch(aheadOpen ? b.children : b.elseChildren);
        continue;
      }
      if (b.kind == BlockKind.ifEnemy) {
        _pushBranch(enemyAhead ? b.children : b.elseChildren);
        continue;
      }
      if (b.kind == BlockKind.ifValue) {
        _pushBranch(
          b.cmp.test(nilai, b.operand) ? b.children : b.elseChildren,
        );
        continue;
      }

      return _execute(b);
    }

    // Susunan habis dieksekusi.
    if (allOk) {
      _win('Tujuan tercapai!');
    } else {
      _fail('Logika selesai, tetapi tujuan belum tercapai.');
    }
    return null;
  }

  void _push(_Frame f) {
    if (_stack.length >= maxDepth) {
      _fail('Perulangan terlalu dalam.');
      return;
    }
    _stack.add(f);
  }

  void _pushBranch(List<ScriptBlock> branch) {
    if (branch.isNotEmpty) _push(_Frame(branch));
  }

  // ----------------------------------------------------------
  // EKSEKUSI SATU BLOK DAUN
  // ----------------------------------------------------------
  GameStep _execute(ScriptBlock b) {
    steps++;

    GameStep step;
    switch (b.kind) {
      case BlockKind.forward:
        step = _move(b, 1);
        break;
      case BlockKind.backward:
        step = _move(b, -1);
        break;
      case BlockKind.turnRight:
        dir = dir.turnRight;
        step = GameStep(
          kind: b.kind,
          message: 'Putar kanan → ${dir.nameId(false)}',
          ok: true,
        );
        break;
      case BlockKind.turnLeft:
        dir = dir.turnLeft;
        step = GameStep(
          kind: b.kind,
          message: 'Putar kiri → ${dir.nameId(false)}',
          ok: true,
        );
        break;
      case BlockKind.attack:
        step = _attack(b);
        break;
      case BlockKind.collect:
        step = _collect(b);
        break;
      case BlockKind.addValue:
        nilai = b.op.apply(nilai, b.operand);
        step = GameStep(
          kind: b.kind,
          message: 'nilai = nilai ${b.op.symbol} ${b.operand} → $nilai',
          ok: true,
        );
        break;
      default:
        step = GameStep(
          kind: b.kind,
          message: 'Blok tidak dikenal',
          ok: false,
        );
    }

    _say(step.message);

    // Musuh sudah tumbang → cek kemenangan sebelum balasan.
    if (allOk) {
      _win('Tujuan tercapai!');
      return step;
    }

    if (playerHp <= 0) {
      _fail('Karakter kehabisan HP.');
      return step;
    }

    // Balasan serangan musuh bila bersebelahan.
    if (enemyAlive &&
        (enemyX - px).abs() + (enemyY - py).abs() == 1 &&
        !goal[py][px]) {
      playerHp -= enemyDamage;
      if (playerHp < 0) playerHp = 0;
      _say('⚔ Musuh menyerang! -$enemyDamage HP');
      if (playerHp <= 0) {
        _fail('Karakter kehabisan HP.');
      }
    }

    return step;
  }

  GameStep _move(ScriptBlock b, int sign) {
    final (int dx, int dy) = dir.vector;
    final int nx = px + dx * sign;
    final int ny = py + dy * sign;

    if (_isWall(nx, ny)) {
      return GameStep(
        kind: b.kind,
        message: 'Terhalang dinding — maju dibatalkan.',
        ok: false,
      );
    }
    if (_enemyAt(nx, ny)) {
      return GameStep(
        kind: b.kind,
        message: 'Musuh menghalangi jalan.',
        ok: false,
      );
    }

    px = nx;
    py = ny;
    return GameStep(
      kind: b.kind,
      message: 'Langkah ke (${px + 1}, ${py + 1}) arah ${dir.nameId(false)}',
      ok: true,
      moved: true,
    );
  }

  GameStep _attack(ScriptBlock b) {
    if (enemyAhead) {
      enemyHp -= damage;
      if (enemyHp <= 0) {
        enemyHp = 0;
        enemyAlive = false;
        return GameStep(
          kind: b.kind,
          message: 'Serangan tepat! Musuh dikalahkan. 💥',
          ok: true,
          attacked: true,
        );
      }
      return GameStep(
        kind: b.kind,
        message: 'Serangan mengenai! -$damage HP musuh (sisa $enemyHp)',
        ok: true,
        attacked: true,
      );
    }
    return GameStep(
      kind: b.kind,
      message: 'Tidak ada musuh di depan.',
      ok: false,
    );
  }

  GameStep _collect(ScriptBlock b) {
    final int key = py * cols + px;
    if (crystals.remove(key)) {
      crystalsTaken++;
      nilai += level.crystalValue;
      return GameStep(
        kind: b.kind,
        message: 'Kristal diambil → nilai = $nilai',
        ok: true,
      );
    }
    return GameStep(
      kind: b.kind,
      message: 'Tidak ada kristal di titik ini.',
      ok: false,
    );
  }
}
