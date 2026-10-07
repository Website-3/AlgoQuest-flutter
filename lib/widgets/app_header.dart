import 'package:flutter/material.dart';

// ============================================================
// HEADER
// ============================================================

class AppHeader extends StatelessWidget {
  final String title;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  /// Diberi nilainya hanya pada halaman sub (Map & Learn)
  /// supaya papaan belakang dipaparkan menggantikan logo.
  final VoidCallback? onBack;

  const AppHeader({
    super.key,
    required this.title,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            // BACK (halaman sub) / LOGO
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 42,
                  minHeight: 42,
                ),
              )
            else
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
                      return const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      );
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

