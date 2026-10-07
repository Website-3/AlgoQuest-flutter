import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlgoQuest',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101414),
      ),
      home: const MainPage(),
    );
  }
}

// ============================================================
// MAIN PAGE + BOTTOM NAVIGATION
// ============================================================

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  bool isEnglish = false;

  void changeLanguage() {
    setState(() {
      isEnglish = !isEnglish;
    });
  }

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      QuestPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,

        // MULAI -> MAP
        onStartPressed: () {
          changePage(1);
        },

        // MATERI -> LEARN
        onMateriPressed: () {
          changePage(2);
        },
      ),

      MapPage(isEnglish: isEnglish, onLanguageChanged: changeLanguage),

      LearnPage(isEnglish: isEnglish, onLanguageChanged: changeLanguage),

      ProfilePage(isEnglish: isEnglish, onLanguageChanged: changeLanguage),
    ];

    return Scaffold(
      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF181D1C),
        selectedItemColor: const Color(0xFF48D8FF),
        unselectedItemColor: Colors.white70,
        selectedFontSize: 13,
        unselectedFontSize: 13,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.sports_esports_outlined),
            activeIcon: const Icon(Icons.sports_esports),
            label: isEnglish ? 'Quest' : 'Quest',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: isEnglish ? 'Map' : 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_outlined),
            activeIcon: const Icon(Icons.menu_book),
            label: isEnglish ? 'Learn' : 'Learn',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: isEnglish ? 'Profile' : 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class AppHeader extends StatelessWidget {
  final String title;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const AppHeader({
    super.key,
    required this.title,
    required this.isEnglish,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            // LOGO
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFB90016),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/logo_algoquest.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.auto_awesome, color: Colors.white);
                  },
                ),
              ),
            ),

            const SizedBox(width: 10),

            // TITLE
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDDE7E9),
                ),
              ),
            ),

            // LANGUAGE
            GestureDetector(
              onTap: onLanguageChanged,
              child: Container(
                height: 34,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: const Color(0xFF303635),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 31,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: !isEnglish
                            ? const Color(0xFF42CFFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ID',
                        style: TextStyle(
                          color: !isEnglish ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 31,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isEnglish
                            ? const Color(0xFF42CFFF)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'EN',
                        style: TextStyle(
                          color: isEnglish ? Colors.black : Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ENERGY
            Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white24),
              ),
              child: const Row(
                children: [
                  Text('⚡', style: TextStyle(fontSize: 17)),
                  SizedBox(width: 4),
                  Text(
                    '42',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// QUEST PAGE
// ============================================================

class QuestPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onStartPressed;
  final VoidCallback onMateriPressed;

  const QuestPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onStartPressed,
    required this.onMateriPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Quest',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
                child: Column(
                  children: [
                    const SizedBox(height: 15),

                    // LOGO BESAR
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Image.asset(
                        'assets/images/logo_algoquest.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.auto_awesome,
                            size: 70,
                            color: Colors.black,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'AlgoQuest',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      isEnglish ? 'LOGIC ADVENTURE' : 'PETUALANGAN LOGIKA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB21A),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // MULAI
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: onStartPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB21A),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.play_arrow),
                            const SizedBox(width: 5),
                            Text(
                              isEnglish ? 'Start' : 'Mulai',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // MATERI
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: onMateriPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF08A9C8),
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.menu_book),
                            const SizedBox(width: 5),
                            Text(
                              isEnglish ? 'Learn' : 'Materi',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // STATISTIK & PENGATURAN
                    Row(
                      children: [
                        Expanded(
                          child: _SmallButton(
                            icon: Icons.bar_chart,
                            text: isEnglish ? 'Statistics' : 'Statistik',
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _SmallButton(
                            icon: Icons.settings,
                            text: isEnglish ? 'Settings' : 'Pengaturan',
                          ),
                        ),
                      ],
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

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallButton({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

// ============================================================
// MAP PAGE
// ============================================================

class MapPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const MapPage({
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
              title: 'Map',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // CHAPTER
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF202524),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Peta Dunia',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Chapter 1: The Basics',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 15,
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
                            child: const Icon(
                              Icons.map,
                              color: Color(0xFF8DE7F5),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // MAP LEVELS
                    _MapLevel(
                      number: '🔥',
                      color: const Color(0xFFD90B1C),
                      stars: '☆ ★ ☆',
                      label: 'Lv 10',
                    ),

                    _MapLine(),

                    _MapLevel(
                      number: '9',
                      color: const Color(0xFF555B5A),
                      stars: '',
                      label: '',
                    ),

                    _MapLine(),

                    _MapLevel(
                      number: '8',
                      color: const Color(0xFF414746),
                      stars: '',
                      label: '',
                    ),

                    _MapLine(),

                    _MapLevel(
                      number: '🏆',
                      color: const Color(0xFF09B5D6),
                      stars: '☆ ☆ ☆',
                      label: 'Lv 7',
                    ),

                    _MapLine(),

                    _MapLevel(
                      number: '6',
                      color: const Color(0xFFC5E0E5),
                      textColor: Colors.black,
                      stars: '☆ ☆ ☆',
                      label: '',
                    ),

                    _MapLine(),

                    _MapLevel(
                      number: '5',
                      color: const Color(0xFFC5E0E5),
                      textColor: Colors.black,
                      stars: '☆ ☆ ★',
                      label: '',
                    ),

                    _MapLine(),

                    _MapLevel(
                      number: '4',
                      color: const Color(0xFFC5E0E5),
                      textColor: Colors.black,
                      stars: '☆ ☆ ☆',
                      label: '',
                    ),

                    const SizedBox(height: 40),
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

class _MapLevel extends StatelessWidget {
  final String number;
  final Color color;
  final Color textColor;
  final String stars;
  final String label;

  const _MapLevel({
    required this.number,
    required this.color,
    this.textColor = Colors.white,
    required this.stars,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 95,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (label.isNotEmpty)
            Positioned(
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C201F),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              if (stars.isNotEmpty)
                Text(
                  stars,
                  style: const TextStyle(
                    color: Color(0xFFFFC9A2),
                    fontSize: 17,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MapLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Center(
        child: Container(
          width: 7,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LEARN PAGE
// ============================================================

class LearnPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const LearnPage({
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
              title: 'Learn',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
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

                    // MOD 1
                    _StudyCard(
                      icon: Icons.check_circle_outline,
                      module: 'MOD 1',
                      title: isEnglish ? 'Sequential' : 'Sekuensial',
                      subtitle: 'Sequence',
                      progress: 1.0,
                      progressText: '100%',
                      active: false,
                    ),

                    const SizedBox(height: 18),

                    // MOD 2
                    _StudyCard(
                      icon: Icons.all_inclusive,
                      module: 'MOD 2',
                      title: isEnglish ? 'Loops' : 'Pengulangan',
                      subtitle: 'Loops',
                      progress: 0.5,
                      progressText: '50%',
                      active: true,
                    ),

                    const SizedBox(height: 18),

                    // MOD 3
                    _StudyCard(
                      icon: Icons.lock_outline,
                      module: 'MOD 3',
                      title: isEnglish
                          ? 'Conditionals & Actions'
                          : 'Percabangan & Aksi',
                      subtitle: 'Conditionals & Actions',
                      progress: 0.0,
                      progressText: '0%',
                      active: false,
                      locked: true,
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

  const _StudyCard({
    required this.icon,
    required this.module,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.progressText,
    required this.active,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: active ? const Color(0xFF164653) : const Color(0xFF363D3B),
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
    );
  }
}

// ============================================================
// PROFILE PAGE
// ============================================================

class ProfilePage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  const ProfilePage({
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
              title: 'Profile',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
            ),

            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFF303635),
                      child: Icon(
                        Icons.person,
                        size: 55,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      isEnglish ? 'AlgoQuest Player' : 'Pemain AlgoQuest',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      isEnglish ? 'Level 10' : 'Level 10',
                      style: const TextStyle(color: Colors.white70),
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
