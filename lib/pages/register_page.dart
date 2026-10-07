import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../services/auth_service.dart';
import '../widgets/app_text_field.dart';

// ============================================================
// HALAMAN DAFTAR (REGISTER)
// ============================================================
// Pengguna membuat nama pengguna & kata sandi sendiri.
// Akun disimpan offline di HP ini (lihat services/auth_service.dart).

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final String username = _usernameCtrl.text.trim();
    final String password = _passwordCtrl.text;

    // Validasi sebelum lanjut
    if (username.length < 3) {
      setState(() => _error = 'Nama pengguna minimal 3 karakter.');
      return;
    }
    if (password.length < 4) {
      setState(() => _error = 'Kata sandi minimal 4 karakter.');
      return;
    }
    if (password != _confirmCtrl.text) {
      setState(() => _error = 'Konfirmasi kata sandi tidak sama.');
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    final String? result = await Auth.register(
      username: username,
      password: password,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        _error = result;
        _loading = false;
      });
      return;
    }

    // Berhasil -> otomatis masuk
    AppRoutes.openMain(context, username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 15),

              const Text(
                'Buat Akun',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Isi data dengan username & sandi buatanmu sendiri',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 15),
              ),

              const SizedBox(height: 30),

              // NAMA PENGGUNA
              AppTextField(
                controller: _usernameCtrl,
                label: 'Nama Pengguna',
                icon: Icons.person_outline,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // KATA SANDI
              AppTextField(
                controller: _passwordCtrl,
                label: 'Kata Sandi',
                icon: Icons.lock_outline,
                obscure: _obscurePassword,
                textInputAction: TextInputAction.next,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),

              const SizedBox(height: 16),

              // ULANGI KATA SANDI
              AppTextField(
                controller: _confirmCtrl,
                label: 'Ulangi Kata Sandi',
                icon: Icons.lock_reset_outlined,
                obscure: _obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
              ),

              const SizedBox(height: 6),

              const Text(
                'Minimal 4 karakter. Kata sandi disimpan dalam '
                'bentuk hash, bukan teks biasa.',
                style: TextStyle(color: Colors.white38, fontSize: 12),
              ),

              // PESAN ERROR
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
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
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Color(0xFFFFB4B4),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 26),

              // TOMBOL DAFTAR
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF08A9C8),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF1C5A66),
                    disabledForegroundColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add_alt_1),
                            SizedBox(width: 8),
                            Text(
                              'Buat Akun',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 18),

              // INFO OFFLINE
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF18211F),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.wifi_off_rounded,
                      color: Color(0xFF8DE7F5),
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '100% offline — tidak perlu internet, '
                        'akun hanya berlaku di HP ini.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // KEMBALI KE HALAMAN MASUK
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun?',
                    style: TextStyle(color: Colors.white70),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        color: Color(0xFF42CFFF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
