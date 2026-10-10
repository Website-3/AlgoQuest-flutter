// ============================================================
// GENERATOR EFEK SUARA (OFFLINE, TANPA ASET EKSTERNAL)
// ============================================================
// Skrip ini mensintesis file WAV pendek untuk efek permainan ke
// folder assets/audio/. Jalankan sekali:
//
//   dart run tool/gen_sounds.dart
//
// Semua suara dibuat dari osilator sederhana (sine/square/saw/tri)
// + derau (noise) dengan amplop (envelope). File 16-bit mono 44.1kHz.

import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _sr = 44100;

void main() {
  final Directory dir = Directory('assets/audio');
  if (!dir.existsSync()) dir.createSync(recursive: true);

  final Map<String, Float64List> sounds = <String, Float64List>{
    'click': _click(),
    'attack': _attack(),
    'hit': _hit(),
    'hurt': _hurt(),
    'dodge': _dodge(),
    'skill': _skill(),
    'victory': _victory(),
    'defeat': _defeat(),
    'star': _star(),
    'error': _error(),
  };

  sounds.forEach((String name, Float64List buf) {
    final int bytes = _write('assets/audio/$name.wav', buf);
    stdout.writeln('  $name.wav  ($bytes bytes)');
  });
  stdout.writeln('Selesai: ${sounds.length} file di assets/audio/');
}

// ---------- Bentuk gelombang ----------
Float64List _buf(double seconds) => Float64List((_sr * seconds).round());

double _wave(String type, double phase) {
  switch (type) {
    case 'square':
      return math.sin(phase) >= 0 ? 0.6 : -0.6;
    case 'saw':
      final double p = (phase / (2 * math.pi)) % 1.0;
      return 2 * p - 1;
    case 'tri':
      final double p = (phase / (2 * math.pi)) % 1.0;
      return p < 0.5 ? 4 * p - 1 : 3 - 4 * p;
    default:
      return math.sin(phase);
  }
}

/// Tambahkan satu nada (bisa menyapu frekuensi) ke [b].
void _tone(
  Float64List b, {
  required double start,
  required double dur,
  required double f0,
  double? f1,
  double amp = 0.5,
  String wave = 'sine',
  double decay = 6,
  double attack = 0.006,
}) {
  final int i0 = (start * _sr).round();
  final int n = (dur * _sr).round();
  final double fe = f1 ?? f0;
  double phase = 0;
  for (int i = 0; i < n; i++) {
    final int idx = i0 + i;
    if (idx < 0 || idx >= b.length) continue;
    final double t = i / _sr;
    final double p = n <= 1 ? 1 : i / (n - 1);
    final double freq = f0 + (fe - f0) * p;
    phase += 2 * math.pi * freq / _sr;
    final double atk = math.min(1.0, t / attack);
    final double env = atk * math.exp(-decay * t);
    b[idx] += amp * env * _wave(wave, phase);
  }
}

/// Tambahkan derau berlow-pass (untuk "whoosh"/hantaman).
void _noise(
  Float64List b, {
  required double start,
  required double dur,
  double amp = 0.4,
  double decay = 12,
  double lp = 0.4,
}) {
  final math.Random rng = math.Random(2026);
  final int i0 = (start * _sr).round();
  final int n = (dur * _sr).round();
  double prev = 0;
  for (int i = 0; i < n; i++) {
    final int idx = i0 + i;
    if (idx < 0 || idx >= b.length) continue;
    final double t = i / _sr;
    final double white = rng.nextDouble() * 2 - 1;
    prev += lp * (white - prev);
    final double env = math.min(1.0, t / 0.004) * math.exp(-decay * t);
    b[idx] += amp * env * prev;
  }
}

// ---------- Definisi tiap efek ----------
Float64List _click() {
  final Float64List b = _buf(0.06);
  _tone(b, start: 0, dur: 0.05, f0: 900, f1: 700, amp: 0.5, wave: 'tri',
      decay: 45);
  return b;
}

Float64List _attack() {
  final Float64List b = _buf(0.2);
  _noise(b, start: 0, dur: 0.16, amp: 0.45, decay: 20, lp: 0.55);
  _tone(b, start: 0, dur: 0.16, f0: 720, f1: 250, amp: 0.32, wave: 'saw',
      decay: 12);
  return b;
}

