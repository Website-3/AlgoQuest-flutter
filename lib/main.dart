import 'package:flutter/material.dart';

import 'pages/map_page.dart';
import 'pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Muat progres bintang yang tersimpan sebelum UI tampil.
  await MapProgress.load();
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AlgoQuest',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0B0F0F),
      ),
      home: const SplashPage(),
    );
  }
}
