import 'dart:math';

// ============================================================
// MESIN PERMAINAN — LABIRIN + MONSTER
// ============================================================
// Pemain menyusun blok perintah (Maju / Belok / Serang) untuk
// mengantar karakter menembus labirin, lalu mengalahkan monster.
// Setelah monster kalah, pemain lanjut menjawab soal (tahap
// berikutnya).
//
// Tingkat kesulitan naik dari Wilayah 1 (mudah) ke Wilayah 5
// (paling sulit): ukuran labirin makin besar dan HP monster
// makin tinggi.

// 0 = atas, 1 = kanan, 2 = bawah, 3 = kiri
const List<int> kDirRow = <int>[-1, 0, 1, 0];
const List<int> kDirCol = <int>[0, 1, 0, -1];

// ------------------------------------------------------------
// KOORDINAT
// ------------------------------------------------------------
class Pos {
  final int row;
  final int col;

  const Pos(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Pos && other.row == row && other.col == col;

  @override
  int get hashCode => row * 1000 + col;
}

// ------------------------------------------------------------
// PERINTAH & BLOK
// ------------------------------------------------------------
enum GameCommand { forward, turnRight, turnLeft, attack }

extension GameCommandText on GameCommand {
  /// Label penuh, dipakai di daftar perintah & blok.
  String label(bool en) {
    switch (this) {
      case GameCommand.forward:
        return en ? 'Move()' : 'Maju()';
      case GameCommand.turnRight:
        return en ? 'TurnRight()' : 'Belok Kanan()';
      case GameCommand.turnLeft:
        return en ? 'TurnLeft()' : 'Belok Kiri()';
      case GameCommand.attack:
        return en ? 'Attack()' : 'Serang()';
    }
  }

  /// Label pendek, dipakai di dalam blok yang sudah tersusun.
  String pill(bool en) {
    switch (this) {
      case GameCommand.forward:
        return en ? 'Move' : 'Maju';
      case GameCommand.turnRight:
        return en ? 'Turn \u25B6' : 'Belok \u25B6';
      case GameCommand.turnLeft:
        return en ? '\u25C0 Turn' : '\u25C0 Belok';
      case GameCommand.attack:
        return en ? 'Attack' : 'Serang';
    }
  }
}

/// Satu blok pada urutan logika. Beberapa perintah sama yang
/// berurutan digabung jadi satu blok (seperti "ulangi").
class CommandBlock {
  final GameCommand command;
  int count;

  CommandBlock(this.command, {this.count = 1});
}

/// Kembangkan blok menjadi barisan perintah tunggal.
List<GameCommand> expandBlocks(List<CommandBlock> blocks) {
  final List<GameCommand> out = <GameCommand>[];
  for (final CommandBlock block in blocks) {
    for (var i = 0; i < block.count; i++) {
      out.add(block.command);
    }
  }
  return out;
}

// ------------------------------------------------------------
// DEFINISI LEVEL
// ------------------------------------------------------------
class MazeLevel {
  final int region;
  final int level;
  final int size;

  /// walls[row][col] == true berarti dinding.
  final List<List<bool>> walls;
  final Pos start;
  final int startDir;
  final Pos monster;
  final int enemyHp;

  /// Jumlah langkah paling efisien (gerak + belok + serang).
  final int par;

  /// Kuota blok (setelah perintah berurutan digabung).
  final int maxBlocks;

  /// Barisan perintah paling efisien (tanpa serangan).
  final List<GameCommand> solution;

  final String monsterId;
  final String monsterEn;

  const MazeLevel({
    required this.region,
    required this.level,
    required this.size,
    required this.walls,
    required this.start,
    required this.startDir,
    required this.monster,
    required this.enemyHp,
    required this.par,
    required this.maxBlocks,
    required this.solution,
    required this.monsterId,
    required this.monsterEn,
  });

  bool isWall(int row, int col) {
    if (row < 0 || col < 0 || row >= size || col >= size) return true;
    return walls[row][col];
  }

  bool isMonster(int row, int col) => row == monster.row && col == monster.col;

  String monsterName(bool en) => en ? monsterEn : monsterId;
}

// ------------------------------------------------------------
// KATALOG 15 LEVEL
// ------------------------------------------------------------
class MazeCatalog {
  MazeCatalog._();

  static const int regionCount = 5;
  static const int levelsPerRegion = 3;

  /// Ukuran labirin tiap wilayah/level (selalu ganjil).
  static const List<List<int>> _sizes = <List<int>>[
    <int>[7, 7, 7],
    <int>[7, 9, 9],
    <int>[9, 9, 9],
    <int>[9, 11, 11],
    <int>[11, 11, 11],
  ];

