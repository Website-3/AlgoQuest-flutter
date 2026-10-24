import 'package:flutter/material.dart';

import '../services/juice.dart';
import '../services/quiz_service.dart';

// ============================================================
// DIALOG KUIS 15 LEVEL — ALGOQUEST
// ============================================================
// Menampilkan kuis 5 soal setelah monster dikalahkan di setiap
// level (Level 1 sampai Level 15).
// Fitur:
//   - Judul "Monster Dikalahkan!"
//   - Label Level & Tingkat Kesulitan (Pemula / Menengah / Sulit)
//   - Indikator progres "Soal X dari 5"
//   - 4 Pilihan ganda (A, B, C, D) dengan 1 jawaban benar
//   - Umpan balik langsung & penjelasan edukatif
//   - Skor akhir & penyelesaian khusus Level 15 (Final Game)

const Color _kCard = Color(0xFF131818);
const Color _kSoft = Color(0xFF1F2727);
const Color _kCyan = Color(0xFF42CFFF);
const Color _kGreen = Color(0xFF59C36A);
const Color _kPink = Color(0xFFFF5E7E);
const Color _kGold = Color(0xFFFFC043);
const Color _kText = Color(0xFFE2EDEF);
const Color _kMuted = Color(0xFF8D9C9A);

/// Buka dialog kuis level setelah monster dikalahkan.
/// Mengembalikan true bila kuis berhasil diselesaikan.
Future<bool> showQuizDialog(
  BuildContext context, {
  required int region,
  required int level,
  required bool isEnglish,
}) async {
  final int globalLevel = region * 3 + level + 1;
  final LevelQuizSet quizSet =
      QuizCatalog.getQuizByRegionAndLevel(region, level);

  final bool? result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) => _LevelQuizDialog(
      quizSet: quizSet,
      globalLevel: globalLevel,
      isEnglish: isEnglish,
      isFinalLevel: globalLevel == 15,
    ),
  );
  return result ?? false;
}

class _LevelQuizDialog extends StatefulWidget {
  final LevelQuizSet quizSet;
  final int globalLevel;
  final bool isEnglish;
  final bool isFinalLevel;

  const _LevelQuizDialog({
    required this.quizSet,
    required this.globalLevel,
    required this.isEnglish,
    required this.isFinalLevel,
  });

  @override
  State<_LevelQuizDialog> createState() => _LevelQuizDialogState();
}

class _LevelQuizDialogState extends State<_LevelQuizDialog> {
  int _currentIndex = 0;
  int? _picked;
  int _correctCount = 0;
  bool _isFinished = false;

  bool get _en => widget.isEnglish;
  List<QuizQuestion> get _questions => widget.quizSet.questions;
  QuizQuestion get _currentQ => _questions[_currentIndex];

  void _pickOption(int index) {
    if (_picked != null) return;
    setState(() {
      _picked = index;
      if (index == _currentQ.correct) {
        _correctCount++;
        Juice.star();
      } else {
        Juice.error();
      }
    });
  }