Float64List _hit() {
  final Float64List b = _buf(0.18);
  _tone(b, start: 0, dur: 0.14, f0: 190, f1: 70, amp: 0.7, decay: 18);
  _noise(b, start: 0, dur: 0.08, amp: 0.5, decay: 32, lp: 0.85);
  return b;
}

Float64List _hurt() {
  final Float64List b = _buf(0.28);
  _tone(b, start: 0, dur: 0.22, f0: 430, f1: 140, amp: 0.6, wave: 'saw',
      decay: 9);
  _noise(b, start: 0, dur: 0.1, amp: 0.35, decay: 26, lp: 0.4);
  return b;
}

Float64List _dodge() {
  final Float64List b = _buf(0.22);
  _noise(b, start: 0, dur: 0.18, amp: 0.4, decay: 14, lp: 0.3);
  _tone(b, start: 0, dur: 0.18, f0: 300, f1: 1500, amp: 0.22, decay: 12);
  return b;
}

Float64List _skill() {
  final Float64List b = _buf(0.5);
  _tone(b, start: 0.0, dur: 0.14, f0: 330, amp: 0.45, wave: 'tri', decay: 6);
  _tone(b, start: 0.11, dur: 0.14, f0: 494, amp: 0.45, wave: 'tri', decay: 6);
  _tone(b, start: 0.22, dur: 0.22, f0: 740, amp: 0.45, wave: 'tri', decay: 6);
  _tone(b, start: 0.06, dur: 0.34, f0: 300, f1: 1200, amp: 0.18, decay: 5);
  return b;
}

Float64List _victory() {
  final Float64List b = _buf(0.85);
  const List<double> notes = <double>[523, 659, 784, 1047];
  for (int i = 0; i < notes.length; i++) {
    _tone(b, start: i * 0.14, dur: 0.4, f0: notes[i], amp: 0.45,
        wave: 'tri', decay: 5);
  }
  return b;
}

Float64List _defeat() {
  final Float64List b = _buf(0.9);
  const List<double> notes = <double>[392, 330, 262, 196];
  for (int i = 0; i < notes.length; i++) {
    _tone(b, start: i * 0.17, dur: 0.45, f0: notes[i], amp: 0.5, decay: 4);
  }
  return b;
}

Float64List _star() {
  final Float64List b = _buf(0.3);
  _tone(b, start: 0, dur: 0.18, f0: 1318, amp: 0.5, decay: 22);
  _tone(b, start: 0, dur: 0.18, f0: 1976, amp: 0.22, decay: 26);
  return b;
}

Float64List _error() {
  final Float64List b = _buf(0.3);
  _tone(b, start: 0, dur: 0.09, f0: 150, amp: 0.4, wave: 'square', decay: 18);
  _tone(b, start: 0.12, dur: 0.12, f0: 120, amp: 0.4, wave: 'square',
      decay: 16);
  return b;
}

// ---------- Penulis berkas WAV ----------
int _write(String path, Float64List buf) {
  double peak = 0;
  for (final double v in buf) {
    final double a = v.abs();
    if (a > peak) peak = a;
  }
  final double norm = peak > 0.95 ? 0.95 / peak : 1.0;

  final Int16List pcm = Int16List(buf.length);
  for (int i = 0; i < buf.length; i++) {
    double v = buf[i] * norm;
    if (v > 1) v = 1;
    if (v < -1) v = -1;
    pcm[i] = (v * 32767).round();
  }

  final int dataLen = pcm.length * 2;
  final BytesBuilder out = BytesBuilder();
  out.add(_ascii('RIFF'));
  out.add(_u32(36 + dataLen));
  out.add(_ascii('WAVE'));
  out.add(_ascii('fmt '));
  out.add(_u32(16));
  out.add(_u16(1)); // PCM
  out.add(_u16(1)); // mono
  out.add(_u32(_sr));
  out.add(_u32(_sr * 2)); // byte rate
  out.add(_u16(2)); // block align
  out.add(_u16(16)); // bit depth
  out.add(_ascii('data'));
  out.add(_u32(dataLen));
  out.add(pcm.buffer.asUint8List());

  final List<int> bytes = out.toBytes();
  File(path).writeAsBytesSync(bytes);
  return bytes.length;
}

List<int> _ascii(String s) => s.codeUnits;

List<int> _u32(int v) => <int>[
      v & 0xFF,
      (v >> 8) & 0xFF,
      (v >> 16) & 0xFF,
      (v >> 24) & 0xFF,
    ];

List<int> _u16(int v) => <int>[v & 0xFF, (v >> 8) & 0xFF];
