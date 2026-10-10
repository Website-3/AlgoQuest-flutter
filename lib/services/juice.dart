import 'dart:async';

import 'package:flutter/services.dart';

import 'audio_service.dart';

// ============================================================
// JUICE — UMPAN BALIK (SUARA + GETARAN)
// ============================================================
// Satu tempat untuk semua "rasa" saat pemain beraksi: efek suara dan
// getaran (haptics). Semua panggilan aman di platform apa pun (di web
// getaran tidak tersedia dan otomatis diabaikan).

class Juice {
  Juice._();

  /// Getaran menyala/tidak (diatur dari halaman Pengaturan).
  static bool hapticsEnabled = true;

  static void _sound(String name, {double volumeScale = 1.0}) {
    GameAudio.instance.play(name, volumeScale: volumeScale);
  }

  static void _haptic(Future<void> Function() action) {
    if (!hapticsEnabled) return;
    try {
      unawaited(action().catchError((Object error, StackTrace stack) {}));
    } catch (_) {
      // diabaikan
    }
  }

  // ---------- Tombol / navigasi ----------
  static void click() {
    _sound('click', volumeScale: 0.5);
    _haptic(HapticFeedback.selectionClick);
  }

  // ---------- Aksi tempur ----------
  static void attack() {
    _sound('attack');
    _haptic(HapticFeedback.lightImpact);
  }

  static void skill() {
    _sound('skill');
    _haptic(HapticFeedback.mediumImpact);
  }

  static void dodge() {
    _sound('dodge');
    _haptic(HapticFeedback.selectionClick);
  }

  /// Monster terkena serangan.
  static void hit() {
    _sound('hit');
    _haptic(HapticFeedback.lightImpact);
  }

  /// Pemain terkena serangan.
  static void hurt() {
    _sound('hurt');
    _haptic(HapticFeedback.heavyImpact);
  }

  // ---------- Hasil ----------
  static void victory() {
    _sound('victory');
    _haptic(HapticFeedback.mediumImpact);
  }

  static void defeat() {
    _sound('defeat');
    _haptic(HapticFeedback.heavyImpact);
  }

  static void star() {
    _sound('star');
    _haptic(HapticFeedback.lightImpact);
  }

  /// Aksi tidak valid / gagal (mis. tertabrak dinding).
  static void error() {
    _sound('error');
    _haptic(HapticFeedback.heavyImpact);
  }
}
