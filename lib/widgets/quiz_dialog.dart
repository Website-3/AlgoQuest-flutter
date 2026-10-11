import 'package:flutter/material.dart';

import '../services/juice.dart';
import '../services/quiz_service.dart';

// ============================================================
// DIALOG SOAL LOGIKA
// ============================================================
// Menampilkan satu soal pilihan ganda setelah monster dikalahkan.
// Pemain memilih satu jawaban, lalu melihat benar/salah beserta
// penjelasannya. Mengembalikan true bila jawabannya benar.

const Color _kCard = Color(0xFF1D2221);
const Color _kSoft = Color(0xFF283130);
const Color _kCyan = Color(0xFF42CFFF);
const Color _kGreen = Color(0xFF59C36A);
const Color _kPink = Color(0xFFFF5E7E);
const Color _kText = Color(0xFFDDE7E9);
const Color _kMuted = Color(0xFF8A9795);

/// Buka dialog soal. Mengembalikan apakah pemain menjawab benar
/// (false bila dialog ditutup tanpa menjawab).
Future<bool> showQuizDialog(
  BuildContext context, {
  required int region,
  required int level,
  required bool isEnglish,
}) async {
  final QuizQuestion q = QuizCatalog.question(region, level);
  final bool? correct = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) =>
        _QuizDialog(question: q, isEnglish: isEnglish),
  );
  return correct ?? false;
}

class _QuizDialog extends StatefulWidget {
  final QuizQuestion question;
  final bool isEnglish;

  const _QuizDialog({required this.question, required this.isEnglish});

  @override
  State<_QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<_QuizDialog> {
  /// Index pilihan yang sudah ditekan (null = belum menjawab).
  int? _picked;

  bool get _en => widget.isEnglish;
  QuizQuestion get q => widget.question;

  void _pick(int index) {
    if (_picked != null) return;
    setState(() => _picked = index);
    if (index == q.correct) {
      Juice.star();
    } else {
      Juice.error();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool answered = _picked != null;
    final bool isCorrect = _picked == q.correct;
    final List<String> options = q.options(_en);
    final Size size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: _kCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * 0.82),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ---- KEPALA ----
              Row(
                children: <Widget>[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: _kCyan.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.quiz_rounded,
                        color: _kCyan, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _en ? 'LOGIC QUESTION' : 'SOAL LOGIKA',
                          style: const TextStyle(
                            color: _kCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _en ? 'Answer to earn bonus' : 'Jawab untuk bonus',
                          style: const TextStyle(color: _kMuted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // ---- PERTANYAAN ----
                      Text(
                        q.question(_en),
                        style: const TextStyle(
                          color: _kText,
                          fontSize: 15,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ---- PILIHAN ----
                      for (int i = 0; i < options.length; i++) ...[
                        _optionButton(i),
                        if (i < options.length - 1) const SizedBox(height: 8),
                      ],

                      // ---- PENJELASAN ----
                      if (answered) ...[
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (isCorrect ? _kGreen : _kPink)
                                .withValues(alpha: 0.14),
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
                                    isCorrect
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: isCorrect ? _kGreen : _kPink,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    isCorrect
                                        ? (_en
                                              ? 'Correct!'
                                              : 'Benar!')
                                        : (_en
                                              ? 'Not quite.'
                                              : 'Belum tepat.'),
                                    style: TextStyle(
                                      color: isCorrect ? _kGreen : _kPink,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                q.explanation(_en),
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

              const SizedBox(height: 16),

              // ---- TOMBOL LANJUT ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: answered
                      ? () {
                          Juice.click();
                          Navigator.of(context).pop(isCorrect);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCyan,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: _kSoft,
                    disabledForegroundColor: _kMuted,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    answered
                        ? (_en ? 'Continue \u25B8' : 'Lanjut \u25B8')
                        : (_en ? 'Pick an answer' : 'Pilih jawaban'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _optionButton(int index) {
    final bool answered = _picked != null;
    final bool isThisCorrect = index == q.correct;
    final bool isThisPicked = index == _picked;

    Color border = _kCyan.withValues(alpha: 0.4);
    Color fill = _kCyan.withValues(alpha: 0.08);
    Color textColor = _kText;
    Widget? trail;

    if (answered) {
      if (isThisCorrect) {
        border = _kGreen;
        fill = _kGreen.withValues(alpha: 0.16);
        trail = const Icon(Icons.check_circle, color: _kGreen, size: 20);
      } else if (isThisPicked) {
        border = _kPink;
        fill = _kPink.withValues(alpha: 0.16);
        trail = const Icon(Icons.cancel, color: _kPink, size: 20);
      } else {
        border = _kSoft;
        fill = Colors.transparent;
        textColor = _kMuted;
      }
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: answered ? null : () => _pick(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: <Widget>[
            Text(
              String.fromCharCode(65 + index),
              style: TextStyle(
                color: border == _kSoft ? _kMuted : border,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                q.options(_en)[index],
                style: TextStyle(color: textColor, fontSize: 13.5),
              ),
            ),
            if (trail != null) ...[const SizedBox(width: 8), trail],
          ],
        ),
      ),
    );
  }
}
