import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

// ============================================================
// AUDIO SERVICE — EFEK SUARA PERMAINAN
// ============================================================
// Ringan & tahan gagal: bila platform tidak mendukung audio (mis. saat
// pengujian), semua panggilan diabaikan tanpa melempar error. Berkas
// suara ada di assets/audio/*.wav (dibuat oleh tool/gen_sounds.dart).

class GameAudio {
  GameAudio._();

  static final GameAudio instance = GameAudio._();

  /// Diubah dari halaman Pengaturan. Default mati agar pengujian tidak
  /// menyentuh plugin audio; [main] menyalakannya untuk aplikasi nyata.
  bool enabled = false;

  /// Volume dasar (0..1).
  double volume = 0.85;

  static const int _poolSize = 6;
  final List<AudioPlayer> _pool = <AudioPlayer>[];
  int _next = 0;

  void _ignore(Future<void>? future) {
    if (future == null) return;
    unawaited(future.catchError((Object error, StackTrace stack) {}));
  }

  /// Siapkan beberapa pemutar agar bunyi pertama tidak tersendat.
  void warmUp() {
    if (!enabled || _pool.isNotEmpty) return;
    for (int i = 0; i < _poolSize; i++) {
      try {
        final AudioPlayer player = AudioPlayer();
        _ignore(player.setReleaseMode(ReleaseMode.stop));
        _pool.add(player);
      } catch (_) {
        // diabaikan
      }
    }
  }

  AudioPlayer _obtain() {
    if (_pool.length < _poolSize) {
      final AudioPlayer player = AudioPlayer();
      _ignore(player.setReleaseMode(ReleaseMode.stop));
      _pool.add(player);
      return player;
    }
    final AudioPlayer player = _pool[_next % _poolSize];
    _next++;
    return player;
  }

  /// Putar efek suara [name] (mis. 'attack', 'hit', 'victory').
  void play(String name, {double volumeScale = 1.0}) {
    if (!enabled) return;
    try {
      final AudioPlayer player = _obtain();
      _ignore(player.stop());
      _ignore(player.setVolume((volume * volumeScale).clamp(0.0, 1.0)));
      _ignore(player.play(AssetSource('audio/$name.wav')));
    } catch (_) {
      // diabaikan
    }
  }
}
