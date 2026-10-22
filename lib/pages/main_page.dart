import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';
import 'learn_page.dart';
import 'game_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'quest_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

// ============================================================
// MAIN PAGE + BOTTOM NAVIGATION
// ============================================================

class MainPage extends StatefulWidget {
  final String username;

  const MainPage({
    super.key,
    this.username = '',
  });

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  bool isEnglish = false;

  int gameRegion = 0;
  int gameLevel = 0;

  // ==========================================================
  // GANTI BAHASA
  // ==========================================================

  void changeLanguage() {
    setState(() {
      isEnglish = !isEnglish;
    });
  }

  // ==========================================================
  // PINDAH HALAMAN
  // ==========================================================

  void changePage(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> _logout() async {
    await Auth.logout();

    if (!mounted) return;

    AppRoutes.openLogin(context);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // INDEX 0: QUEST
      QuestPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,

        // MULAI -> MAP
        onStartPressed: () {
          changePage(5);
        },

        // PANDUAN PERMAINAN
        onPanduanPressed: () {
          changePage(7);
        },

        // MATERI
        onMateriPressed: () {
          changePage(1);
        },

        // SETTINGS -> HALAMAN PENGATURAN (INDEX 4)
        onSettingsPressed: () {
          changePage(4);
        },
      ),

      // INDEX 1: MATERI
      LearnPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onBack: () => changePage(0),
      ),

      // INDEX 2: STATISTICS
      StatisticsPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
      ),

      // INDEX 3: PROFILE
      ProfilePage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        username: widget.username,
      ),

      // INDEX 4: SETTINGS (SUB PAGE)
      SettingsPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onLogout: _logout,
        onBack: () => changePage(0),
      ),

      // INDEX 5: MAP
      MapPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onBack: () => changePage(0),

        onStartLevel: (int region, int level) {
          setState(() {
            gameRegion = region;
            gameLevel = level;
            currentIndex = 6;
          });
        },
      ),

      // INDEX 6: GAME
      GamePage(
        region: gameRegion,
        level: gameLevel,
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onBack: () => changePage(5),
        onFinished: (int stars) => changePage(5),
      ),

      // INDEX 7: PANDUAN PERMAINAN
      GameGuidePage(
        isEnglish: isEnglish,
        onBack: () => changePage(0),
      ),
    ];

    // HALAMAN SUB TANPA NAVIGASI BAWAH
    final bool isSubPage =
        currentIndex == 4 ||
        currentIndex == 5 ||
        currentIndex == 6 ||
        currentIndex == 7;

    return Scaffold(
      body: pages[currentIndex],

      // NAVIGASI BAWAH
      bottomNavigationBar: isSubPage
          ? null
          : BottomNavigationBar(
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
                  label: 'Quest',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.menu_book_outlined),
                  activeIcon: const Icon(Icons.menu_book),
                  label: isEnglish ? 'Learn' : 'Materi',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.insights_outlined),
                  activeIcon: const Icon(Icons.insights),
                  label: 'Statistic',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.person_outline),
                  activeIcon: const Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
    );
  }
}

// ============================================================
// GAME GUIDE PAGE
// ============================================================

class GameGuidePage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onBack;

  const GameGuidePage({
    super.key,
    required this.isEnglish,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      appBar: AppBar(
        backgroundColor: const Color(0xFF181D1C),
        foregroundColor: Colors.white,
        title: Text(
          isEnglish ? 'Game Guide' : 'Panduan Permainan',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEnglish
                  ? 'How to Play AlgoQuest'
                  : 'Cara Bermain AlgoQuest',
              style: const TextStyle(
                color: Color(0xFFFFB21A),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            _guideItem(
              '1',
              isEnglish ? 'Start the Adventure' : 'Mulai Petualangan',
              isEnglish
                  ? 'Press Start on the Quest page to open the map.'
                  : 'Tekan tombol Mulai pada halaman Quest untuk membuka peta permainan.',
            ),

            _guideItem(
              '2',
              isEnglish ? 'Choose a Level' : 'Pilih Level',
              isEnglish
                  ? 'Select an available level on the map.'
                  : 'Pilih level yang tersedia pada peta untuk masuk ke permainan.',
            ),

            _guideItem(
              '3',
              isEnglish ? 'Complete the Challenge' : 'Selesaikan Tantangan',
              isEnglish
                  ? 'Follow the instructions and solve the logic challenges.'
                  : 'Ikuti instruksi dan selesaikan tantangan logika yang diberikan.',
            ),

            _guideItem(
              '4',
              isEnglish ? 'Learn the Materials' : 'Pelajari Materi',
              isEnglish
                  ? 'Open the Learn menu to study the materials.'
                  : 'Buka menu Materi untuk mempelajari materi sebelum bermain.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _guideItem(
    String number,
    String title,
    String description,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF181D1C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF08A9C8),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFB21A),
            foregroundColor: Colors.black,
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
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
