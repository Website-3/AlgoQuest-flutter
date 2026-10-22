import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_header.dart';
import '../widgets/npc_dialog.dart';

// ============================================================
// MAP PAGE â€” PETA DUNIA
// ============================================================
// 5 wilayah x 3 level = 15 level. Tiap level dimainkan dalam
// mode Arena Logika (susun blok perintah untuk mengalahkan
// monster).
//
// ATURAN PROGRES:
//   1. Wilayah 1 terbuka dari awal.
//   2. Di dalam 1 wilayah, level berikutnya terbuka begitu level
//      sebelumnya selesai (bintang 1 pun cukup untuk membuka).
//   3. Untuk PINDAH ke wilayah berikutnya, SEMUA level di wilayah
//      ini harus minimal 2 bintang.
//   4. Progres disimpan ke perangkat (shared_preferences) & dimuat
//      kembali saat aplikasi dibuka.

// ============================================================
// DATA WILAYAH
// ============================================================
class GameRegion {
  final String nameId;
  final String nameEn;
  final String materialId;
  final String materialEn;
  final Color color;
  final IconData icon;

  const GameRegion({
    required this.nameId,
    required this.nameEn,
    required this.materialId,
    required this.materialEn,
    required this.color,
    required this.icon,
  });

  String name(bool isEnglish) => isEnglish ? nameEn : nameId;

  String material(bool isEnglish) => isEnglish ? materialEn : materialId;
}

const List<GameRegion> gameRegions = <GameRegion>[
  GameRegion(
    nameId: 'Wilayah 1 - Hutan Algoritma',
    nameEn: 'Region 1 - Algorithm Forest',
    materialId: 'Materi algoritma dan urutan instruksi.',
    materialEn: 'Materials: algorithms and instruction sequence.',
    color: Color(0xFF59C36A),
    icon: Icons.forest,
  ),
  GameRegion(
    nameId: 'Wilayah 2 - Lembah Variabel',
    nameEn: 'Region 2 - Variable Valley',
    materialId: 'Materi variabel dan operator.',
    materialEn: 'Materials: variables and operators.',
    color: Color(0xFF42CFFF),
    icon: Icons.data_object,
  ),
  GameRegion(
    nameId: 'Wilayah 3 - Gerbang Percabangan',
    nameEn: 'Region 3 - Branching Gate',
    materialId: 'Materi kondisi dan percabangan.',
    materialEn: 'Materials: conditions and branching.',
    color: Color(0xFFFFB21A),
    icon: Icons.alt_route,
  ),
  GameRegion(
    nameId: 'Wilayah 4 - Labirin Perulangan',
    nameEn: 'Region 4 - Loop Maze',
    materialId: 'Materi perulangan.',
    materialEn: 'Materials: loops.',
    color: Color(0xFFB07CFF),
    icon: Icons.all_inclusive,
  ),
  GameRegion(
    nameId: 'Wilayah 5 - Benteng Logika',
    nameEn: 'Region 5 - Logic Fortress',
    materialId: 'Tantangan gabungan.',
    materialEn: 'Combined challenges.',
    color: Color(0xFFFF6B4A),
    icon: Icons.shield,
  ),
];

// ============================================================
// PROGRES (DISIMPAN KE PERANGKAT)
// ============================================================
class MapProgress {
  MapProgress._();

  static const int regionCount = 5;
  static const int levelsPerRegion = 3;
  static const int totalLevels = regionCount * levelsPerRegion; // 15
  static const int maxStars = 3;
  static const int requiredStars = 2; // syarat pindah wilayah

  /// Kunci penyimpanan di shared_preferences.
  static const String _prefsKey = 'map_progress_v1';

  /// Sinyal agar UI (mis. halaman Statistik) ikut menyegarkan saat
  /// progres berubah.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  /// Bintang tiap level.
  /// Index = wilayah * 3 + level. 0 = belum selesai.
  static final List<int> stars = List<int>.filled(totalLevels, 0);

  /// Wilayah yang cerita pembukanya sudah pernah ditampilkan.
  static final List<bool> storySeen = List<bool>.filled(regionCount, false);

  /// Level yang soalnya sudah dijawab dengan benar.
  static final List<bool> quizCorrect = List<bool>.filled(totalLevels, false);

