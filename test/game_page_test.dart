import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/game_page.dart';
import 'package:flutter_application_1/services/game_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap() {
    return MaterialApp(
      home: GamePage(
        region: 0,
        level: 0,
        isEnglish: false,
        onLanguageChanged: () {},
        onBack: () {},
      ),
    );
  }

  testWidgets('menampilkan elemen utama halaman permainan', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Quest'), findsOneWidget);
    expect(find.text('URUTAN LOGIKA'), findsOneWidget);
    expect(find.text('JALANKAN'), findsOneWidget);
    expect(find.text('Maju'), findsOneWidget);
    expect(find.text('Belok \u25B6'), findsOneWidget);
    expect(find.text('\u25C0 Belok'), findsOneWidget);
    expect(find.text('Serang'), findsOneWidget);
  });

  testWidgets('mengetuk perintah menambah blok', (tester) async {
    await tester.pumpWidget(wrap());
    final MazeLevel level = MazeCatalog.level(0, 0);

    expect(find.text('0/${level.maxBlocks}'), findsOneWidget);

    final Finder move = find.byKey(const ValueKey<String>('cmd_forward'));
    await tester.ensureVisible(move);
    await tester.tap(move);
    await tester.pump();

    expect(find.text('1/${level.maxBlocks}'), findsOneWidget);
  });

  testWidgets('menggabungkan perintah yang sama jadi satu blok', (tester) async {
    await tester.pumpWidget(wrap());
    final MazeLevel level = MazeCatalog.level(0, 0);

    final Finder move = find.byKey(const ValueKey<String>('cmd_forward'));
    await tester.ensureVisible(move);
    await tester.tap(move);
    await tester.pump();
    await tester.tap(move);
    await tester.pump();

    expect(find.text('1/${level.maxBlocks}'), findsOneWidget);
    expect(find.text('Maju  \u00D72'), findsOneWidget);
  });

  testWidgets('alur lengkap: jalankan solusi sampai monster kalah',
      (tester) async {
    await tester.pumpWidget(wrap());
    final MazeLevel level = MazeCatalog.level(0, 0);

    Future<void> add(GameCommand command) async {
      final Finder button =
          find.byKey(ValueKey<String>('cmd_${command.name}'));
      await tester.ensureVisible(button);
      await tester.tap(button);
      await tester.pump();
    }

    for (final GameCommand command in level.solution) {
      await add(command);
    }
    for (var i = 0; i < level.enemyHp; i++) {
      await add(GameCommand.attack);
    }

    // Semua blok harus tersusun (perintah berurutan digabung).
    var runs = 0;
    GameCommand? prev;
    for (final GameCommand command
        in <GameCommand>[...level.solution, GameCommand.attack]) {
      if (command != prev) {
        runs++;
        prev = command;
      }
    }
    expect(find.text('$runs/${level.maxBlocks}'), findsOneWidget);

    final Finder run = find.text('JALANKAN');
    await tester.ensureVisible(run);
    await tester.tap(run);

    // Dorong timer sampai semua perintah selesai dieksekusi.
    for (var i = 0;
        i < 400 && find.text('MONSTER DIKALAHKAN!').evaluate().isEmpty;
        i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.text('MONSTER DIKALAHKAN!'), findsOneWidget);
  });
}
