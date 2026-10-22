import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/game_page.dart';
import 'package:flutter_application_1/services/game_service.dart';
import 'package:flutter_application_1/widgets/hero_token.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

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
    // Karakter memakai widget bersama HeroToken (sama seperti Petualangan).
    expect(find.byType(HeroToken), findsOneWidget);
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

  testWidgets('menggabungkan perintah yang sama jadi satu blok', (
    tester,
  ) async {
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

  testWidgets('alur lengkap: jalankan solusi sampai monster kalah', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    final MazeLevel level = MazeCatalog.level(0, 0);

    Future<void> add(GameCommand command) async {
      final Finder button = find.byKey(ValueKey<String>('cmd_${command.name}'));
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
    for (final GameCommand command in <GameCommand>[
      ...level.solution,
      GameCommand.attack,
    ]) {
      if (command != prev) {
        runs++;
        prev = command;
      }
    }
    expect(find.text('$runs/${level.maxBlocks}'), findsOneWidget);

    final Finder run = find.text('JALANKAN');
    await tester.ensureVisible(run);
    await tester.tap(run);

    // Dorong timer sampai semua perintah selesai dieksekusi dan kuis muncul.
    for (
      var i = 0;
      i < 400 && find.text('Monster Dikalahkan!').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 250));
    }

    expect(find.text('Monster Dikalahkan!'), findsOneWidget);
    expect(find.text('Soal 1/5'), findsOneWidget);
  });

  testWidgets('arena mengisi hampir seluruh lebar layar ponsel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(wrap());
    await tester.pump();

    final Size arena = tester.getSize(
      find.byKey(const ValueKey<String>('maze_arena')),
    );

    // Arena harus hampir selebar layar (hanya menyisakan padding tipis),
    // dan tetap persegi agar labirin tidak gepeng.
    expect(arena.width, greaterThan(375));
    expect(arena.width, lessThanOrEqualTo(390));
    expect(arena.height, closeTo(arena.width, 0.5));
  });
}
