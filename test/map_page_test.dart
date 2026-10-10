import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_test/flutter_test.dart';

/// Kosongkan seluruh progres (state statis) sebelum tiap tes.
void resetProgress() {
  for (var r = 0; r < MapProgress.regionCount; r++) {
    for (var l = 0; l < MapProgress.levelsPerRegion; l++) {
      MapProgress.setStars(r, l, GameMode.adventure, 0);
      MapProgress.setStars(r, l, GameMode.logic, 0);
    }
  }
}

void main() {
  setUp(resetProgress);

  Widget wrap({void Function(int, int, GameMode)? onStartLevel}) {
    return MaterialApp(
      home: MapPage(
        isEnglish: false,
        onLanguageChanged: () {},
        onStartLevel: onStartLevel,
      ),
    );
  }

  // Layar tinggi agar dialog tidak kehabisan ruang (font tes = Ahem).
  Future<void> bigScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets('mengetuk level membuka dialog pilih mode', (tester) async {
    await bigScreen(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Level 1 wilayah 1 adalah satu-satunya yang terbuka (angka "1").
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(find.text('Pilih mode:'), findsOneWidget);
    expect(find.text('Petualangan'), findsOneWidget);
    expect(find.text('Arena Logika'), findsOneWidget);
  });

  testWidgets('memilih Petualangan memanggil onStartLevel(adventure)', (
    tester,
  ) async {
    await bigScreen(tester);
    GameMode? picked;
    int? pickedRegion;
    int? pickedLevel;

    await tester.pumpWidget(
      wrap(
        onStartLevel: (region, level, mode) {
          pickedRegion = region;
          pickedLevel = level;
          picked = mode;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Petualangan'));
    await tester.pumpAndSettle();

    expect(picked, GameMode.adventure);
    expect(pickedRegion, 0);
    expect(pickedLevel, 0);
  });

  testWidgets('memilih Arena Logika memanggil onStartLevel(logic)', (
    tester,
  ) async {
    await bigScreen(tester);
    GameMode? picked;

    await tester.pumpWidget(
      wrap(onStartLevel: (region, level, mode) => picked = mode),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arena Logika'));
    await tester.pumpAndSettle();

    expect(picked, GameMode.logic);
  });

  testWidgets('tanpa host: memilih mode mensimulasikan 3 bintang', (
    tester,
  ) async {
    await bigScreen(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Arena Logika'));
    await tester.pumpAndSettle();

    expect(MapProgress.starsOf(0, 0, GameMode.logic), 3);
    expect(MapProgress.starsOf(0, 0, GameMode.adventure), 0);
  });

  testWidgets('level terbuka menampilkan bintang dua mode', (tester) async {
    await bigScreen(tester);
    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Hanya level 1 wilayah 1 yang terbuka -> satu baris ikon tiap mode.
    expect(find.byIcon(Icons.explore), findsOneWidget);
    expect(find.byIcon(Icons.extension), findsOneWidget);

    // Level 2 & 3 masih terkunci.
    expect(find.text('Terkunci'), findsWidgets);
  });
}
