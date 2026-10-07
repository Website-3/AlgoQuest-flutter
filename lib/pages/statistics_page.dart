import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/stat_card.dart';

// ============================================================
// STATISTICS PAGE
// ============================================================

class StatisticsPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const StatisticsPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

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
              child: SingleChildScrollView(
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
                                const Text(
                                  'Level 10',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isEnglish
                                      ? 'Logic Adventurer'
                                      : 'Petualang Logika',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: const LinearProgressIndicator(
                                          value: 0.62,
                                          minHeight: 8,
                                          backgroundColor: Color(0x66000000),
                                          valueColor: AlwaysStoppedAnimation(
                                            Color(0xFFFFC15C),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      '1240 XP',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
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
                            icon: Icons.local_fire_department,
                            iconColor: const Color(0xFFFF7A1A),
                            value: '12',
                            label: isEnglish
                                ? 'Day Streak'
                                : 'Streak Hari',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: StatCard(
                            icon: Icons.star,
                            iconColor: const Color(0xFFFFC15C),
                            value: '18',
                            label: isEnglish
                                ? 'Stars Earned'
                                : 'Bintang Diperoleh',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.check_circle,
                            iconColor: const Color(0xFF4DD7F7),
                            value: '7/10',
                            label: isEnglish
                                ? 'Quest Completed'
                                : 'Quest Selesai',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: StatCard(
                            icon: Icons.bolt,
                            iconColor: const Color(0xFFB9F13E),
                            value: '42',
                            label: isEnglish ? 'Energy' : 'Energi',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // PROGRES MODUL
                    Text(
                      isEnglish ? 'MODULE PROGRESS' : 'PROGRES MODUL',
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 14),

                    _ProgressRow(
                      label:
                          'MOD 1 • ${isEnglish ? 'Sequential' : 'Sekuensial'}',
                      value: 1.0,
                      progressText: '100%',
                    ),

                    const SizedBox(height: 12),

                    _ProgressRow(
                      label: 'MOD 2 • ${isEnglish ? 'Loops' : 'Pengulangan'}',
                      value: 0.5,
                      progressText: '50%',
                    ),

                    const SizedBox(height: 12),

                    _ProgressRow(
                      label: isEnglish
                          ? 'MOD 3 • Conditionals & Actions'
                          : 'MOD 3 • Percabangan & Aksi',
                      value: 0.0,
                      progressText: '0%',
                    ),

                    const SizedBox(height: 28),

                    // AKURASI JAWABAN
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
                              Icons.track_changes,
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
                                  isEnglish
                                      ? 'Answer Accuracy'
                                      : 'Akurasi Jawaban',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isEnglish
                                      ? '171 of 199 answers correct'
                                      : '171 daripada 199 jawapan betul',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text(
                            '86%',
                            style: TextStyle(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final String label;
  final double value;
  final String progressText;

  const _ProgressRow({
    required this.label,
    required this.value,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 155,
          child: Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFF363B39),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF4DD7F7)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
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

