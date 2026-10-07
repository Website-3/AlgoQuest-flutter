import 'package:flutter/material.dart';
import '../widgets/app_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/settings_card.dart';

// ============================================================
// PROFILE PAGE
// ============================================================

class ProfilePage extends StatelessWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  /// Nama pengguna hasil login; kosong jika belum login.
  final String username;

  const ProfilePage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.username = '',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Profile',
              isEnglish: isEnglish,
              onLanguageChanged: onLanguageChanged,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KARTU PROFIL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF22343B), Color(0xFF143B44)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          // AVATAR + LENCANA LEVEL
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              const CircleAvatar(
                                radius: 50,
                                backgroundColor: Color(0xFF303635),
                                child: Icon(
                                  Icons.person,
                                  size: 55,
                                  color: Colors.white70,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF42CFFF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: const Text(
                                  'LV 10',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          Text(
                            username.isNotEmpty
                                ? username
                                : (isEnglish
                                      ? 'AlgoQuest Player'
                                      : 'Pemain AlgoQuest'),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            isEnglish
                                ? 'Logic Adventurer'
                                : 'Petualang Logika',
                            style: const TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 16),

                          // BAR XP
                          Row(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: const LinearProgressIndicator(
                                    value: 0.62,
                                    minHeight: 8,
                                    backgroundColor: Color(0x66000000),
                                    valueColor: AlwaysStoppedAnimation(
                                      Color(0xFF42CFFF),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                '1240 XP',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // UBAH PROFIL
                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 18),
                              label: Text(
                                isEnglish ? 'Edit Profile' : 'Ubah Profil',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Colors.white24,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // RINGKAS SINGKAT
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            icon: Icons.bolt,
                            iconColor: const Color(0xFFB9F13E),
                            value: '42',
                            label: isEnglish ? 'Energy' : 'Energi',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.local_fire_department,
                            iconColor: const Color(0xFFFF7A1A),
                            value: '12',
                            label: 'Streak',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatCard(
                            icon: Icons.star,
                            iconColor: const Color(0xFFFFC15C),
                            value: '18',
                            label: isEnglish ? 'Stars' : 'Bintang',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // MENU AKUN
                    Text(
                      isEnglish ? 'ACCOUNT' : 'AKUN',
                      style: const TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 12),

                    SettingsCard(
                      child: Column(
                        children: [
                          _MenuRow(
                            icon: Icons.emoji_events_outlined,
                            label: isEnglish ? 'Achievements' : 'Prestasi',
                            value: isEnglish ? '12 badges' : '12 lencana',
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _MenuRow(
                            icon: Icons.history,
                            label: isEnglish
                                ? 'Quest History'
                                : 'Riwayat Quest',
                            value: isEnglish ? '7 quests' : '7 quest',
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _MenuRow(
                            icon: Icons.favorite_border,
                            label: isEnglish ? 'Favorites' : 'Favorit',
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _MenuRow(
                            icon: Icons.help_outline,
                            label: isEnglish
                                ? 'Help Center'
                                : 'Pusat Bantuan',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MenuRow({
    required this.icon,
    required this.label,
    this.value = '',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 16)),
          ),
          if (value.isNotEmpty) ...[
            Text(
              value,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}
