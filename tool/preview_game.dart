// Entrypoint pratinjau: langsung membuka halaman permainan di dalam
// bingkai ukuran ponsel (supaya seluruh layar terlihat saat di-build web).
// Jalankan: flutter run -t tool/preview_game.dart
// Atau akses web dengan query: ?r=0&l=0  (region 0-4, level 0-2)
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/adventure_page.dart';
import 'package:flutter_application_1/pages/game_page.dart';

void main() {
  runApp(const PreviewApp());
}

class PreviewApp extends StatelessWidget {
  const PreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Uri uri = Uri.base;
    final int region =
        int.tryParse(uri.queryParameters['r'] ?? '')?.clamp(0, 4) ?? 0;
    final int level =
        int.tryParse(uri.queryParameters['l'] ?? '')?.clamp(0, 2) ?? 0;
    final double? fx = double.tryParse(uri.queryParameters['fx'] ?? '');
    final String mode = uri.queryParameters['mode'] ?? 'logic';

    final Widget page = mode == 'adventure'
        ? AdventurePage(
            region: region,
            level: level,
            isEnglish: false,
            onLanguageChanged: () {},
            onBack: () {},
            onFinished: (_) {},
          )
        : GamePage(
            region: region,
            level: level,
            isEnglish: false,
            onLanguageChanged: () {},
            onBack: () {},
            onFinished: (_) {},
            debugAttack: fx,
          );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F0F),
      ),
      home: ColoredBox(
        color: const Color(0xFF050808),
        child: Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: 390,
              height: 844,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: page,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
