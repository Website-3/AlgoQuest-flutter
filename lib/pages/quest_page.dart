import 'package:flutter/material.dart';
import '../widgets/app_header.dart';

// ============================================================
// QUEST PAGE
// ============================================================

class QuestPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onStartPressed;
  final VoidCallback? onPanduanPressed;
  final VoidCallback? onMateriPressed;

  // SETTINGS
  final VoidCallback onSettingsPressed;

  const QuestPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onStartPressed,
    this.onPanduanPressed,
    this.onMateriPressed,
    required this.onSettingsPressed,
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

              // SETTINGS -> HALAMAN PENGATURAN
              onSettingsPressed: onSettingsPressed,
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

                    // NAMA GAME
                    const Text(
                      'AlgoQuest',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // SUBTITLE
                    Text(
                      isEnglish ? 'LOGIC ADVENTURE' : 'PETUALANGAN LOGIKA',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFB21A),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ==================================================
                    // TOMBOL MULAI
                    // ==================================================
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

                    // ==================================================
                    // TOMBOL PANDUAN PERMAINAN (KOTAK BIRU)
                    // ==================================================
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: onPanduanPressed,
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
                            const SizedBox(width: 8),
                            Text(
                              isEnglish
                                  ? 'Game Guide'
                                  : 'Panduan Permainan',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
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
