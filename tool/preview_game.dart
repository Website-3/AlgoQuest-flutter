// Entrypoint pratinjau: langsung membuka halaman permainan di dalam
// bingkai ukuran ponsel (supaya seluruh layar terlihat saat di-build web).
// Jalankan: flutter run -t tool/preview_game.dart
// Atau akses web dengan query: ?r=0&l=0  (region 0-4, level 0-2)
import 'package:flutter/material.dart';
import 'package:flutter_application_1/pages/adventure_page.dart';
import 'package:flutter_application_1/pages/game_page.dart';
import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_application_1/pages/statistics_page.dart';

void main() {
  runApp(const PreviewApp());
}

/// Pratinjau alur Peta -> pilih mode -> halaman permainan.
class MapPreview extends StatefulWidget {
  const MapPreview({super.key, this.openDialog = false});

  final bool openDialog;

  @override
  State<MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<MapPreview> {
  int? _region;
  int? _level;
  GameMode _mode = GameMode.logic;

  @override
  Widget build(BuildContext context) {
    if (_region == null) {
      return MapPage(
        isEnglish: false,
        onLanguageChanged: () {},
        debugOpenDialog: widget.openDialog,
        onStartLevel: (region, level, mode) {
          setState(() {
            _region = region;
            _level = level;
            _mode = mode;
          });
        },
      );
    }
    return _mode == GameMode.adventure
        ? AdventurePage(
            region: _region!,
            level: _level!,
            isEnglish: false,
            onLanguageChanged: () {},
            onBack: () => setState(() => _region = null),
            onFinished: (_) => setState(() => _region = null),
          )
        : GamePage(
            region: _region!,
            level: _level!,
            isEnglish: false,
            onLanguageChanged: () {},
            onBack: () => setState(() => _region = null),
            onFinished: (_) => setState(() => _region = null),
          );
  }
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
    final bool fight = uri.queryParameters['fight'] == '1';
    final bool dlg = uri.queryParameters['dlg'] == '1';

    // Pratinjau halaman Statistik: isi beberapa bintang contoh agar
    // terlihat hidup (hanya berlaku di tool pratinjau).
    if (mode == 'stats') {
      MapProgress.setStars(0, 0, GameMode.adventure, 3);
      MapProgress.setStars(0, 1, GameMode.logic, 2);
      MapProgress.setStars(1, 0, GameMode.adventure, 1);
      MapProgress.setStars(1, 0, GameMode.logic, 3);
      MapProgress.setStars(2, 0, GameMode.logic, 2);
    }

    final Widget page = mode == 'map'
        ? MapPreview(openDialog: dlg)
        : mode == 'stats'
        ? StatisticsPage(isEnglish: false, onLanguageChanged: () {})
        : mode == 'adventure'
        ? AdventurePage(
            region: region,
            level: level,
            isEnglish: false,
            onLanguageChanged: () {},
            onBack: () {},
            onFinished: (_) {},
            debugStartFight: fight,
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