  static int indexOf(int region, int level) => region * levelsPerRegion + level;

  // ---------- Penyimpanan ----------

  /// Muat progres dari perangkat. Aman dipanggil walau gagal
  /// (mis. saat pengujian tanpa plugin).
  static Future<void> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? raw = prefs.getString(_prefsKey);
      if (raw == null) return;
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return;

      if (decoded['stars'] is List) {
        _readInto(stars, decoded['stars']);
      } else {
        // Migrasi dari versi lama (2 mode): ambil bintang terbaik
        // supaya progres pemain tidak hilang.
        final List<int> adventure = List<int>.filled(totalLevels, 0);
        final List<int> logic = List<int>.filled(totalLevels, 0);
        _readInto(adventure, decoded['adventure']);
        _readInto(logic, decoded['logic']);
        for (var i = 0; i < totalLevels; i++) {
          stars[i] = adventure[i] > logic[i] ? adventure[i] : logic[i];
        }
      }

      _readBoolInto(storySeen, decoded['story']);
      _readBoolInto(quizCorrect, decoded['quiz']);
      revision.value++;
    } catch (_) {
      // Abaikan: progres tetap berjalan di memori.
    }
  }

  static void _readInto(List<int> target, Object? source) {
    if (source is! List) return;
    for (var i = 0; i < target.length && i < source.length; i++) {
      final Object? value = source[i];
      if (value is int) target[i] = value.clamp(0, maxStars);
    }
  }

  static void _readBoolInto(List<bool> target, Object? source) {
    if (source is! List) return;
    for (var i = 0; i < target.length && i < source.length; i++) {
      final Object? value = source[i];
      if (value is bool) target[i] = value;
    }
  }

  /// Simpan progres. Aman dipanggil walau gagal.
  static Future<void> save() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _prefsKey,
        jsonEncode(<String, Object>{
          'stars': stars,
          'story': storySeen,
          'quiz': quizCorrect,
        }),
      );
    } catch (_) {
      // Abaikan.
    }
  }

  /// Hapus seluruh progres dari memori (tidak menghapus penyimpanan).
  static void reset() {
    stars.fillRange(0, stars.length, 0);
    storySeen.fillRange(0, storySeen.length, false);
    quizCorrect.fillRange(0, quizCorrect.length, false);
    revision.value++;
  }

  // ---------- Cerita wilayah ----------

  static bool isStorySeen(int region) => storySeen[region.clamp(0, regionCount - 1)];

  static void markStorySeen(int region) {
    storySeen[region.clamp(0, regionCount - 1)] = true;
    revision.value++;
    unawaited(save());
  }

  // ---------- Soal logika ----------

  static bool isQuizCorrect(int region, int level) =>
      quizCorrect[indexOf(region, level)];

  /// Tandai soal level ini sudah dijawab benar (sekali saja).
  static void markQuizCorrect(int region, int level) {
    final int i = indexOf(region, level);
    if (quizCorrect[i]) return;
    quizCorrect[i] = true;
    revision.value++;
    unawaited(save());
  }

  /// Jumlah level yang soalnya sudah dijawab benar.
  static int quizCorrectCount() {
    var count = 0;
    for (final bool b in quizCorrect) {
      if (b) count++;
    }
    return count;
  }

  // ---------- Baca/tulis bintang ----------

  /// Bintang level ini (0..3).
  static int starsOf(int region, int level) => stars[indexOf(region, level)];

  static void setStars(int region, int level, int value) {
    stars[indexOf(region, level)] = value.clamp(0, maxStars);
    revision.value++;
    unawaited(save());
  }

  /// Semua level di wilayah ini sudah >= 2 bintang?
  static bool isRegionReady(int region) {
    for (var level = 0; level < levelsPerRegion; level++) {
      if (starsOf(region, level) < requiredStars) return false;
    }
    return true;
  }

  /// Wilayah terbuka? (Wilayah 1 selalu terbuka)
  static bool isRegionUnlocked(int region) {
    if (region <= 0) return true;
    return isRegionReady(region - 1);
  }

  /// Level terbuka? (Level 1 terbuka jika wilayahnya terbuka)
  static bool isLevelUnlocked(int region, int level) {
    if (!isRegionUnlocked(region)) return false;
    if (level == 0) return true;
    return starsOf(region, level - 1) >= 1;
  }

  /// Total bintang dalam 1 wilayah (maks 9).
  static int regionStars(int region) {
    var total = 0;
    for (var level = 0; level < levelsPerRegion; level++) {
      total += starsOf(region, level);
    }
    return total;
  }

  static int completedLevels() {
    var count = 0;
    for (var i = 0; i < totalLevels; i++) {
      if (stars[i] > 0) count++;
    }
    return count;
  }

  static int totalStars() {
    var total = 0;
    for (final int s in stars) {
      total += s;
    }
    return total;
  }

  /// Bintang maksimum seluruh peta (15 level x 3 bintang = 45).
  static int maxTotalStars() => totalLevels * maxStars;

  /// Jumlah wilayah yang sudah siap pindah (semua level >= 2 bintang).
  static int readyRegions() {
    var count = 0;
    for (var r = 0; r < regionCount; r++) {
      if (isRegionReady(r)) count++;
    }
    return count;
  }
}

