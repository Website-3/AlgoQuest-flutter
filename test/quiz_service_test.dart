import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/quiz_service.dart';

void main() {
  test('ada 15 level dan total 75 soal (15 level x 5 soal)', () {
    expect(QuizCatalog.totalLevels, 15);
    expect(QuizCatalog.questionsPerLevel, 5);
    expect(QuizCatalog.totalQuestions, 75);
    expect(QuizCatalog.allLevels.length, 15);
    expect(QuizCatalog.questions.length, 75);
  });

  test('setiap level memiliki tepat 5 soal dengan tingkat kesulitan', () {
    for (int lvl = 1; lvl <= 15; lvl++) {
      final LevelQuizSet quizSet = QuizCatalog.getLevelQuiz(lvl);
      expect(quizSet.levelNumber, lvl);
      expect(quizSet.difficultyId.trim(), isNotEmpty);
      expect(quizSet.difficultyEn.trim(), isNotEmpty);
      expect(quizSet.questions.length, 5,
          reason: 'level $lvl harus punya 5 soal');
    }
  });

  test('setiap soal lengkap dengan 4 pilihan & 1 jawaban benar valid', () {
    for (int i = 0; i < QuizCatalog.questions.length; i++) {
      final QuizQuestion q = QuizCatalog.questions[i];

      expect(q.questionId.trim(), isNotEmpty, reason: 'soal $i ID');
      expect(q.questionEn.trim(), isNotEmpty, reason: 'soal $i EN');
      expect(q.explanationId.trim(), isNotEmpty, reason: 'penjelasan $i ID');
      expect(q.explanationEn.trim(), isNotEmpty, reason: 'penjelasan $i EN');

      // Tepat 4 pilihan, jumlah sama di kedua bahasa.
      expect(q.optionsId.length, 4, reason: 'soal $i optionsId harus 4');
      expect(q.optionsEn.length, 4, reason: 'soal $i optionsEn harus 4');

      // Tidak ada pilihan kosong.
      for (final String o in <String>[...q.optionsId, ...q.optionsEn]) {
        expect(o.trim(), isNotEmpty, reason: 'soal $i ada pilihan kosong');
      }

      // Index jawaban benar harus dalam rentang 0..3
      expect(q.correct, greaterThanOrEqualTo(0),
          reason: 'soal $i correct index');
      expect(q.correct, lessThan(4), reason: 'soal $i correct index < 4');
    }
  });

  test('tiap wilayah/level punya kuis sendiri yang berbeda', () {
    final Set<String> questionTexts = <String>{};
    for (final QuizQuestion q in QuizCatalog.questions) {
      expect(questionTexts.contains(q.questionId), isFalse,
          reason: 'pertanyaan tidak boleh berulang: ${q.questionId}');
      questionTexts.add(q.questionId);
    }
    expect(questionTexts.length, 75);
  });

  test('pemetaan region/level tidak keluar jangkauan (clamp)', () {
    expect(QuizCatalog.question(9, 9),
        same(QuizCatalog.allLevels[14].questions.first));
    expect(QuizCatalog.question(-1, -1),
        same(QuizCatalog.allLevels[0].questions.first));
  });

  test('helper question/options/explanation mengikuti bahasa', () {
    final QuizQuestion q = QuizCatalog.question(0, 0);
    expect(q.question(true), q.questionEn);
    expect(q.question(false), q.questionId);
    expect(q.options(true), q.optionsEn);
    expect(q.explanation(false), q.explanationId);
  });
}
