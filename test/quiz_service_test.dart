import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/quiz_service.dart';

void main() {
  test('ada tepat 15 soal (5 wilayah x 3 level)', () {
    expect(QuizCatalog.totalQuestions, 15);
    expect(QuizCatalog.questions.length, 15);
  });

  test('setiap soal lengkap & jawaban benar valid', () {
    for (int i = 0; i < QuizCatalog.questions.length; i++) {
      final QuizQuestion q = QuizCatalog.questions[i];

      expect(q.questionId.trim(), isNotEmpty, reason: 'soal $i');
      expect(q.questionEn.trim(), isNotEmpty, reason: 'soal $i');
      expect(q.explanationId.trim(), isNotEmpty, reason: 'soal $i');
      expect(q.explanationEn.trim(), isNotEmpty, reason: 'soal $i');

      // Minimal 2 pilihan, jumlah sama di kedua bahasa.
      expect(q.optionsId.length, greaterThanOrEqualTo(2), reason: 'soal $i');
      expect(q.optionsEn.length, q.optionsId.length, reason: 'soal $i');

      // Tidak ada pilihan kosong.
      for (final String o in <String>[...q.optionsId, ...q.optionsEn]) {
        expect(o.trim(), isNotEmpty, reason: 'soal $i');
      }

      // Index jawaban benar harus menunjuk pilihan yang ada.
      expect(q.correct, greaterThanOrEqualTo(0), reason: 'soal $i');
      expect(q.correct, lessThan(q.optionsId.length), reason: 'soal $i');
    }
  });

  test('tiap wilayah/level punya soal sendiri', () {
    expect(QuizCatalog.question(0, 0), same(QuizCatalog.questions[0]));
    expect(QuizCatalog.question(0, 2), same(QuizCatalog.questions[2]));
    expect(QuizCatalog.question(4, 2), same(QuizCatalog.questions[14]));
  });

  test('pemetaan region/level tidak keluar jangkauan (clamp)', () {
    expect(QuizCatalog.question(9, 9), same(QuizCatalog.questions[14]));
    expect(QuizCatalog.question(-1, -1), same(QuizCatalog.questions[0]));
  });

  test('helper question/options/explanation mengikuti bahasa', () {
    final QuizQuestion q = QuizCatalog.question(0, 0);
    expect(q.question(true), q.questionEn);
    expect(q.question(false), q.questionId);
    expect(q.options(true), q.optionsEn);
    expect(q.explanation(false), q.explanationId);
  });
}
