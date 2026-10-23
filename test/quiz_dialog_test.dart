import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/quiz_service.dart';
import 'package:flutter_application_1/widgets/quiz_dialog.dart';

/// Harness: satu tombol yang membuka dialog kuis dan menyimpan hasilnya.
Widget _harness({
  required int region,
  required int level,
  required bool isEnglish,
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
                isEnglish: isEnglish,
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
  testWidgets('jawaban benar: tampil penjelasan edukatif & lanjut ke hasil kuis',
      (tester) async {
    _bigScreen(tester);
    bool? result;
    final LevelQuizSet quizSet = QuizCatalog.getQuizByRegionAndLevel(0, 0);

    await tester.pumpWidget(
      _harness(
        region: 0,
        level: 0,
        isEnglish: false,
        onResult: (bool r) => result = r,
      ),
    );
    await tester.tap(find.text('BUKA'));
    await tester.pumpAndSettle();

    expect(find.text('Monster Dikalahkan!'), findsOneWidget);
    expect(find.textContaining('Kuis Level 1'), findsOneWidget);
    expect(find.text('Soal 1/5'), findsOneWidget);

    // Jawab 5 soal sampai selesai
    for (int i = 0; i < 5; i++) {
      final QuizQuestion q = quizSet.questions[i];
      expect(find.text(q.question(false)), findsOneWidget);

      await tester.tap(find.text(q.options(false)[q.correct]));
      await tester.pumpAndSettle();

      expect(find.text('Benar!'), findsOneWidget);
      expect(find.text(q.explanation(false)), findsOneWidget);

      if (i < 4) {
        await tester.tap(find.text('Soal Berikutnya \u25B8'));
        await tester.pumpAndSettle();
      } else {
        await tester.tap(find.text('Lihat Hasil Kuis \u25B8'));
        await tester.pumpAndSettle();
      }
    }

    // Tampilan Hasil Akhir Kuis
    expect(find.text('Kuis Selesai!'), findsOneWidget);
    expect(find.text('100'), findsOneWidget); // Skor 100
    expect(find.text('5/5'), findsOneWidget); // 5 dari 5 benar

    await tester.tap(find.text('Lanjut ke Level Berikutnya \u25B8'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets('jawaban salah: tampil umpan balik belum tepat & penjelasan',
      (tester) async {
    _bigScreen(tester);
    final LevelQuizSet quizSet = QuizCatalog.getQuizByRegionAndLevel(0, 0);
    final QuizQuestion q0 = quizSet.questions[0];
    final int wrong = q0.correct == 0 ? 1 : 0;

    await tester.pumpWidget(
      _harness(
        region: 0,
        level: 0,
        isEnglish: false,
        onResult: (_) {},
      ),
    );
    await tester.tap(find.text('BUKA'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(q0.options(false)[wrong]));
    await tester.pumpAndSettle();

    expect(find.text('Belum tepat.'), findsOneWidget);
    expect(find.text(q0.explanation(false)), findsOneWidget);
  });

  testWidgets('bahasa Inggris menampilkan Monster Defeated! & teks Inggris',
      (tester) async {
    _bigScreen(tester);
    final LevelQuizSet quizSet = QuizCatalog.getQuizByRegionAndLevel(1, 0);

    await tester.pumpWidget(
      _harness(
        region: 1,
        level: 0,
        isEnglish: true,
        onResult: (_) {},
      ),
    );
    await tester.tap(find.text('BUKA'));
    await tester.pumpAndSettle();

    expect(find.text('Monster Defeated!'), findsOneWidget);
    expect(find.textContaining('Quiz Level 4'), findsOneWidget);
    expect(find.text('Q 1/5'), findsOneWidget);
    expect(find.text(quizSet.questions[0].questionEn), findsOneWidget);
  });
}
