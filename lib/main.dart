import 'package:flutter/material.dart';

import 'pages/map_page.dart';
import 'pages/splash_page.dart';
import 'services/app_settings.dart';
import 'services/audio_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Suara aktif secara bawaan (bisa dimatikan di Pengaturan).
  GameAudio.instance.enabled = true;
  // Muat progres bintang & preferensi yang tersimpan sebelum UI tampil.
  await MapProgress.load();
  await AppSettings.load();
  GameAudio.instance.warmUp();
  runApp(const MyApp());
}

// ============================================================
// APP
// ============================================================
// Alur pembuka aplikasi:
//   SplashPage (loading + tips)
//        -> AuthGate (cek sesi login)
//             -> LoginPage (belum masuk)
//             -> MainPage  (sudah masuk)

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    GameAudio.instance.stopBgm();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      GameAudio.instance.pauseBgm();
    } else if (state == AppLifecycleState.resumed) {
      GameAudio.instance.resumeBgm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData base = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlgoQuest',
      theme: base.copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F0F),
        // Terapkan font kustom (Poppins) ke seluruh teks.
        textTheme: base.textTheme.apply(fontFamily: 'Poppins'),
        primaryTextTheme: base.primaryTextTheme.apply(fontFamily: 'Poppins'),
      ),
      home: const SplashPage(),
    );
  }
}
