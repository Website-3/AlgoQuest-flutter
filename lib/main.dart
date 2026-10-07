import 'package:flutter/material.dart';
import 'pages/learn_page.dart';
import 'pages/map_page.dart';
import 'pages/profile_page.dart';
import 'pages/quest_page.dart';
import 'pages/settings_page.dart';
import 'pages/statistics_page.dart';

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

        // MULAI -> MAP (halaman sub, bukan tab)
        onStartPressed: () {
          changePage(4);
        },

        // MATERI -> LEARN (halaman sub, bukan tab)
        onMateriPressed: () {
          changePage(5);
        },
      ),

      StatisticsPage(isEnglish: isEnglish, onLanguageChanged: changeLanguage),

      SettingsPage(isEnglish: isEnglish, onLanguageChanged: changeLanguage),

      ProfilePage(isEnglish: isEnglish, onLanguageChanged: changeLanguage),

      // Halaman sub (dibuka dari Quest, tiada di bottom nav)
      MapPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onBack: () => changePage(0),
      ),

      LearnPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onBack: () => changePage(0),
      ),
    ];

    // Tab Map & Learn diganti dengan Statistics & Settings.
    // Map & Learn kini halaman sub -> bottom nav disembunyikan.
    final bool isSubPage = currentIndex >= 4;

    return Scaffold(
      body: pages[currentIndex],

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
                  icon: const Icon(Icons.insights_outlined),
                  activeIcon: const Icon(Icons.insights),
                  label: 'Statistics',
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings_outlined),
                  activeIcon: const Icon(Icons.settings),
                  label: 'Settings',
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

