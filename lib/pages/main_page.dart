import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';
import 'learn_page.dart';
import 'map_page.dart';
import 'profile_page.dart';
import 'quest_page.dart';
import 'settings_page.dart';
import 'statistics_page.dart';

// ============================================================
// MAIN PAGE + BOTTOM NAVIGATION
// ============================================================

class MainPage extends StatefulWidget {
  /// Nama pengguna yang sedang masuk (hasil login).
  final String username;

  const MainPage({super.key, this.username = ''});

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

  Future<void> _logout() async {
    await Auth.logout();
    if (!mounted) return;
    AppRoutes.openLogin(context);
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

      SettingsPage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        onLogout: _logout,
      ),

      ProfilePage(
        isEnglish: isEnglish,
        onLanguageChanged: changeLanguage,
        username: widget.username,
      ),

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
