import 'dart:async';

import 'package:flutter/material.dart';

import '../app_routes.dart';

// ============================================================
// HALAMAN PEMBUKA (SPLASH / LOADING)
// ============================================================
// Sesuai wireframe "Halaman Pembuka":
//   badge versi -> logo glow -> judul -> subjudul
//   -> teks inisialisasi -> bar loading + persentase -> tips
// Setelah loading selesai, lanjut ke AuthGate (cek login).

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  late Timer _timer;
  double _progress = 0;

  // Tips acak yang muncul saat loading (gaya wireframe)
  final List<String> _tips = [
    'TIP: Gunakan `<loop>` untuk melewati jebakan rintangan goblin!',
    'TIP: Simpan energi kamu untuk boss akhir chapter!',
    'TIP: Selesaikan quest harian agar naik level lebih cepat!',
    'TIP: Baca materi sebelum mencoba tantangan baru.',
  ];

  late final String _tip;

  @override
  void initState() {
    super.initState();
    _tip = (_tips..shuffle()).first;

    // Naikkan progress sedikit demi sedikit sampai 100%
    _timer = Timer.periodic(const Duration(milliseconds: 45), (timer) {
      if (!mounted) return;
      setState(() {
        _progress = (_progress + 0.018).clamp(0.0, 1.0);
      });

      if (_progress >= 1.0) {
        timer.cancel();
        // Loading selesai -> cek sesi login
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) AppRoutes.openGate(context);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int percent = (_progress * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 14),

              // ---- BADGE VERSI ----
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF181D1C),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Text(
                  'V1.0.4 · QUEST WORLD',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Spacer(),

              // ---- LOGO + GLOW ----
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF48D8FF).withValues(alpha: 0.45),
                      blurRadius: 45,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Image.asset(
                  'assets/images/logo_algoquest.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      size: 64,
                      color: Colors.black,
                    );
                  },
                ),
              ),

              const SizedBox(height: 26),

              // ---- JUDUL: Algo (putih) + Quest (oranye) ----
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'Algo',
                      style: TextStyle(color: Colors.white),
                    ),
                    TextSpan(
                      text: 'Quest',
                      style: TextStyle(color: Color(0xFFFFB21A)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'PETUALANGAN LOGIKA',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Color(0xFFFFB21A),
                ),
              ),

              const SizedBox(height: 34),

              const Text(
                'Inisialisasi Dunia Algoritma...',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const Spacer(),

              // ---- BAR LOADING + PERSENTASE ----
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Memuat Petualangan...',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      color: Color(0xFF48D8FF),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: const Color(0xFF24302E),
                  valueColor: const AlwaysStoppedAnimation(
                    Color(0xFF48D8FF),
                  ),
                ),
              ),

              const SizedBox(height: 26),

              // ---- TIPS ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF141A19),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  _tip,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
