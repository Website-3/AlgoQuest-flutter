import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/game_page.dart';

// ============================================================
// TES HALAMAN PERMAINAN
// ============================================================
// Memastikan komponen inti sesuai wireframe:
// arena, blok perintah, urutan eksekusi, indikator status,
// dan tombol EKSEKUSI / RUN CODE — plus alur menang penuh.

Future<void> _pumpGame(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: GamePage(
        region: 0,
        level: 0,
        isEnglish: false,
        onLanguageChanged: () {},
        onBack: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Ketuk chip palette (sudah diberi key `palette_<kind>`).
Future<void> _tapPalette(WidgetTester tester, String kind) async {
  final Finder f = find.byKey(ValueKey<String>('palette_$kind'));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('halaman menampilkan komponen inti sesuai wireframe', (
    WidgetTester tester,
  ) async {
    await _pumpGame(tester);

    // Header + tombol eksekusi
    expect(find.text('Quest'), findsOneWidget);
    expect(find.text('EKSEKUSI / RUN CODE'), findsOneWidget);

    // Attack Strategy
    expect(find.text('Attack Strategy'), findsOneWidget);

    // Panel eksekusi & zona jatuh
    expect(find.text('EXECUTION SEQUENCE'), findsOneWidget);
    expect(find.text('AVAILABLE COMMANDS'), findsOneWidget);
    expect(find.text('Drop next block here'), findsWidgets);
    expect(find.text('Belum ada blok. Ketuk perintah atau jatuhkan blok di sini.'), findsOneWidget);

    // Indikator status
    expect(find.text('Blok '), findsOneWidget);
    expect(find.text('Energi '), findsOneWidget);
    expect(find.text('Langkah '), findsOneWidget);

    // Bar HP karakter
    expect(find.text('HP: 100/100'), findsOneWidget);

    // Konsol output
    expect(find.text('OUTPUT'), findsOneWidget);

    // Zona kosong saat belum ada blok hanya tampil SEKALI
    // (tidak dobel di dalam maupun luar _emptySequence).
    expect(find.text('Drop next block here'), findsOneWidget);
  });

  testWidgets('menyusun blok lalu menekan EKSEKUSI menghasilkan kemenangan', (
    WidgetTester tester,
  ) async {
    await _pumpGame(tester);

    // Susun solusi Level 1: Maju, Maju, Putar(Kanan), Maju
    await _tapPalette(tester, 'forward');
    await _tapPalette(tester, 'forward');
    await _tapPalette(tester, 'turnRight');
    await _tapPalette(tester, 'forward');

    // Kuota blok terpakai4 / 8
    expect(find.text('4 / 8'), findsOneWidget);
    expect(find.text('4 sisa'), findsOneWidget);

    // Jalankan
    final Finder run = find.text('EKSEKUSI / RUN CODE');
    await tester.ensureVisible(run);
    await tester.pumpAndSettle();
    await tester.tap(run);

    bool won = false;
    for (int i = 0; i < 80; i++) {
      await tester.pump(const Duration(milliseconds: 400));
      if (find.text('Tantangan selesai!').evaluate().isNotEmpty) {
        won = true;
        break;
      }
    }

    expect(won, isTrue, reason: 'Dialog kemenangan tidak muncul');
    expect(find.text('Kembali ke Peta'), findsOneWidget);

    // Tombol bintang tampil (3 bintang untuk solusi par)
    expect(find.byIcon(Icons.star_rounded), findsNWidgets(3));
  });

  testWidgets('mengetuk zona jatuh membuka pemilih blok', (
    WidgetTester tester,
  ) async {
    await _pumpGame(tester);

    final Finder zone = find.text('Drop next block here').first;
    await tester.ensureVisible(zone);
    await tester.pumpAndSettle();
    await tester.tap(zone);
    await tester.pumpAndSettle();

    expect(find.text('Pilih Blok Perintah'), findsOneWidget);
    expect(find.text('0 / 8 blok terpakai'), findsOneWidget);
  });
}
