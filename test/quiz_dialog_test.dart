import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/quiz_service.dart';
import 'package:flutter_application_1/widgets/quiz_dialog.dart';

/// Harness: satu tombol yang membuka dialog soal dan menyimpan hasilnya.
Widget _harness({
  required int region,
  required int level,
  required ValueChanged<bool> onResult,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (BuildContext ctx) => Center(
          child: ElevatedButton(
            onPressed: () async {
              final bool r = await showQuizDialog(
                ctx,
                region: region,
                level: level,
                isEnglish: false,
              );
              onResult(r);
            },
            child: const Text('BUKA'),
          ),
        ),
      ),
    ),
  );
}

void _bigScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(1000, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('jawaban benar: tampil penjelasan & hasil true', (tester) async {
    _bigScreen(tester);
    bool? result;
    final QuizQuestion q = QuizCatalog.question(0, 0);

    await tester.pumpWidget(
      _harness(region: 0, level: 0, onResult: (bool r) => result = r),
    );
    await tester.tap(find.text('BUKA'));
    await tester.pumpAndSettle();

    expect(find.text('SOAL LOGIKA'), findsOneWidget);
    expect(find.text(q.question(false)), findsOneWidget);
    expect(find.text('Pilih jawaban'), findsOneWidget);

    await tester.tap(find.text(q.options(false)[q.correct]));
    await tester.pumpAndSettle();

    expect(find.text('Benar!'), findsOneWidget);
    expect(find.text(q.explanation(false)), findsOneWidget);

    await tester.tap(find.text('Lanjut \u25B8'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('jawaban salah: tampil koreksi & hasil false', (tester) async {
    _bigScreen(tester);
    bool? result;
    final QuizQuestion q = QuizCatalog.question(0, 0);
    final int wrong = q.correct == 0 ? 1 : 0;

    await tester.pumpWidget(
      _harness(region: 0, level: 0, onResult: (bool r) => result = r),
    );
    await tester.tap(find.text('BUKA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(q.options(false)[wrong]));
    await tester.pumpAndSettle();

    expect(find.text('Belum tepat.'), findsOneWidget);
    expect(find.text(q.explanation(false)), findsOneWidget);

    await tester.tap(find.text('Lanjut \u25B8'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets('bahasa Inggris menampilkan teks Inggris', (tester) async {
    _bigScreen(tester);
    final QuizQuestion q = QuizCatalog.question(1, 0);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (BuildContext ctx) => Center(
              child: ElevatedButton(
                onPressed: () => showQuizDialog(
                  ctx,
                  region: 1,
                  level: 0,
                  isEnglish: true,
                ),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('LOGIC QUESTION'), findsOneWidget);
    expect(find.text(q.questionEn), findsOneWidget);
    expect(find.text('Pick an answer'), findsOneWidget);
  });
}
