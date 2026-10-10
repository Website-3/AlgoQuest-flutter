import 'package:flutter/material.dart';

import '../widgets/app_header.dart';
import '../widgets/stat_card.dart';
import 'map_page.dart';

// ============================================================
// STATISTICS PAGE — DATA ASLI DARI PROGRES PEMAIN
// ============================================================
// Semua angka di halaman ini dihitung dari MapProgress (bintang
// yang benar-benar diraih pemain), bukan angka contoh.

class StatisticsPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const StatisticsPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  bool get _en => isEnglish;

  /// Nama wilayah tanpa awalan "Wilayah n - " agar muat di kartu.
  String _regionLabel(int region) {
    final String name = gameRegions[region].name(_en);
    final int idx = name.indexOf(' - ');
    return idx >= 0 ? name.substring(idx + 3) : name;
  }

  /// Gelar pemain berdasarkan total bintang.
  String _rank(int total) {
    if (total >= 70) return _en ? 'Logic Master' : 'Master Logika';
    if (total >= 40) return _en ? 'Logic Expert' : 'Ahli Logika';
    if (total >= 15) return _en ? 'Logic Adventurer' : 'Petualang Logika';
    if (total > 0) return _en ? 'Explorer' : 'Penjelajah';
    return _en ? 'Beginner' : 'Pemula';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Statistics',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
            ),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: MapProgress.revision,
                builder: (BuildContext context, int value, Widget? child) =>
                    _body(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body() {
    final int total = MapProgress.totalStars();
    final int maxTotal = MapProgress.maxTotalStars();
    final int completed = MapProgress.completedLevels();
    final int advTotal = MapProgress.modeStars(GameMode.adventure);
    final int logicTotal = MapProgress.modeStars(GameMode.logic);
    final int maxMode = MapProgress.totalLevels * MapProgress.maxStars;
    final int readyRegions = MapProgress.readyRegions();
    final int unlockedRegions = List<int>.generate(
      MapProgress.regionCount,
      (int r) => r,
    ).where(MapProgress.isRegionUnlocked).length;

    // Level & XP diturunkan dari bintang (6 bintang = 1 level).
    final int level = 1 + total ~/ 6;
    final int intoLevel = total % 6;
    final double levelProgress = intoLevel / 6;
    final int xp = total * 100;

    final int percent = maxTotal == 0 ? 0 : (total / maxTotal * 100).round();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KARTU LEVEL & XP
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B4E5C), Color(0xFF08A9C8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 36,
                    color: Color(0xFFFFC15C),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_en ? 'Level' : 'Level'} $level',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _rank(total),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: levelProgress,
                                minHeight: 8,
                                backgroundColor: const Color(0x66000000),
                                valueColor: const AlwaysStoppedAnimation(
                                  Color(0xFFFFC15C),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$xp XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _en
                            ? '$intoLevel/6 stars to next level'
                            : '$intoLevel/6 bintang menuju level berikutnya',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // GRID STATISTIK
          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.star_rounded,
                  iconColor: const Color(0xFFFFC15C),
                  value: '$total/$maxTotal',
                  label: _en ? 'Stars Earned' : 'Bintang Diperoleh',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  icon: Icons.check_circle,
                  iconColor: const Color(0xFF4DD7F7),
                  value: '$completed/${MapProgress.totalLevels}',
                  label: _en ? 'Levels Cleared' : 'Level Selesai',
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: StatCard(
                  icon: Icons.explore,
                  iconColor: const Color(0xFF59C36A),
                  value: '$advTotal/$maxMode',
                  label: _en ? 'Adventure' : 'Petualangan',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: StatCard(
                  icon: Icons.widgets,
                  iconColor: const Color(0xFFB07CFF),
                  value: '$logicTotal/$maxMode',
                  label: _en ? 'Logic Arena' : 'Arena Logika',
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // PROGRES WILAYAH
          Text(
            _en ? 'REGION PROGRESS' : 'PROGRES WILAYAH',
            style: const TextStyle(
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 14),

          for (int r = 0; r < MapProgress.regionCount; r++) ...[
            _ProgressRow(
              label: '${r + 1}. ${_regionLabel(r)}',
              value: MapProgress.regionStars(r) /
                  (MapProgress.levelsPerRegion * MapProgress.maxStars * 2),
              progressText:
                  '${MapProgress.regionStars(r)}/${MapProgress.levelsPerRegion * MapProgress.maxStars * 2}',
              color: gameRegions[r].color,
            ),
            if (r < MapProgress.regionCount - 1) const SizedBox(height: 12),
          ],

          const SizedBox(height: 28),

          // RINGKASAN KOLEKSI BINTANG
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF202524),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: const Color(0xFF064A50),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.military_tech,
                    color: Color(0xFF8DE7F5),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _en ? 'Star Collection' : 'Koleksi Bintang',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _en
                            ? '$total of $maxTotal stars collected'
                            : '$total daripada $maxTotal bintang terkumpul',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _en
                            ? '$unlockedRegions regions unlocked · $readyRegions completed'
                            : '$unlockedRegions wilayah terbuka · $readyRegions tuntas',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4DD7F7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final String progressText;
  final Color color;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progressText,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFF363B39),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 46,
          child: Text(
            progressText,
            textAlign: TextAlign.right,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
