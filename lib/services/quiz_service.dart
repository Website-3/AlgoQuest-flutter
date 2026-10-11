// ============================================================
// SOAL LOGIKA — KUIS SETELAH MONSTER DIKALAHKAN
// ============================================================
// Satu soal pilihan ganda untuk tiap level (15 soal). Soal
// mendidik: urutan, variabel, percabangan, perulangan, dan
// gabungan. Teks dwibahasa (Indonesia / Inggris).
//
// Index soal = wilayah * 3 + level.

class QuizQuestion {
  final String questionId;
  final String questionEn;

  /// Pilihan jawaban (urutan sama untuk kedua bahasa).
  final List<String> optionsId;
  final List<String> optionsEn;

  /// Index jawaban benar (0-based).
  final int correct;

  /// Penjelasan singkat setelah menjawab.
  final String explanationId;
  final String explanationEn;

  const QuizQuestion({
    required this.questionId,
    required this.questionEn,
    required this.optionsId,
    required this.optionsEn,
    required this.correct,
    required this.explanationId,
    required this.explanationEn,
  });

  String question(bool en) => en ? questionEn : questionId;
  List<String> options(bool en) => en ? optionsEn : optionsId;
  String explanation(bool en) => en ? explanationEn : explanationId;
}

class QuizCatalog {
  QuizCatalog._();

  static const int regionCount = 5;
  static const int levelsPerRegion = 3;
  static const int totalQuestions = regionCount * levelsPerRegion; // 15