// ============================================================
// HALAMAN PETA
// ============================================================
class MapPage extends StatefulWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback? onBack;

  /// Bila diisi, mengetuk level langsung memulai Arena Logika lewat
  /// callback ini. Bila null, level mensimulasikan kemenangan
  /// (3 bintang) â€” berguna untuk pratinjau.
  final void Function(int region, int level)? onStartLevel;

  const MapPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.onBack,
    this.onStartLevel,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool get _en => widget.isEnglish;

  // ----------------------------------------------------------
  // Ketuk level yang terbuka -> mulai Arena Logika
  // ----------------------------------------------------------
  Future<void> _openLevel(int region, int level) async {
    final bool wasReady = MapProgress.isRegionReady(region);

    // Pertama kali memasuki wilayah ini -> perkenalan dari NPC.
    if (!MapProgress.isStorySeen(region)) {
      await showNpcStory(context, region: region, isEnglish: _en);
      if (!mounted) return;
      MapProgress.markStorySeen(region);
    }

    if (!mounted) return;

    // Host sebenarnya -> buka halaman permainan.
    if (widget.onStartLevel != null) {
      widget.onStartLevel!(region, level);
      return;
    }

    // Tanpa host (mode demo) -> simulasikan kemenangan 3 bintang.
    MapProgress.setStars(region, level, 3);
    setState(() {});
    _announceRegion(region, wasReady);
  }

  /// Kabari bila wilayah berikutnya baru terbuka.
  void _announceRegion(int region, bool wasReady) {
    final bool nowReady = MapProgress.isRegionReady(region);
    if (wasReady || !nowReady) return;
    final String msg = region < gameRegions.length - 1
        ? (_en
              ? 'Region ${region + 2} unlocked!'
              : 'Wilayah ${region + 2} terbuka!')
        : (_en
              ? 'All regions cleared - you finished AlgoQuest!'
              : 'Semua wilayah selesai - kamu menuntaskan AlgoQuest!');
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(backgroundColor: const Color(0xFF164653), content: Text(msg)),
      );
  }


  /// Level terkunci disentuh -> beri tahu syaratnya.
  void _showLocked(int region, int level) {
    final String msg;
    if (!MapProgress.isRegionUnlocked(region)) {
      final String prev = gameRegions[region - 1].name(_en);
      msg = _en
          ? 'Locked. Earn at least 2 stars on every level of $prev.'
          : 'Terkunci. Dapatkan minimal 2 bintang di semua level $prev.';
    } else {
      msg = _en
          ? 'Locked. Finish Level $level first.'
          : 'Terkunci. Selesaikan Level $level dulu.';
    }

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(backgroundColor: const Color(0xFF2A2320), content: Text(msg)),
      );
  }

  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Map',
              isEnglish: _en,
              onLanguageChanged: widget.onLanguageChanged,
              onBack: widget.onBack,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    _overviewCard(),
                    const SizedBox(height: 18),

                    for (
                      var region = 0;
                      region < gameRegions.length;
                      region++
                    ) ...[
                      _regionCard(region),
                      if (region < gameRegions.length - 1)
                        _gate(
                          unlocked: MapProgress.isRegionUnlocked(region + 1),
                          color: gameRegions[region + 1].color,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // KARTU RINGKASAN
  // ----------------------------------------------------------
  Widget _overviewCard() {
    final int done = MapProgress.completedLevels();
    final int stars = MapProgress.totalStars();
    final int maxTotal = MapProgress.totalLevels * MapProgress.maxStars;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF202524),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _en ? 'World Map' : 'Peta Dunia',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _en ? '5 Regions - 15 Levels' : '5 Wilayah - 15 Level',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFF064A50),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.map, color: Color(0xFF8DE7F5)),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                _en ? 'Levels' : 'Level selesai',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$done / ${MapProgress.totalLevels}',
                style: const TextStyle(
                  color: Color(0xFF42CFFF),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: done / MapProgress.totalLevels,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A302F),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF42CFFF)),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC15C),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                _en ? 'Total stars' : 'Total bintang',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const Spacer(),
              Text(
                '$stars / $maxTotal',
                style: const TextStyle(
                  color: Color(0xFFFFC15C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // KARTU WILAYAH
  // ----------------------------------------------------------
  Widget _regionCard(int region) {
    final GameRegion r = gameRegions[region];
    final bool unlocked = MapProgress.isRegionUnlocked(region);
    final bool ready = unlocked && MapProgress.isRegionReady(region);
    final int stars = MapProgress.regionStars(region);
    final int maxStars = MapProgress.levelsPerRegion * MapProgress.maxStars;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: const Color(0xFF202524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: unlocked ? r.color.withValues(alpha: 0.55) : Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- HEADER WILAYAH ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: unlocked
                      ? r.color.withValues(alpha: 0.18)
                      : const Color(0xFF2A302F),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  unlocked ? r.icon : Icons.lock_outline,
                  color: unlocked ? r.color : Colors.white38,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name(_en),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: unlocked ? Colors.white : Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.material(_en),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),

              // Buka ulang cerita wilayah kapan saja.
              if (unlocked)
                IconButton(
                  tooltip: _en ? 'Story' : 'Cerita',
                  onPressed: () =>
                      showNpcStory(context, region: region, isEnglish: _en),
                  icon: const Icon(Icons.menu_book_rounded),
                  color: r.color,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ---- STATUS + BINTANG ----
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC15C),
                size: 15,
              ),
              const SizedBox(width: 5),
              Text(
                '$stars / $maxStars',
                style: const TextStyle(
                  color: Color(0xFFFFC15C),
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),

              const Spacer(),

              _statusChip(
                unlocked: unlocked,
                ready: ready,
                isLast: region == gameRegions.length - 1,
              ),
            ],
          ),

          // ---- PESAN SYARAT ----
          if (!unlocked) ...[
            const SizedBox(height: 12),
            _noteBox(
              icon: Icons.lock_outline,
              color: Colors.white54,
              text: _en
                  ? 'Locked. Earn at least 2 stars on every level of '
                        '${gameRegions[region - 1].name(_en)}.'
                  : 'Terkunci. Dapatkan minimal 2 bintang di semua level '
                        '${gameRegions[region - 1].name(_en)}.',
            ),
          ] else if (ready && region == gameRegions.length - 1) ...[
            const SizedBox(height: 12),
            _noteBox(
              icon: Icons.emoji_events_outlined,
              color: const Color(0xFFFFC15C),
              text: _en
                  ? 'All 5 regions cleared - you conquered AlgoQuest!'
                  : 'Semua 5 wilayah selesai - kamu menaklukkan AlgoQuest!',
            ),
          ] else if (ready && region < gameRegions.length - 1) ...[
            const SizedBox(height: 12),
            _noteBox(
              icon: Icons.check_circle_outline,
              color: const Color(0xFF59C36A),
              text: _en
                  ? 'All levels have 2+ stars - the next region is open!'
                  : 'Semua level sudah 2 bintang - wilayah berikutnya terbuka!',
            ),
          ],

          const SizedBox(height: 18),

          // ---- JALUR 3 LEVEL ----
          for (var level = 0; level < MapProgress.levelsPerRegion; level++) ...[
            _levelNode(region, level),
            if (level < MapProgress.levelsPerRegion - 1)
              _pathLine(
                color: r.color,
                active: MapProgress.isLevelUnlocked(region, level + 1),
              ),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // TOMBOL STATUS
  // ----------------------------------------------------------
  Widget _statusChip({
    required bool unlocked,
    required bool ready,
    bool isLast = false,
  }) {
    final Color color;
    final String label;
    final IconData icon;

    if (!unlocked) {
      color = Colors.white54;
      label = _en ? 'LOCKED' : 'TERKUNCI';
      icon = Icons.lock_outline;
    } else if (ready) {
      color = const Color(0xFF59C36A);
      if (isLast) {
        label = _en ? 'CLEARED' : 'SELESAI';
        icon = Icons.emoji_events_outlined;
      } else {
        label = _en ? 'NEXT OPEN' : 'SIAP PINDAH';
        icon = Icons.lock_open;
      }
    } else {
      color = const Color(0xFFFFC15C);
      label = _en ? '2 STARS NEEDED' : 'BUTUH 2 BINTANG';
      icon = Icons.star_border;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // SIMPUL LEVEL (LINGKARAN)
  // ----------------------------------------------------------
  Widget _levelNode(int region, int level) {
    final GameRegion r = gameRegions[region];
    final bool unlocked = MapProgress.isLevelUnlocked(region, level);
    final int stars = MapProgress.starsOf(region, level);

    final Color fill;
    final Color border;
    final Widget child;

    if (!unlocked) {
      fill = const Color(0xFF171C1B);
      border = Colors.white10;
      child = const Icon(Icons.lock_outline, color: Colors.white30, size: 26);
    } else if (stars > 0) {
      fill = r.color;
      border = r.color;
      child = Text(
        '${level + 1}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: r.color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
        ),
      );
    } else {
      fill = const Color(0xFF171C1B);
      border = r.color;
      child = Text(
        '${level + 1}',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: r.color,
        ),
      );
    }

    return InkWell(
      onTap: unlocked
          ? () => _openLevel(region, level)
          : () => _showLocked(region, level),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: unlocked ? 2 : 1),
                boxShadow: stars >= 2
                    ? [
                        BoxShadow(
                          color: r.color.withValues(alpha: 0.35),
                          blurRadius: 16,
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: child,
            ),

            const SizedBox(height: 7),

            Text(
              'Level ${level + 1}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: unlocked ? Colors.white70 : Colors.white30,
              ),
            ),

            const SizedBox(height: 4),

            if (unlocked)
              _starRow(stars, size: 13)
            else
              Text(
                _en ? 'Locked' : 'Terkunci',
                style: const TextStyle(fontSize: 10.5, color: Colors.white30),
              ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // GARIS PENGIKAT LEVEL
  // ----------------------------------------------------------
  Widget _pathLine({required Color color, required bool active}) {
    return SizedBox(
      height: 30,
      child: Center(
        child: Container(
          width: 6,
          height: 30,
          decoration: BoxDecoration(
            color: active ? color.withValues(alpha: 0.55) : Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // GERBANG ANTAR WILAYAH
  // ----------------------------------------------------------
  Widget _gate({required bool unlocked, required Color color}) {
    final Color c = unlocked ? color : Colors.white30;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          Container(
            width: 6,
            height: 26,
            decoration: BoxDecoration(
              color: unlocked ? color.withValues(alpha: 0.5) : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1C201F),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: c.withValues(alpha: 0.6)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  unlocked ? Icons.lock_open : Icons.lock,
                  size: 13,
                  color: c,
                ),
                const SizedBox(width: 6),
                Text(
                  unlocked
                      ? (_en ? 'GATE OPEN' : 'GERBANG TERBUKA')
                      : (_en ? 'GATE LOCKED' : 'GERBANG TERKUNCI'),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: c,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // BINTANG
  // ----------------------------------------------------------
  Widget _starRow(int value, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1.5),
          child: Icon(
            i < value ? Icons.star_rounded : Icons.star_border_rounded,
            size: size,
            color: i < value ? const Color(0xFFFFC15C) : Colors.white24,
          ),
        );
      }),
    );
  }

  /// Dua baris mini bintang di bawah tiap level sudah digantikan satu
  /// baris [_starRow] karena kini hanya ada satu mode.

  // ----------------------------------------------------------
  // KOTAK INFO
  // ----------------------------------------------------------
  Widget _noteBox({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: color, fontSize: 11.5, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
