import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/adventure_page.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_application_1/services/game_service.dart';
import 'package:flutter_application_1/widgets/action_button.dart';
import 'package:flutter_application_1/widgets/hero_token.dart';
import 'package:flutter_application_1/widgets/hp_bar.dart';
import 'package:flutter_application_1/widgets/minimap.dart';
import 'package:flutter_application_1/widgets/virtual_joystick.dart';

MazeLevel _openLevel() {
  final List<List<bool>> walls = List<List<bool>>.generate(
    5,
    (_) => List<bool>.filled(5, false),
  );
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

Widget _wrap({bool debug = false, void Function(int stars)? onFinished}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Scaffold(
      body: AdventurePage(
        region: 0,
        level: 0,
        isEnglish: false,
        onLanguageChanged: () {},
        onBack: () {},
        onFinished: onFinished,
        debugLevel: debug ? _openLevel() : null,
      ),
    ),
  );
}

void _resetProgress() {
  for (var r = 0; r < MapProgress.regionCount; r++) {
    for (var l = 0; l < MapProgress.levelsPerRegion; l++) {
      MapProgress.setStars(r, l, GameMode.adventure, 0);
      MapProgress.setStars(r, l, GameMode.logic, 0);
    }
  }
}

void main() {
  setUp(_resetProgress);

  testWidgets('menampilkan elemen utama halaman petualangan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(AdventurePage), findsOneWidget);
    expect(find.byType(VirtualJoystick), findsOneWidget);
    expect(find.byType(HeroToken), findsOneWidget);
    expect(find.byType(Minimap), findsOneWidget);
    expect(find.textContaining('WILAYAH 1'), findsOneWidget);
    expect(find.text('Joystick / WASD untuk jelajah'), findsOneWidget);

    // Tidak boleh ada overflow.
    expect(tester.takeException(), isNull);
  });

  testWidgets('karakter bergerak saat tombol panah ditekan', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 50));

    final Offset before = tester.getTopLeft(find.byType(HeroToken));

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();

    final Offset after = tester.getTopLeft(find.byType(HeroToken));
    expect(after.dx, greaterThan(before.dx));
  });

  testWidgets('karakter bergerak saat joystick digeser', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap());
    await tester.pump(const Duration(milliseconds: 50));

    final Offset before = tester.getTopLeft(find.byType(HeroToken));

    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(VirtualJoystick)) + const Offset(24, 0),
    );
    for (int i = 0; i < 14; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await gesture.up();
    await tester.pump();

    final Offset after = tester.getTopLeft(find.byType(HeroToken));
    expect(after.dx, greaterThan(before.dx));
  });

  testWidgets('dekat monster memunculkan TEMPUR lalu masuk mode tempur', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_wrap(debug: true));
    await tester.pump(const Duration(milliseconds: 50));

    // Jauh dari monster → belum ada tombol TEMPUR.
    expect(find.textContaining('TEMPUR'), findsNothing);

    // Bergerak ke kanan lalu ke bawah mendekati monster (3,3).
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    for (int i = 0; i < 13; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
    for (int i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();

    expect(find.textContaining('TEMPUR'), findsOneWidget);

    // Mulai tempur.
    await tester.tap(find.textContaining('TEMPUR'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ActionButton), findsNWidgets(3));
    expect(find.text('SERANG'), findsOneWidget);
    expect(find.text('SKILL'), findsOneWidget);
    expect(find.text('DODGE'), findsOneWidget);
    expect(find.byType(HpBar), findsNWidgets(2));

    // Menyerang tidak menimbulkan error.
    await tester.tap(find.text('SERANG'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'menang memberi bintang mode Petualangan & memanggil onFinished',
    (WidgetTester tester) async {
      int? awarded;
      await tester.pumpWidget(
        _wrap(debug: true, onFinished: (int stars) => awarded = stars),
      );
      await tester.pump(const Duration(milliseconds: 50));

      // Dekati monster (3,3).
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
      for (int i = 0; i < 13; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
      for (int i = 0; i < 8; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();

      // Mulai tempur lalu serang berulang sampai monster tumbang.
      await tester.tap(find.textContaining('TEMPUR'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      for (
        int i = 0;
        i < 30 && find.text('SERANG').evaluate().isNotEmpty;
        i++
      ) {
        await tester.tap(find.text('SERANG'));
        for (int j = 0; j < 4; j++) {
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      // Panel hasil baru muncul setelah jeda animasi (ledakan + pop panel).
      expect(find.text('MENANG!'), findsNothing);
      for (int j = 0; j < 30; j++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('MENANG!'), findsOneWidget);
      expect(MapProgress.starsOf(0, 0, GameMode.adventure), greaterThan(0));

      // Kembali ke peta -> onFinished dipanggil dengan bintang.
      await tester.tap(find.text('KE PETA'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(awarded, isNotNull);
      expect(awarded, greaterThan(0));
    },
  );
}