  static const List<QuizQuestion> questions = <QuizQuestion>[
    // ================= WILAYAH 1 — URUTAN / ALGORITMA =================
    QuizQuestion(
      questionId: 'Kamu memasak mi instan. Mana urutan langkah yang paling tepat?',
      questionEn: 'You are cooking instant noodles. Which step order is best?',
      optionsId: <String>[
        'Rebus air, masukkan mi, tiriskan',
        'Masukkan mi, rebus air, tiriskan',
        'Tiriskan, rebus air, masukkan mi',
      ],
      optionsEn: <String>[
        'Boil water, add noodles, drain',
        'Add noodles, boil water, drain',
        'Drain, boil water, add noodles',
      ],
      correct: 0,
      explanationId:
          'Algoritma adalah langkah berurutan yang benar. Air harus mendidih lebih dulu sebelum mi masuk.',
      explanationEn:
          'An algorithm is a correct sequence of steps. Water must boil before the noodles go in.',
    ),
    QuizQuestion(
      questionId: 'Langkah pertama saat membuat sebuah algoritma adalah ...',
      questionEn: 'The first step when building an algorithm is ...',
      optionsId: <String>[
        'Langsung menulis semua perintah',
        'Menentukan tujuan atau masalah dengan jelas',
        'Menghapus semua langkah',
      ],
      optionsEn: <String>[
        'Write all commands right away',
        'Define the goal or problem clearly',
        'Delete every step',
      ],
      correct: 1,
      explanationId:
          'Sebelum menyusun langkah, kita harus tahu dulu apa yang ingin dicapai. Tujuan yang jelas membuat langkah lebih tepat.',
      explanationEn:
          'Before arranging steps, we must know what we want to achieve. A clear goal makes the steps more accurate.',
    ),
    QuizQuestion(
      questionId:
          'Dari petak 0, perintah "maju" diulang 3 kali. Kamu berhenti di petak ke berapa?',
      questionEn:
          'From tile 0, the "move forward" command runs 3 times. Which tile do you stop on?',
      optionsId: <String>['Petak 3', 'Petak 4', 'Petak 2'],
      optionsEn: <String>['Tile 3', 'Tile 4', 'Tile 2'],
      correct: 0,
      explanationId: 'Maju 3 kali berarti berpindah 3 petak: 0 menjadi 3.',
      explanationEn: 'Moving 3 times moves 3 tiles: 0 becomes 3.',
    ),

    // ================= WILAYAH 2 — VARIABEL / OPERATOR =================
    QuizQuestion(
      questionId: 'Jika x = 5, lalu x = x + 3. Berapa nilai x sekarang?',
      questionEn: 'If x = 5, then x = x + 3. What is x now?',
      optionsId: <String>['8', '53', '2'],
      optionsEn: <String>['8', '53', '2'],
      correct: 0,
      explanationId:
          'x + 3 = 5 + 3 = 8, lalu nilai 8 disimpan kembali ke x.',
      explanationEn: 'x + 3 = 5 + 3 = 8, then 8 is stored back into x.',
    ),
    QuizQuestion(
      questionId: 'Variabel paling mirip dengan ...',
      questionEn: 'A variable is most like a ...',
      optionsId: <String>[
        'Kotak penyimpan nilai',
        'Penghapus papan tulis',
        'Lampu yang menyala',
      ],
      optionsEn: <String>[
        'Box that stores a value',
        'Whiteboard eraser',
        'Light that turns on',
      ],
      correct: 0,
      explanationId:
          'Variabel adalah wadah untuk menyimpan nilai yang bisa dipakai dan diubah.',
      explanationEn:
          'A variable is a container that stores a value you can use and change.',
    ),
    QuizQuestion(
      questionId: 'Jika a = 10 dan b = 4, berapa hasil dari a - b?',
      questionEn: 'If a = 10 and b = 4, what is a - b?',
      optionsId: <String>['6', '14', '40'],
      optionsEn: <String>['6', '14', '40'],
      correct: 0,
      explanationId: 'Operator "-" mengurangi: 10 - 4 = 6.',
      explanationEn: 'The "-" operator subtracts: 10 - 4 = 6.',
    ),

    // ================= WILAYAH 3 — KONDISI / PERCABANGAN =================
    QuizQuestion(
      questionId:
          '"Jika hujan, maka bawa payung." Sekarang hujan. Apa yang kita lakukan?',
      questionEn:
          '"If it rains, then bring an umbrella." Now it rains. What do we do?',
      optionsId: <String>[
        'Membawa payung',
        'Tidak membawa payung',
        'Menunggu hujan berhenti',
      ],
      optionsEn: <String>[
        'Bring an umbrella',
        'Do not bring an umbrella',
        'Wait for the rain to stop',
      ],
      correct: 0,
      explanationId:
          'Karena syarat "hujan" terpenuhi, tindakan "bawa payung" dijalankan.',
      explanationEn:
          'Because the "rain" condition holds, the action "bring an umbrella" runs.',
    ),
    QuizQuestion(
      questionId: 'Percabangan "jika ... maka ..." berguna untuk ...',
      questionEn: 'The "if ... then ..." branch is useful to ...',
      optionsId: <String>[
        'Memilih tindakan berdasarkan suatu syarat',
        'Mengulang perintah terus-menerus',
        'Menyimpan banyak angka sekaligus',
      ],
      optionsEn: <String>[
        'Choose an action based on a condition',
        'Repeat commands over and over',
        'Store many numbers at once',
      ],
      correct: 0,
      explanationId:
          'Percabangan membuat program memilih jalan sesuai syarat yang benar atau salah.',
      explanationEn:
          'Branching makes the program choose a path depending on whether the condition is true or false.',
    ),
    QuizQuestion(
      questionId:
          'Syarat "umur >= 17". Jika umur = 15, apakah syarat itu benar?',
      questionEn:
          'Condition "age >= 17". If age = 15, is the condition true?',
      optionsId: <String>['Ya, benar', 'Tidak, salah', 'Tidak bisa ditentukan'],
      optionsEn: <String>['Yes, true', 'No, false', 'Cannot be determined'],
      correct: 1,
      explanationId:
          '15 >= 17 salah, karena 15 lebih kecil daripada 17. Jadi syaratnya tidak terpenuhi.',
      explanationEn:
          '15 >= 17 is false, because 15 is less than 17. So the condition is not met.',
    ),

    // ================= WILAYAH 4 — PERULANGAN =================
    QuizQuestion(
      questionId: '"Ulangi 4 kali: cetak Halo." Berapa kali kata Halo tercetak?',
      questionEn: '"Repeat 4 times: print Hello." How many times is Hello printed?',
      optionsId: <String>['4 kali', '1 kali', '3 kali'],
      optionsEn: <String>['4 times', '1 time', '3 times'],
      correct: 0,
      explanationId:
          'Perulangan "ulangi 4 kali" menjalankan isi blok tepat 4 kali.',
      explanationEn: 'A "repeat 4 times" loop runs its body exactly 4 times.',
    ),
    QuizQuestion(
      questionId: 'Dengan perulangan, kita bisa ...',
      questionEn: 'With a loop, we can ...',
      optionsId: <String>[
        'Menulis perintah berulang tanpa menyalinnya berkali-kali',
        'Menghapus semua perintah',
        'Menghentikan program selamanya',
      ],
      optionsEn: <String>[
        'Repeat commands without copying them many times',
        'Delete all commands',
        'Stop the program forever',
      ],
      correct: 0,
      explanationId:
          'Perulangan menghemat penulisan: satu blok, dijalankan berkali-kali.',
      explanationEn:
          'A loop saves writing: one block, run many times.',
    ),
    QuizQuestion(
      questionId:
          'Mulai dari 0, tiap putaran tambah 2. Setelah 3 kali putaran, berapa hasilnya?',
      questionEn:
          'Start at 0, add 2 each round. After 3 rounds, what is the result?',
      optionsId: <String>['6', '5', '8'],
      optionsEn: <String>['6', '5', '8'],
      correct: 0,
      explanationId: '0 -> 2 -> 4 -> 6. Setelah 3 kali menambah 2, hasilnya 6.',
      explanationEn: '0 -> 2 -> 4 -> 6. After adding 2 three times, the result is 6.',
    ),

    // ================= WILAYAH 5 — GABUNGAN =================
    QuizQuestion(
      questionId:
          'Kamu sedang menghadap ke utara, lalu "belok kanan" 3 kali. Sekarang kamu menghadap ke arah?',
      questionEn:
          'You face north, then "turn right" 3 times. Which way do you face now?',
      optionsId: <String>['Barat', 'Timur', 'Selatan'],
      optionsEn: <String>['West', 'East', 'South'],
      correct: 0,
      explanationId:
          'Utara -> Timur -> Selatan -> Barat. Belok kanan 3 kali berakhir di arah barat.',
      explanationEn:
          'North -> East -> South -> West. Turning right 3 times ends facing west.',
    ),
    QuizQuestion(
      questionId:
          'x = 2. Lalu "ulangi 3 kali: x = x * 2". Berapa nilai x setelah selesai?',
      questionEn:
          'x = 2. Then "repeat 3 times: x = x * 2". What is x when done?',
      optionsId: <String>['16', '8', '12'],
      optionsEn: <String>['16', '8', '12'],
      correct: 0,
      explanationId: '2 -> 4 -> 8 -> 16. Dikali 2 tiga kali menghasilkan 16.',
      explanationEn: '2 -> 4 -> 8 -> 16. Multiplying by 2 three times gives 16.',
    ),
    QuizQuestion(
      questionId:
          'Aturan: "jika nilai > 70 maka Lulus, selain itu Ulang". Jika nilai = 70, hasilnya ...',
      questionEn:
          'Rule: "if score > 70 then Pass, else Retry". If score = 70, the result is ...',
      optionsId: <String>['Ulang', 'Lulus', 'Terjadi galat'],
      optionsEn: <String>['Retry', 'Pass', 'An error occurs'],
      correct: 0,
      explanationId:
          '70 > 70 salah (harus lebih dari 70). Karena itu jalur "selain itu" dijalankan: Ulang.',
      explanationEn:
          '70 > 70 is false (it must be greater than 70). So the "else" branch runs: Retry.',
    ),
  ];

  /// Soal untuk wilayah/level tertentu (di-clamp agar aman).
  static QuizQuestion question(int region, int level) {
    final int r = region.clamp(0, regionCount - 1);
    final int l = level.clamp(0, levelsPerRegion - 1);
    return questions[r * levelsPerRegion + l];
  }
}
