import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// LAYANAN LOGIN 100% OFFLINE
// ============================================================
// Tidak memerlukan internet maupun database server.
// Semua data akun disimpan di penyimpanan lokal HP
// (SharedPreferences) dalam bentuk hash.
//
// Alur:
//   register() -> buat akun baru + otomatis masuk
//   login()    -> verifikasi nama pengguna & kata sandi
//   logout()   -> keluar (akun tetap tersimpan)
//   currentUser() -> siapa yang sedang masuk (null = belum login)

class Auth {
  Auth._();

  static const String _keyAccounts = 'algoquest_accounts';
  static const String _keySession = 'algoquest_session';
  static const String _salt = 'AlgoQuest-Salt-v1';

  /// Kata sandi tidak pernah disimpan mentah, hanya hash SHA-256.
  static String _hash(String password) {
    return sha256.convert(utf8.encode('$_salt::$password')).toString();
  }

  static Future<Map<String, String>> _loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyAccounts);
    if (raw == null || raw.isEmpty) return <String, String>{};
    return Map<String, String>.from(jsonDecode(raw) as Map);
  }

  static Future<void> _saveAccounts(Map<String, String> accounts) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccounts, jsonEncode(accounts));
  }

  /// Nama pengguna yang sedang masuk, atau null bila belum login.
  static Future<String?> currentUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySession);
  }

  /// Buat akun baru.
  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  static Future<String?> register({
    required String username,
    required String password,
  }) async {
    final name = username.trim();

    if (name.length < 3) {
      return 'Nama pengguna minimal 3 karakter.';
    }
    if (password.length < 4) {
      return 'Kata sandi minimal 4 karakter.';
    }

    final accounts = await _loadAccounts();
    if (accounts.containsKey(name)) {
      return 'Nama pengguna sudah dipakai.';
    }

    accounts[name] = _hash(password);
    await _saveAccounts(accounts);
    await _setSession(name);
    return null;
  }

  /// Verifikasi login.
  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  ///
  /// [rememberMe] = true  -> sesi disimpan, app langsung masuk lagi
  ///                         saat dibuka berikutnya
  /// [rememberMe] = false -> sesi hanya berlaku selama app masih berjalan,
  ///                         saat dibuka lagi harus login ulang.
  static Future<String?> login({
    required String username,
    required String password,
    bool rememberMe = true,
  }) async {
    final name = username.trim();
    final accounts = await _loadAccounts();

    final stored = accounts[name];
    if (stored == null) {
      return 'Nama pengguna belum terdaftar.';
    }
    if (stored != _hash(password)) {
      return 'Kata sandi salah.';
    }

    if (rememberMe) {
      await _setSession(name);
    } else {
      // Tidak mengingat -> hapus sesi tersimpan (jika ada)
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keySession);
    }
    return null;
  }

  static Future<void> _setSession(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySession, username);
  }

  /// Keluar dari akun. Akun tetap tersimpan di HP.
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySession);
  }
}
