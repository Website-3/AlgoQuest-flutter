// ============================================================
// CERITA WILAYAH — NARASI + PETUNJUK DARI NPC
// ============================================================
// Tiap wilayah punya cerita pendek dan satu petunjuk logika.
// Teks dwibahasa (Indonesia / Inggris). NPC pemandu bernama
// "Profesor Bit" memakai gambar assets/images/logo_npc.png.

class RegionStory {
  final String titleId;
  final String titleEn;

  /// Beberapa paragraf narasi.
  final List<String> paragraphsId;
  final List<String> paragraphsEn;

  /// Petunjuk singkat sebelum bertempur / menyusun blok.
  final String hintId;
  final String hintEn;

  const RegionStory({
    required this.titleId,
    required this.titleEn,
    required this.paragraphsId,
    required this.paragraphsEn,
    required this.hintId,
    required this.hintEn,
  });

  String title(bool en) => en ? titleEn : titleId;
  List<String> paragraphs(bool en) => en ? paragraphsEn : paragraphsId;
  String hint(bool en) => en ? hintEn : hintId;
}

class StoryCatalog {
  StoryCatalog._();

  static const String npcNameId = 'Profesor Bit';
  static const String npcNameEn = 'Professor Bit';

  static const List<RegionStory> stories = <RegionStory>[
    // ---- Wilayah 1: Hutan Algoritma ----
    RegionStory(
      titleId: 'Hutan Algoritma',
      titleEn: 'Algorithm Forest',
      paragraphsId: <String>[
        'Selamat datang, Petualang! Aku Profesor Bit, pemandumu di AlgoQuest.',
        'Hutan ini tumbuh dari urutan langkah. Setiap perintah dikerjakan berurutan dari atas ke bawah, seperti resep masakan: langkah pertama dulu, baru berikutnya.',
        'Monster di sini, si Goblin Algoritma, hanya bisa dikalahkan bila langkahmu rapi dan tidak terburu-buru.',
      ],
      paragraphsEn: <String>[
        'Welcome, adventurer! I am Professor Bit, your guide in AlgoQuest.',
        'This forest grows from the order of steps. Every command runs in order from top to bottom, like a cooking recipe: first step first, then the next.',
        'The monster here, the Algorithm Goblin, can only be defeated if your steps are neat and unhurried.',
      ],
      hintId:
          'Kunci Wilayah 1 adalah urutan. Maju dulu sampai dekat, baru belok, lalu serang. Satu perintah sama dengan satu langkah.',
      hintEn:
          'The key to Region 1 is order. Move forward until close, then turn, then attack. One command equals one step.',
    ),

    // ---- Wilayah 2: Lembah Variabel ----
    RegionStory(
      titleId: 'Lembah Variabel',
      titleEn: 'Variable Valley',
      paragraphsId: <String>[
        'Lembah ini penuh kotak penyimpanan bernama variabel.',
        'Variabel menyimpan sebuah nilai, dan operator mengubahnya. Ingat: x = x + 1 berarti ambil nilai lama x, tambah satu, lalu simpan kembali.',
        'Slime Variabel berubah bentuk setiap kali nilainya berubah. Amati posisimu dengan teliti.',
      ],
      paragraphsEn: <String>[
        'This valley is full of storage boxes called variables.',
        'A variable stores a value, and an operator changes it. Remember: x = x + 1 means take the old x, add one, then store it back.',
        'The Variable Slime changes shape every time its value changes. Watch your position carefully.',
      ],
      hintId:
          'Perhatikan posisi awal dan arah hadapmu. Belok mengubah arah, maju memindahkan posisi satu petak.',
      hintEn:
          'Pay attention to your starting position and facing. Turning changes direction, moving shifts your position by one tile.',
    ),

    // ---- Wilayah 3: Gerbang Percabangan ----
    RegionStory(
      titleId: 'Gerbang Percabangan',
      titleEn: 'Branching Gate',
      paragraphsId: <String>[
        'Gerbang ini memilih jalan: jika syarat terpenuhi, ambil satu jalan; jika tidak, ambil jalan yang lain.',
        'Percabangan membuat karaktermu bisa mengambil keputusan, alih-alih selalu lurus.',
        'Naga Percabangan menutup sebagian jalan. Pilih rute yang benar sebelum ia menyerang.',
      ],
      paragraphsEn: <String>[
        'This gate chooses a path: if the condition holds, take one path; if not, take the other.',
        'Branching lets your character make decisions, instead of always going straight.',
        'The Branch Dragon blocks part of the path. Pick the right route before it strikes.',
      ],
      hintId:
          'Periksa dinding di sekitarmu. Kadang memutar dulu lebih cepat daripada memaksa lurus ke dinding.',
      hintEn:
          'Check the walls around you. Sometimes turning first is faster than pushing straight into a wall.',
    ),

    // ---- Wilayah 4: Labirin Perulangan ----
    RegionStory(
      titleId: 'Labirin Perulangan',
      titleEn: 'Loop Maze',
      paragraphsId: <String>[
        'Labirin ini berputar seperti perulangan: satu pola diulang berkali-kali.',
        'Kalau kamu menemukan pola langkah yang tepat, cukup ulangi pola itu sampai tujuan.',
        'Iblis Perulangan kuat dan sabar. Jangan buang langkah; hemat perintahmu.',
      ],
      paragraphsEn: <String>[
        'This maze spins like a loop: one pattern repeats over and over.',
        'If you find the right movement pattern, just repeat it until you arrive.',
        'The Loop Demon is strong and patient. Do not waste steps; save your commands.',
      ],
      hintId:
          'Cari pola langkah yang berulang, lalu ulangi pola itu sampai dekat monster.',
      hintEn:
          'Find the repeating movement pattern, then repeat it until you are close to the monster.',
    ),

    // ---- Wilayah 5: Benteng Logika ----
    RegionStory(
      titleId: 'Benteng Logika',
      titleEn: 'Logic Fortress',
      paragraphsId: <String>[
        'Inilah benteng terakhir, tempat semua teknik digabung: urutan, variabel, percabangan, dan perulangan.',
        'Musuh terkuat, Behemoth Logika, menjaga gerbang kemenangan.',
        'Rencanakan seluruh langkahmu sebelum menekan tombol jalan. Tidak ada langkah yang boleh terbuang.',
      ],
      paragraphsEn: <String>[
        'This is the final fortress, where all techniques combine: sequence, variables, branching, and loops.',
        'The strongest foe, the Logic Behemoth, guards the gate of victory.',
        'Plan all your steps before pressing run. No step may be wasted.',
      ],
      hintId:
          'Gabungkan urutan, percabangan, dan perulangan. Susun semua blok dulu, baru jalankan.',
      hintEn:
          'Combine sequence, branching, and loops. Arrange all blocks first, then run.',
    ),
  ];

  /// Cerita untuk wilayah tertentu (region di-clamp agar aman).
  static RegionStory story(int region) =>
      stories[region.clamp(0, stories.length - 1)];
}