  /// HP monster tiap wilayah/level.
  static const List<List<int>> _hp = <List<int>>[
    <int>[1, 1, 2],
    <int>[2, 2, 2],
    <int>[2, 3, 3],
    <int>[3, 3, 3],
    <int>[3, 3, 4],
  ];

  static const List<String> _monsterId = <String>[
    'Goblin Algoritma',
    'Slime Variabel',
    'Naga Percabangan',
    'Iblis Perulangan',
    'Behemoth Logika',
  ];

  static const List<String> _monsterEn = <String>[
    'Algorithm Goblin',
    'Variable Slime',
    'Branch Dragon',
    'Loop Demon',
    'Logic Behemoth',
  ];

  static final List<MazeLevel> levels = List<MazeLevel>.generate(
    regionCount * levelsPerRegion,
    (int i) => _build(i ~/ levelsPerRegion, i % levelsPerRegion),
  );

  static MazeLevel level(int region, int level) {
    final int r = region.clamp(0, regionCount - 1);
    final int l = level.clamp(0, levelsPerRegion - 1);
    return levels[r * levelsPerRegion + l];
  }

  static MazeLevel _build(int region, int level) {
    final int size = _sizes[region][level];
    final int hp = _hp[region][level];
    final Random rng = Random(1000 + region * 37 + level * 7);

    final List<List<bool>> walls = _generateMaze(size, rng);
    const Pos start = Pos(1, 1);
    final Pos monster = Pos(size - 2, size - 2);
    final int startDir = _pickDir(walls, size, start, monster, rng);

    final _Solution sol = _solve(walls, size, start, startDir, monster, hp);
    final bool boss = level == levelsPerRegion - 1;
    final String nameId =
        boss ? '${_monsterId[region]} (Boss)' : _monsterId[region];
    final String nameEn =
        boss ? '${_monsterEn[region]} (Boss)' : _monsterEn[region];

    return MazeLevel(
      region: region,
      level: level,
      size: size,
      walls: walls,
      start: start,
      startDir: startDir,
      monster: monster,
      enemyHp: hp,
      par: sol.cost,
      maxBlocks: _mergedRuns(sol.commands) + 3,
      solution: sol.commands,
      monsterId: nameId,
      monsterEn: nameEn,
    );
  }

  /// Labirin sempurna (recursive backtracker).
  static List<List<bool>> _generateMaze(int size, Random rng) {
    final List<List<bool>> grid = List<List<bool>>.generate(
      size,
      (_) => List<bool>.filled(size, true),
    );
    final List<Pos> stack = <Pos>[const Pos(1, 1)];
    grid[1][1] = false;

    while (stack.isNotEmpty) {
      final Pos cur = stack.last;
      final List<int> dirs = <int>[0, 1, 2, 3]..shuffle(rng);
      var moved = false;
      for (final int d in dirs) {
        final int nr = cur.row + kDirRow[d] * 2;
        final int nc = cur.col + kDirCol[d] * 2;
        if (nr <= 0 || nc <= 0 || nr >= size - 1 || nc >= size - 1) continue;
        if (!grid[nr][nc]) continue;
        grid[cur.row + kDirRow[d]][cur.col + kDirCol[d]] = false;
        grid[nr][nc] = false;
        stack.add(Pos(nr, nc));
        moved = true;
        break;
      }
      if (!moved) stack.removeLast();
    }
    return grid;
  }

  static int _pickDir(
    List<List<bool>> walls,
    int size,
    Pos start,
    Pos monster,
    Random rng,
  ) {
    final List<int> options = <int>[];
    for (var d = 0; d < 4; d++) {
      final int nr = start.row + kDirRow[d];
      final int nc = start.col + kDirCol[d];
      if (nr < 0 || nc < 0 || nr >= size || nc >= size) continue;
      if (walls[nr][nc]) continue;
      if (nr == monster.row && nc == monster.col) continue;
      options.add(d);
    }
    if (options.isEmpty) return 1;
    return options[rng.nextInt(options.length)];
  }

