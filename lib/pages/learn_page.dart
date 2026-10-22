import 'package:flutter/material.dart';
import '../widgets/app_header.dart';

// ============================================================
// LEARN PAGE
// ============================================================

class LearnPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback? onBack;

  const LearnPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.onBack,
  });

  void _openDetail(
    BuildContext context, {
    required String module,
    required String title,
    required IconData icon,
    required String summary,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialDetailPage(
          module: module,
          title: title,
          icon: icon,
          summary: summary,
          isEnglish: isEnglish,
          onLanguageChanged: onLanguageChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Learn',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
              onBack: onBack,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CURRICULUM
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202524),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Curriculum',
                            style: TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isEnglish
                                ? 'Master the fundamentals of logic'
                                : 'Kuasai dasar-dasar logika',
                            style: const TextStyle(
                              fontSize: 19,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 22),

                          const Text(
                            'Overall Progress',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.33,
                                    minHeight: 9,
                                    backgroundColor: Color(0xFF363B39),
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFF4DD7F7),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '33%',
                                style: TextStyle(
                                  color: Color(0xFF4DD7F7),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    const Text(
                      'STUDY TOPICS',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // MOD 1: SEKUENSIAL
                    _StudyCard(
                      icon: Icons.check_circle_outline,
                      module: 'MOD 1',
                      title: isEnglish ? 'Sequential' : 'Sekuensial',
                      subtitle: 'Sequence',
                      progress: 1.0,
                      progressText: '100%',
                      active: false,
                      onTap: () {
                        _openDetail(
                          context,
                          module: 'MOD 1',
                          title: isEnglish
                              ? 'Sequential (Sequence)'
                              : 'Sekuensial (Sequence)',
                          icon: Icons.check_circle_outline,
                          summary: isEnglish
                              ? 'Sequential is a fundamental structure in programming logic that executes instructions sequentially from the first step to the last step. The order of instructions is crucial because each step must be performed according to the specified sequence for the program to achieve its goal correctly.'
                              : 'Sekuensial adalah struktur dasar logika pemrograman yang menjalankan instruksi secara berurutan dari langkah pertama hingga langkah terakhir. Urutan instruksi sangat penting karena setiap langkah harus dilakukan sesuai susunan yang telah ditentukan agar program dapat mencapai tujuan dengan benar.',
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // MOD 2: PENGULANGAN
                    _StudyCard(
                      icon: Icons.all_inclusive,
                      module: 'MOD 2',
                      title: isEnglish ? 'Loops' : 'Pengulangan',
                      subtitle: 'Loops',
                      progress: 0.5,
                      progressText: '50%',
                      active: true,
                      onTap: () {
                        _openDetail(
                          context,
                          module: 'MOD 2',
                          title: isEnglish
                              ? 'Loops (Loops)'
                              : 'Pengulangan (Loops)',
                          icon: Icons.all_inclusive,
                          summary: isEnglish
                              ? 'Loops are a programming logic structure used to execute the same instructions multiple times. Loops help make commands more concise and efficient because users do not need to write repetitive instructions.'
                              : 'Pengulangan adalah struktur logika pemrograman yang digunakan untuk menjalankan instruksi yang sama beberapa kali. Pengulangan membantu membuat perintah menjadi lebih ringkas dan efisien karena pengguna tidak perlu menuliskan instruksi yang sama secara berulang-ulang.',
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // MOD 3: PERCABANGAN
                    _StudyCard(
                      icon: Icons.call_split,
                      module: 'MOD 3',
                      title: isEnglish ? 'Conditionals' : 'Percabangan',
                      subtitle: 'Conditionals',
                      progress: 0.0,
                      progressText: '0%',
                      active: false,
                      locked: false,
                      onTap: () {
                        _openDetail(
                          context,
                          module: 'MOD 3',
                          title: isEnglish
                              ? 'Conditionals (Conditionals)'
                              : 'Percabangan (Conditionals)',
                          icon: Icons.call_split,
                          summary: isEnglish
                              ? 'Conditionals are a programming logic structure used to determine actions based on specific conditions. The program evaluates a condition first, then executes the corresponding instruction based on the result.'
                              : 'Percabangan adalah struktur logika pemrograman yang digunakan untuk menentukan tindakan berdasarkan kondisi tertentu. Program akan memeriksa suatu kondisi terlebih dahulu, kemudian menjalankan instruksi yang sesuai dengan hasil pemeriksaan tersebut.',
                        );
                      },
                    ),

                    const SizedBox(height: 25),

                    // DAILY CHALLENGE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF262116),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFF725E2E)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF5A4826),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.local_fire_department,
                              color: Color(0xFFFFC15C),
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Daily Challenge',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  isEnglish
                                      ? 'Earn 50 bonus XP'
                                      : 'Dapatkan 50 bonus XP',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, size: 30),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // NPC
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D2221),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/logo_npc.png',
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox(
                                width: 100,
                                height: 100,
                                child: Icon(Icons.person, size: 60),
                              );
                            },
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              isEnglish
                                  ? 'Learn logic and complete every challenge!'
                                  : 'Pelajari logika dan selesaikan setiap tantangan!',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
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

// ============================================================
// STUDY CARD
// ============================================================

class _StudyCard extends StatelessWidget {
  final IconData icon;
  final String module;
  final String title;
  final String subtitle;
  final double progress;
  final String progressText;
  final bool active;
  final bool locked;
  final VoidCallback? onTap;

  const _StudyCard({
    required this.icon,
    required this.module,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
    required this.active,
    this.locked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: const Color(0x1F35D5FF),
        highlightColor: const Color(0x0F35D5FF),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF202423),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: active ? const Color(0xFF35D5FF) : Colors.white12,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 70,
                decoration: BoxDecoration(
                  color: active
                      ? const Color(0xFF164653)
                      : const Color(0xFF363D3B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: active ? const Color(0xFF4DD7F7) : Colors.white70,
                ),
              ),

              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF30403F),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            module,
                            style: TextStyle(
                              color: active
                                  ? const Color(0xFF4DD7F7)
                                  : Colors.white70,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (active) ...[
                          const SizedBox(width: 8),
                          const Text(
                            '▷ IN PROGRESS',
                            style: TextStyle(
                              color: Color(0xFF4DD7F7),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: locked ? Colors.white38 : Colors.white,
                      ),
                    ),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: locked ? Colors.white30 : Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: const Color(0xFF363B39),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                active
                                    ? const Color(0xFF4DD7F7)
                                    : const Color(0xFFC5E0E5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          progressText,
                          style: TextStyle(
                            color: active
                                ? const Color(0xFF4DD7F7)
                                : Colors.white70,
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
      ),
    );
  }
}

// ============================================================
// MATERIAL DETAIL PAGE
// ============================================================

class MaterialDetailPage extends StatelessWidget {
  final String module;
  final String title;
  final IconData icon;
  final String summary;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const MaterialDetailPage({
    super.key,
    required this.module,
    required this.title,
    required this.icon,
    required this.summary,
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
              title: isEnglish ? 'Material' : 'Materi',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
              onBack: () => Navigator.of(context).pop(),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU HEADER MATERI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202423),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF35D5FF),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF164653),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              icon,
                              size: 34,
                              color: const Color(0xFF4DD7F7),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF30403F),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    module,
                                    style: const TextStyle(
                                      color: Color(0xFF4DD7F7),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // LABEL RANGKUMAN
                    Text(
                      isEnglish ? 'SUMMARY' : 'RANGKUMAN',
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // KARTU RANGKUMAN
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF181D1C),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF08A9C8),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        summary,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Color(0xFFDDE7E9),
                        ),
                        textAlign: TextAlign.justify,
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
