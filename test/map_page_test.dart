import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kosongkan seluruh progres (state statis) sebelum tiap tes.
void resetProgress() {
  MapProgress.reset();
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });
  setUp(resetProgress);

  Widget wrap({void Function(int, int)? onStartLevel}) {
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

  // Buka Level 1 Wilayah 1. Kali pertama dialog cerita NPC muncul lebih
  // dulu; tutup dulu agar aksi berikutnya terlihat.
  Future<void> openLevel1(WidgetTester tester) async {
    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();
    final Finder story = find.text('Mengerti!');
    if (story.evaluate().isNotEmpty) {
      await tester.tap(story);
      await tester.pumpAndSettle();
    }
  }

  testWidgets('pertama kali level dibuka: cerita NPC lebih dulu', (
    tester,
  ) async {
    await bigScreen(tester);
    bool started = false;

    await tester.pumpWidget(
      wrap(onStartLevel: (region, level) => started = true),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(find.text('Profesor Bit'), findsOneWidget);
    expect(find.text('Hutan Algoritma'), findsOneWidget);
    expect(find.text('Mengerti!'), findsOneWidget);
    expect(started, isFalse);

    await tester.tap(find.text('Mengerti!'));
    await tester.pumpAndSettle();

    expect(started, isTrue);
  });

  testWidgets('mengetuk level langsung memulai permainan', (tester) async {
    await bigScreen(tester);
    MapProgress.storySeen[0] = true;

    int? pickedRegion;
    int? pickedLevel;

    await tester.pumpWidget(
      wrap(
        onStartLevel: (region, level) {
          pickedRegion = region;
          pickedLevel = level;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('1').first);
    await tester.pumpAndSettle();

    expect(pickedRegion, 0);
    expect(pickedLevel, 0);
  });

  testWidgets('tanpa host: mengetuk level mensimulasikan 3 bintang', (
    tester,
  ) async {
    await bigScreen(tester);
    MapProgress.storySeen[0] = true;

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await openLevel1(tester);

    expect(MapProgress.starsOf(0, 0), 3);
  });

  testWidgets('level terbuka menampilkan satu baris bintang', (tester) async {
    await bigScreen(tester);
    MapProgress.storySeen[0] = true;

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    // Tidak ada lagi ikon mode Petualangan/Arena Logika.
    expect(find.byIcon(Icons.explore), findsNothing);
    expect(find.byIcon(Icons.extension), findsNothing);

    // Wilayah terbuka punya tombol cerita.
    expect(find.byIcon(Icons.menu_book_rounded), findsOneWidget);

    // Level 2 & 3 masih terkunci.
    expect(find.text('Terkunci'), findsWidgets);
  });

  testWidgets('tombol cerita di kartu wilayah membuka ulang cerita', (
    tester,
  ) async {
    await bigScreen(tester);
    MapProgress.storySeen[0] = true;

    await tester.pumpWidget(wrap());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.menu_book_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Profesor Bit'), findsOneWidget);
    expect(find.text('Mengerti!'), findsOneWidget);
  });
}