  /// BFS pada keadaan (baris, kolom, arah) untuk mencari rute
  /// paling efisien sampai berhadapan dengan monster.
  static _Solution _solve(
    List<List<bool>> walls,
    int size,
    Pos start,
    int startDir,
    Pos monster,
    int hp,
  ) {
    int key(int r, int c, int d) => (r * size + c) * 4 + d;
    final int startKey = key(start.row, start.col, startDir);

    final Map<int, int> dist = <int, int>{startKey: 0};
    final Map<int, int> parent = <int, int>{};
    final Map<int, GameCommand> stepCmd = <int, GameCommand>{};
    final List<int> queue = <int>[startKey];

    int? goalKey;
    var head = 0;
    while (head < queue.length) {
      final int k = queue[head++];
      final int d = dist[k]!;
      final int pos = k ~/ 4;
      final int r = pos ~/ size;
      final int c = pos % size;
      final int dir = k % 4;

      if (r + kDirRow[dir] == monster.row && c + kDirCol[dir] == monster.col) {
        goalKey = k;
        break;
      }

      // Belok kanan / kiri
      final int rightDir = (dir + 1) % 4;
      final int leftDir = (dir + 3) % 4;
      for (final int nd in <int>[rightDir, leftDir]) {
        final int nk = key(r, c, nd);
        if (dist.containsKey(nk)) continue;
        dist[nk] = d + 1;
        parent[nk] = k;
        stepCmd[nk] = nd == rightDir
            ? GameCommand.turnRight
            : GameCommand.turnLeft;
        queue.add(nk);
      }

      // Maju
      final int nr = r + kDirRow[dir];
      final int nc = c + kDirCol[dir];
      if (nr >= 0 && nc >= 0 && nr < size && nc < size) {
        if (!walls[nr][nc] && !(nr == monster.row && nc == monster.col)) {
          final int nk = key(nr, nc, dir);
          if (!dist.containsKey(nk)) {
            dist[nk] = d + 1;
            parent[nk] = k;
            stepCmd[nk] = GameCommand.forward;
            queue.add(nk);
          }
        }
      }
    }

    if (goalKey == null) {
      return const _Solution(<GameCommand>[], 0);
    }

    final List<GameCommand> path = <GameCommand>[];
    var cur = goalKey;
    while (cur != startKey) {
      path.add(stepCmd[cur]!);
      cur = parent[cur]!;
    }
    final List<GameCommand> commands = path.reversed.toList();
    return _Solution(commands, commands.length + hp);
  }

  static int _mergedRuns(List<GameCommand> commands) {
    var runs = 0;
    GameCommand? prev;
    for (final GameCommand c in commands) {
      if (c != prev) {
        runs++;
        prev = c;
      }
    }
    return runs;
  }
}

class _Solution {
  final List<GameCommand> commands;
  final int cost;

  const _Solution(this.commands, this.cost);
}

// ------------------------------------------------------------
// MESIN EKSEKUSI
// ------------------------------------------------------------
enum StepOutcome { moved, turned, hit, missed, blocked }

class MazeEngine {
  final MazeLevel level;

  int row;
  int col;
  int dir;
  int enemyHp;
  int steps;
  StepOutcome? last;

  MazeEngine(this.level)
      : row = level.start.row,
        col = level.start.col,
        dir = level.startDir,
        enemyHp = level.enemyHp,
        steps = 0;

  bool get defeated => enemyHp <= 0;

  bool get facingMonster {
    final int nr = row + kDirRow[dir];
    final int nc = col + kDirCol[dir];
    return nr == level.monster.row && nc == level.monster.col;
  }

  bool get canMove {
    final int nr = row + kDirRow[dir];
    final int nc = col + kDirCol[dir];
    if (level.isWall(nr, nc)) return false;
    if (level.isMonster(nr, nc)) return false;
    return true;
  }

  void reset() {
    row = level.start.row;
    col = level.start.col;
    dir = level.startDir;
    enemyHp = level.enemyHp;
    steps = 0;
    last = null;
  }

  StepOutcome apply(GameCommand command) {
    if (defeated) {
      return last ?? StepOutcome.blocked;
    }

    switch (command) {
      case GameCommand.turnRight:
        dir = (dir + 1) % 4;
        steps++;
        last = StepOutcome.turned;
        break;
      case GameCommand.turnLeft:
        dir = (dir + 3) % 4;
        steps++;
        last = StepOutcome.turned;
        break;
      case GameCommand.forward:
        steps++;
        if (canMove) {
          row += kDirRow[dir];
          col += kDirCol[dir];
          last = StepOutcome.moved;
        } else {
          last = StepOutcome.blocked;
        }
        break;
      case GameCommand.attack:
        steps++;
        if (facingMonster) {
          enemyHp = (enemyHp - 1).clamp(0, level.enemyHp);
          last = StepOutcome.hit;
        } else {
          last = StepOutcome.missed;
        }
        break;
    }
    return last!;
  }
}
