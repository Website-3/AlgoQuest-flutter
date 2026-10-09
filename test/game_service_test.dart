import 'package:flutter_application_1/services/game_service.dart';
import 'package:flutter_test/flutter_test.dart';

const List<List<int>> _deltas = <List<int>>[
  <int>[-1, 0],
  <int>[0, 1],
  <int>[1, 0],
  <int>[0, -1],
];

void main() {
  group('MazeCatalog', () {
    test('menyediakan 15 level (5 wilayah x 3 level)', () {
      expect(MazeCatalog.levels.length, 15);
      expect(MazeCatalog.regionCount, 5);
      expect(MazeCatalog.levelsPerRegion, 3);
    });

    test('posisi awal dan monster bukan dinding', () {
      for (final MazeLevel level in MazeCatalog.levels) {
        expect(
          level.walls[level.start.row][level.start.col],
          isFalse,
          reason: 'start level ${level.region}-${level.level}',
        );
        expect(
          level.walls[level.monster.row][level.monster.col],
          isFalse,
          reason: 'monster level ${level.region}-${level.level}',
        );
      }
    });

    test('setiap level punya solusi yang mengalahkan monster', () {
      for (final MazeLevel level in MazeCatalog.levels) {
        final MazeEngine engine = MazeEngine(level);
        for (final GameCommand command in level.solution) {
          engine.apply(command);
        }
        expect(
          engine.facingMonster,
          isTrue,
          reason: 'rute level ${level.region}-${level.level} '
              'tidak berakhir menghadap monster',
        );
        for (var i = 0; i < level.enemyHp; i++) {
          engine.apply(GameCommand.attack);
        }
        expect(engine.defeated, isTrue);
        expect(engine.steps, level.par);
      }
    });

    test('kuota blok cukup untuk menyusun solusi', () {
      for (final MazeLevel level in MazeCatalog.levels) {
        expect(level.maxBlocks, greaterThanOrEqualTo(1));
        expect(level.par, greaterThan(0));
      }
    });

    test('kesulitan naik: ukuran labirin dan HP monster bertambah', () {
      expect(MazeCatalog.level(0, 0).size,
          lessThanOrEqualTo(MazeCatalog.level(4, 2).size));
      expect(MazeCatalog.level(0, 0).enemyHp,
          lessThanOrEqualTo(MazeCatalog.level(4, 2).enemyHp));
    });
  });

  group('MazeEngine', () {
    test('belok kanan 4 kali kembali ke arah semula', () {
      final MazeEngine engine = MazeEngine(MazeCatalog.level(0, 0));
      final int startDir = engine.dir;
      for (var i = 0; i < 4; i++) {
        engine.apply(GameCommand.turnRight);
      }
      expect(engine.dir, startDir);
      expect(engine.steps, 4);
    });

    test('maju menabrak dinding ditandai blocked dan tidak berpindah', () {
      final MazeLevel level = MazeCatalog.level(0, 0);
      int? wallDir;
      for (var d = 0; d < 4; d++) {
        final int r = level.start.row + _deltas[d][0];
        final int c = level.start.col + _deltas[d][1];
        if (level.isWall(r, c)) {
          wallDir = d;
          break;
        }
      }
      expect(wallDir, isNotNull);

      final MazeEngine engine = MazeEngine(level);
      while (engine.dir != wallDir) {
        engine.apply(GameCommand.turnRight);
      }
      final int row0 = engine.row;
      final int col0 = engine.col;
      final StepOutcome outcome = engine.apply(GameCommand.forward);
      expect(outcome, StepOutcome.blocked);
      expect(engine.row, row0);
      expect(engine.col, col0);
    });

    test('serang saat tidak menghadap monster = meleset', () {
      final MazeEngine engine = MazeEngine(MazeCatalog.level(0, 0));
      final StepOutcome outcome = engine.apply(GameCommand.attack);
      expect(outcome, StepOutcome.missed);
      expect(engine.enemyHp, engine.level.enemyHp);
    });

    test('reset mengembalikan keadaan awal', () {
      final MazeEngine engine = MazeEngine(MazeCatalog.level(0, 0));
      engine.apply(GameCommand.turnRight);
      engine.apply(GameCommand.forward);
      engine.reset();
      expect(engine.row, engine.level.start.row);
      expect(engine.col, engine.level.start.col);
      expect(engine.dir, engine.level.startDir);
      expect(engine.steps, 0);
      expect(engine.enemyHp, engine.level.enemyHp);
    });
  });

  group('expandBlocks', () {
    test('menggabungkan hitungan blok menjadi perintah tunggal', () {
      final List<CommandBlock> blocks = <CommandBlock>[
        CommandBlock(GameCommand.forward, count: 3),
        CommandBlock(GameCommand.turnRight),
        CommandBlock(GameCommand.attack, count: 2),
      ];
      expect(expandBlocks(blocks), <GameCommand>[
        GameCommand.forward,
        GameCommand.forward,
        GameCommand.forward,
        GameCommand.turnRight,
        GameCommand.attack,
        GameCommand.attack,
      ]);
    });
  });
}
