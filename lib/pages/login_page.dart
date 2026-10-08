import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';

// ============================================================
// HALAMAN MASUK (LOGIN) — sesuai wireframe "Halaman Masuk"
// ============================================================
// Susunan: top bar -> kartu karakter wizard -> kartu login
//          -> kartu info offline.
// Login 100% offline, diverifikasi lewat class Auth.

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _loading = false;
  String? _error;
  bool _isEnglish = false; // toggle ID | EN di top bar

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() => _isEnglish = !_isEnglish);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _error = null;
      _loading = true;
    });

    final String? result = await Auth.login(
      username: _usernameCtrl.text,
      password: _passwordCtrl.text,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _error = result;
        _loading = false;
      });
      return;
    }

    AppRoutes.openMain(context, _usernameCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F0F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTopBar(),

              const SizedBox(height: 14),

              _buildCharacterCard(),

              const SizedBox(height: 14),

              _buildLoginCard(),

              const SizedBox(height: 14),

              _buildOfflineCard(),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // TOP BAR: <- logo OFFLINE | ID/EN | energi | avatar
  // ==========================================================
  Widget _buildTopBar() {
    return Row(
      children: [
        // KEMBALI (jika bisa)
        if (Navigator.canPop(context))
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white70),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),

        // LOGO KECIL
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFB90016),
            borderRadius: BorderRadius.circular(9),
          ),
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            'assets/images/logo_algoquest.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.auto_awesome, size: 18, color: Colors.white);
            },
          ),
        ),

        const SizedBox(width: 8),

        // BADGE OFFLINE
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0E3A3F),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF42CFFF)),
          ),
          child: const Text(
            'OFFLINE',
            style: TextStyle(
              color: Color(0xFF42CFFF),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),

        const Spacer(),

        // TOGGLE BAHASA ID | EN
        Container(
          height: 32,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: const Color(0xFF303635),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: [
              _langChip('ID', selected: !_isEnglish),
              _langChip('EN', selected: _isEnglish),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // ENERGI
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white24),
          ),
          child: const Row(
            children: [
              Text('⚡', style: TextStyle(fontSize: 15)),
              SizedBox(width: 3),
              Text(
                '42',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // AVATAR
        CircleAvatar(
          radius: 16,
          backgroundColor: const Color(0xFF303635),
          backgroundImage: AssetImage('assets/images/logo_npc.png'),
        ),
      ],
    );
  }

  Widget _langChip(String label, {required bool selected}) {
    return GestureDetector(
      onTap: _toggleLanguage,
      child: Container(
        width: 32,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF42CFFF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // KARTU KARAKTER: badge + LVL 99 + wizard + quote
  // ==========================================================
  Widget _buildCharacterCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF171D1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BADGE JABATAN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF3A2E12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF725E2E)),
            ),
            child: Text(
              _isEnglish
                  ? 'WIZARD SYNTAX · OFFLINE GUARDIAN'
                  : 'WIZARD SYNTAX · PENGAWAL OFFLINE',
              style: const TextStyle(
                color: Color(0xFFFFC15C),
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // GAMBAR WIZARD
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3A3F),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF42CFFF)),
                ),
                padding: const EdgeInsets.all(6),
                child: Image.asset(
                  'assets/images/logo_npc.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: Color(0xFF8DE7F5),
                    );
                  },
                ),
              ),

              const SizedBox(width: 12),

              // KANAN: LVL + QUOTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BADGE LEVEL
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A3416),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'LVL 99',
                        style: TextStyle(
                          color: Color(0xFFFFB21A),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // QUOTE
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F1413),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEnglish
                                ? '“Ready your spells for the realm ahead!”'
                                : '“Siapkan mantramu, coder!”',
                            style: const TextStyle(
                              color: Color(0xFFFFB21A),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isEnglish
                                ? 'Siapkan mantramu, coder!'
                                : 'Ready your spells for the realm ahead!',
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KARTU LOGIN
  // ==========================================================
  Widget _buildLoginCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171D1C),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IKON KUNCI + JUDUL
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF164653),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF4DD7F7),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isEnglish ? 'Enter the Adventure...' : 'Masuk Ke Petualangan...',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isEnglish
                          ? 'Access your adventurer profile'
                          : 'Akses profil petualangmu di perangkat ini',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          const Text(
            '- Local device access',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),

          const SizedBox(height: 20),

          // ---- USERNAME ----
          _fieldLabel(
            _isEnglish ? 'PLAYER NAME / USERNAME' : 'NAMA PEMAIN / USERNAME',
            'var hero_name;',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _usernameCtrl,
            textInputAction: TextInputAction.next,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hint: _isEnglish ? 'Alex_Coder' : 'Alex_Coder',
              icon: Icons.person_outline,
            ),
          ),

          const SizedBox(height: 16),

          // ---- PASSWORD ----
          _fieldLabel(
            _isEnglish ? 'SECRET KEY / PASSWORD' : 'KATA SANDI / PASSWORD',
            'const hash_key;',
          ),

          const SizedBox(height: 8),

          TextField(
            controller: _passwordCtrl,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration(
              hint: '••••••••••',
              icon: Icons.lock_outline,
              suffix: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                onPressed: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ---- INGAT SAYA + PIN ----
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (v) {
                  setState(() => _rememberMe = v ?? true);
                },
                activeColor: const Color(0xFF42CFFF),
                checkColor: Colors.black,
                side: const BorderSide(color: Colors.white38),
              ),
              GestureDetector(
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Text(
                  _isEnglish ? 'Remember Me' : 'Ingat Saya',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),

              const Spacer(),

              // BADGE PIN
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3A3F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 13, color: Color(0xFF42CFFF)),
                    SizedBox(width: 5),
                    Text(
                      'PIN Pengaman Aktif',
                      style: TextStyle(
                        color: Color(0xFF42CFFF),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ---- PESAN ERROR ----
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: const Color(0xFF3A1E1E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7A2E2E)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFFF7A7A),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: Color(0xFFFFB4B4),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 18),

          // ---- TOMBOL MASUK ----
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB21A),
                foregroundColor: Colors.black,
                disabledBackgroundColor: const Color(0xFF7A6124),
                disabledForegroundColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.black,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_esports, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _isEnglish
                              ? 'ENTER ADVENTURE'
                              : 'MASUK PETUALANGAN',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 12),

          // ---- LINK DAFTAR ----
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                _isEnglish
                    ? 'No adventurer account yet?'
                    : 'Belum punya akun petualang?',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
              TextButton(
                onPressed: () => AppRoutes.openRegister(context),
                child: Text(
                  _isEnglish ? 'Register Now' : 'Daftar Sekarang',
                  style: const TextStyle(
                    color: Color(0xFF42CFFF),
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF42CFFF),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // KARTU INFO OFFLINE
  // ==========================================================
  Widget _buildOfflineCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141A19),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF0E3A3F)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Color(0xFF42CFFF),
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isEnglish
                      ? 'OFFLINE STORAGE ACTIVE'
                      : 'PENYIMPANAN OFFLINE AKTIF',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E3A3F),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '100% BEBAS KUOTA',
                  style: TextStyle(
                    color: Color(0xFF42CFFF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            _isEnglish
                ? 'Data is stored safely in this device\'s local storage '
                      '(Offline Save). You can play anytime without an '
                      'internet connection.'
                : 'Data tersimpan aman di penyimpanan lokal HP '
                      '(Offline Save). Anda dapat bermain kapan pun '
                      'tanpa koneksi internet.',
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12.5,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BANTUAN TAMPILAN
  // ==========================================================
  Widget _fieldLabel(String label, String code) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1413),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white10),
          ),
          child: Text(
            code,
            style: const TextStyle(
              color: Color(0xFF4DD7F7),
              fontSize: 11,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30),
      prefixIcon: Icon(icon, color: Colors.white54, size: 20),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF0F1413),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.white12),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF42CFFF)),
      ),
    );
  }
}
