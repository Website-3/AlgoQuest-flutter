import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'audio_service.dart';
import 'juice.dart';

// ============================================================
// APP SETTINGS — PREFERENSI (SUARA & GETARAN) YANG TERSIMPAN
// ============================================================

class AppSettings {
  AppSettings._();

  static const String _kSound = 'pref_sound_enabled';
  static const String _kHaptics = 'pref_haptics_enabled';

  /// Sinyal agar UI penyetel (halaman Pengaturan) ikut menyegarkan.
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<void> load() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      GameAudio.instance.enabled = prefs.getBool(_kSound) ?? true;
      Juice.hapticsEnabled = prefs.getBool(_kHaptics) ?? true;
      revision.value++;
    } catch (_) {
      // diabaikan: pakai nilai bawaan
    }
  }

  static Future<void> setSound(bool value) async {
    GameAudio.instance.enabled = value;
    revision.value++;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kSound, value);
    } catch (_) {
      // diabaikan
    }
  }

  static Future<void> setHaptics(bool value) async {
    Juice.hapticsEnabled = value;
    revision.value++;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kHaptics, value);
    } catch (_) {
      // diabaikan
    }
  }
}
