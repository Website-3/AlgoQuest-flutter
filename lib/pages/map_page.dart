import 'package:flutter/material.dart';
import '../widgets/app_header.dart';

// ============================================================
// MAP PAGE
// ============================================================

class MapPage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback? onBack;

  const MapPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.onBack,
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
              onBack: onBack,
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

