import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'services/auth_service.dart';

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
      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE — cek sesi login saat aplikasi dibuka
// ============================================================
// Sudah pernah masuk  -> langsung ke MainPage
// Belum / sudah keluar -> tampilkan LoginPage

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late final Future<String?> _session;

  @override
  void initState() {
    super.initState();
    _session = Auth.currentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _session,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const _SplashScreen();
        }

        final String? username = snapshot.data;
        if (username == null || username.isEmpty) {
          return const LoginPage();
        }

        return MainPage(username: username);
      },
    );
  }
}

// ============================================================
// LAYAR PEMBUKA (saat mengecek sesi)
// ============================================================

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
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
                    size: 60,
                    color: Colors.black,
                  );
                },
              ),
            ),
            const SizedBox(height: 26),
            const CircularProgressIndicator(
              color: Color(0xFF48D8FF),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
