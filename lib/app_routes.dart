import 'package:flutter/material.dart';

import 'auth_gate.dart';
import 'pages/login_page.dart';
import 'pages/main_page.dart';
import 'pages/register_page.dart';

// ============================================================
// PINDAH HALAMAN ANTAR-BAGIAN APLIKASI
// ============================================================
// Semua halaman masuk memakai helper ini supaya kodenya
// tidak duplikat dan konsisten.

class AppRoutes {
  AppRoutes._();

  /// Dari splash -> cek sesi login (AuthGate).
  static void openGate(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AuthGate()),
      (route) => false,
    );
  }

  /// Buka halaman Masuk (login) — semua halaman lama dibuang.
  static void openLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  /// Buka halaman utama setelah berhasil login/daftar.
  static void openMain(BuildContext context, String username) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainPage(username: username)),
      (route) => false,
    );
  }

  /// Buka halaman Daftar (ditumpuk di atas halaman Masuk).
  static void openRegister(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterPage()),
    );
  }
}
