import 'package:flutter/material.dart';

import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'services/auth_service.dart';

// ============================================================
// AUTH GATE — cek sesi login setelah splash
// ============================================================
// Sudah pernah masuk (dan centang "Ingat Saya") -> langsung MainPage
// Belum / belum centang / sudah keluar           -> tampilkan LoginPage

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
        // Masih mengecek sesi -> tampilan ringan
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B0F0F),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF48D8FF)),
            ),
          );
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