  void _nextQuestion() {
    Juice.click();
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _picked = null;
      });
    } else {
      // Selesai seluruh 5 soal
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: _kCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(
          color: widget.isFinalLevel ? _kGold : _kCyan.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 580,
          maxHeight: size.height * 0.88,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
          child: _isFinished ? _buildResultView() : _buildQuestionView(),
        ),
      ),
    );
  }

  // ==========================================================
  // TAMPILAN PERTANYAAN
  // ==========================================================
  Widget _buildQuestionView() {
    final bool answered = _picked != null;
    final bool isCorrect = _picked == _currentQ.correct;
    final List<String> options = _currentQ.options(_en);
    final String diff = widget.quizSet.difficulty(_en);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        // ---- HEADER PERTANYAAN ----
        Row(
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _kGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: _kGold.withValues(alpha: 0.5)),
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: _kGold,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _en ? 'Monster Defeated!' : 'Monster Dikalahkan!',
                    style: const TextStyle(
                      color: _kGold,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _kCyan.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: _kCyan.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      _en
                          ? 'Quiz Level ${widget.globalLevel} — $diff'
                          : 'Kuis Level ${widget.globalLevel} — $diff',
                      style: const TextStyle(
                        color: _kCyan,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Indikator Progres Soal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _kSoft,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: Text(
                _en
                    ? 'Q ${_currentIndex + 1}/5'
                    : 'Soal ${_currentIndex + 1}/5',
                style: const TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Garis Bar Progres Soal
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            minHeight: 5,
            backgroundColor: _kSoft,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.isFinalLevel ? _kGold : _kCyan,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ---- KONTEN PERTANYAAN (SCROLLABLE) ----
        Flexible(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Kotak Teks Pertanyaan
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _kSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _currentQ.question(_en),
                    style: const TextStyle(
                      color: _kText,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 4 Pilihan Jawaban
                for (int i = 0; i < options.length; i++) ...[
                  _buildOptionTile(i, options[i]),
                  if (i < options.length - 1) const SizedBox(height: 8),
                ],

                // Kotak Umpan Balik & Penjelasan Edukatif
                if (answered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (isCorrect ? _kGreen : _kPink)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (isCorrect ? _kGreen : _kPink)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? _kGreen : _kPink,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isCorrect
                                  ? (_en ? 'Correct!' : 'Benar!')
                                  : (_en ? 'Not quite right.' : 'Belum tepat.'),
                              style: TextStyle(
                                color: isCorrect ? _kGreen : _kPink,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Tampilkan jawaban yang benar jika jawaban salah
                        if (!isCorrect) ...[ 
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: _kGreen.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _kGreen.withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Icon(Icons.check_circle_outline,
                                    color: _kGreen, size: 15),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    _en
                                        ? 'Correct answer: . '
                                        : 'Jawaban yang benar: . ',
                                    style: const TextStyle(
                                      color: _kGreen,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        Text(
                          _currentQ.explanation(_en),
                          style: const TextStyle(
                            color: _kText,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 14),

        // ---- TOMBOL LANJUT ----
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: answered ? _nextQuestion : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _kCyan,
              foregroundColor: Colors.black,
              disabledBackgroundColor: _kSoft,
              disabledForegroundColor: _kMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Text(
              answered
                  ? (_currentIndex < _questions.length - 1
                      ? (_en ? 'Next Question \u25B8' : 'Soal Berikutnya \u25B8')
                      : (_en
                          ? 'View Quiz Results \u25B8'
                          : 'Lihat Hasil Kuis \u25B8'))
                  : (_en
                      ? 'Pick an answer above'
                      : 'Pilih salah satu jawaban di atas'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TOMBOL PILIHAN JAWABAN (A, B, C, D)
  // ==========================================================
  Widget _buildOptionTile(int index, String optionText) {
    final bool answered = _picked != null;
    final bool isThisCorrect = index == _currentQ.correct;
    final bool isThisPicked = index == _picked;

    Color border = _kCyan.withValues(alpha: 0.3);
    Color fill = _kSoft;
    Color textColor = _kText;
    Widget? icon;

    if (answered) {
      if (isThisPicked && !isThisCorrect) {
        // Pilihan yang dipilih tapi salah → warna merah/pink
        border = _kPink;
        fill = _kPink.withValues(alpha: 0.16);
        textColor = Colors.white;
        icon = const Icon(Icons.cancel, color: _kPink, size: 20);
      } else if (!isThisPicked) {
        // Pilihan yang tidak dipilih → warna netral redup
        border = Colors.white10;
        fill = _kSoft.withValues(alpha: 0.5);
        textColor = _kMuted;
      }
      // isThisPicked && isThisCorrect → tetap warna default (cyan/biru netral)
    }

    final String letter = String.fromCharCode(65 + index);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: answered ? null : () => _pickOption(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isThisCorrect ? 1.5 : 1),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Kotak huruf: pink jika salah pilih, cyan default untuk semua
                color: (isThisPicked && !isThisCorrect)
                    ? _kPink
                    : _kCyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                letter,
                style: TextStyle(
                  color: (isThisPicked && !isThisCorrect)
                      ? Colors.black
                      : _kCyan,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                optionText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 13.5,
                  height: 1.35,
                ),
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              icon,
            ],
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TAMPILAN HASIL SKOR / PENYELESAIAN GAME (LEVEL 15)
  // ==========================================================
  Widget _buildResultView() {
    final int score = ((_correctCount / _questions.length) * 100).round();
    final bool isPassed = _correctCount >= 3;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 10),

          // Icon Trofi Kemenangan
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: (widget.isFinalLevel ? _kGold : _kCyan)
                  .withValues(alpha: 0.18),
              shape: BoxShape.circle,
              border: Border.all(
                color: (widget.isFinalLevel ? _kGold : _kCyan),
                width: 2,
              ),
            ),
            child: Icon(
              widget.isFinalLevel
                  ? Icons.military_tech_rounded
                  : Icons.emoji_events_rounded,
              color: widget.isFinalLevel ? _kGold : _kCyan,
              size: 42,
            ),
          ),

          const SizedBox(height: 14),

          // Judul Hasil
          Text(
            widget.isFinalLevel
                ? (_en
                    ? '\u{1F3C6} CONGRATULATIONS! GAME COMPLETE!'
                    : '\u{1F3C6} SELAMAT! GAME SELESAI!')
                : (_en ? 'Quiz Completed!' : 'Kuis Selesai!'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: widget.isFinalLevel ? _kGold : _kText,
              fontWeight: FontWeight.bold,
              fontSize: widget.isFinalLevel ? 18 : 19,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          // Subjudul
          Text(
            widget.isFinalLevel
                ? (_en
                    ? 'You conquered all 15 Levels of Algorithm Forest and defeated Logic Behemoth!'
                    : 'Kamu telah menuntaskan seluruh 15 Level Hutan Algoritma dan mengalahkan Behemoth Logika!')
                : (_en
                    ? 'Level ${widget.globalLevel} Evaluation — ${widget.quizSet.difficultyEn}'
                    : 'Hasil Evaluasi Level ${widget.globalLevel} — ${widget.quizSet.difficultyId}'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _kMuted,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 18),

          // Kartu Skor
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: _kSoft,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isFinalLevel
                    ? _kGold.withValues(alpha: 0.5)
                    : Colors.white12,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                // Skor Angka
                Column(
                  children: <Widget>[
                    Text(
                      '$score',
                      style: TextStyle(
                        color: isPassed ? _kGreen : _kPink,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _en ? 'Score' : 'Skor Akhir',
                      style: const TextStyle(color: _kMuted, fontSize: 12),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: Colors.white12,
                ),
                // Jawaban Benar
                Column(
                  children: <Widget>[
                    Text(
                      '$_correctCount/5',
                      style: const TextStyle(
                        color: _kCyan,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _en ? 'Correct Answers' : 'Jawaban Benar',
                      style: const TextStyle(color: _kMuted, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Tombol Aksi Akhir
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Juice.click();
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.isFinalLevel ? _kGold : _kCyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    widget.isFinalLevel
                        ? (_en
                            ? 'Finish & Return to Menu'
                            : 'Selesai & Kembali ke Menu')
                        : (_en
                            ? 'Continue to Next Level \u25B8'
                            : 'Lanjut ke Level Berikutnya \u25B8'),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }
}
