import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/app_header.dart';
import '../widgets/stat_card.dart';
import '../widgets/settings_card.dart';
import 'map_page.dart';

// ============================================================
// PROFILE PAGE — PROFIL UTAMA & DATA TERSIMPAN
// ============================================================

class _AvatarItem {
  final String? assetPath;
  final IconData? icon;
  final String nameId;
  final String nameEn;

  const _AvatarItem.icon(this.icon, this.nameId, this.nameEn) : assetPath = null;
  const _AvatarItem.asset(this.assetPath, this.nameId, this.nameEn) : icon = null;
}

const List<_AvatarItem> _kAvatars = [
  _AvatarItem.icon(Icons.person, 'Penjelajah', 'Explorer'),
  _AvatarItem.asset('assets/images/hero.png', 'Pendekar Logika', 'Logic Warrior'),
  _AvatarItem.asset('assets/images/logo_npc.png', 'Mentor Guru', 'Guru Mentor'),
  _AvatarItem.asset('assets/images/monster.png', 'Bug Hunter', 'Bug Hunter'),
  _AvatarItem.icon(Icons.smart_toy, 'Robot AI', 'AI Robot'),
  _AvatarItem.icon(Icons.psychology, 'Pakar Algoritma', 'Algorithm Pro'),
  _AvatarItem.icon(Icons.sports_esports, 'Gamer Sejati', 'True Gamer'),
  _AvatarItem.icon(Icons.auto_awesome, 'Penyihir Kode', 'Code Wizard'),
];

class ProfilePage extends StatefulWidget {
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
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const String _kProfileName = 'algoquest_profile_name';
  static const String _kProfileAvatar = 'algoquest_avatar_index';

  String _displayName = '';
  int _avatarIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.username != oldWidget.username && _displayName.isEmpty) {
      _loadProfileData();
    }
  }

  Future<void> _loadProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(_kProfileName);
      final savedAvatar = prefs.getInt(_kProfileAvatar) ?? 0;
      if (mounted) {
        setState(() {
          _displayName = (savedName != null && savedName.isNotEmpty)
              ? savedName
              : widget.username;
          _avatarIndex = savedAvatar.clamp(0, _kAvatars.length - 1);
        });
      }
    } catch (_) {
      // diabaikan
    }
  }

  Future<void> _saveProfile(String name, int avatarIndex) async {
    setState(() {
      _displayName = name;
      _avatarIndex = avatarIndex.clamp(0, _kAvatars.length - 1);
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kProfileName, name);
      await prefs.setInt(_kProfileAvatar, _avatarIndex);
    } catch (_) {
      // diabaikan
    }
  }

  String _rank(int total) {
    if (total >= 35) return widget.isEnglish ? 'Logic Master' : 'Master Logika';
    if (total >= 20) return widget.isEnglish ? 'Logic Expert' : 'Ahli Logika';
    if (total >= 8) return widget.isEnglish ? 'Logic Adventurer' : 'Petualang Logika';
    if (total > 0) return widget.isEnglish ? 'Explorer' : 'Penjelajah';
    return widget.isEnglish ? 'Beginner' : 'Pemula';
  }

  Widget _buildAvatarWidget(_AvatarItem item, {double radius = 50}) {
    if (item.assetPath != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF303635),
        child: ClipOval(
          child: Image.asset(
            item.assetPath!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.person,
              size: radius * 1.1,
              color: Colors.white70,
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFF303635),
      child: Icon(
        item.icon ?? Icons.person,
        size: radius * 1.1,
        color: Colors.white70,
      ),
    );
  }

  void _openEditProfileSheet(BuildContext context) {
    final effectiveName = _displayName.isNotEmpty
        ? _displayName
        : (widget.username.isNotEmpty
            ? widget.username
            : (widget.isEnglish ? 'AlgoQuest Player' : 'Pemain AlgoQuest'));

    final TextEditingController nameController = TextEditingController(text: effectiveName);
    int tempAvatarIndex = _avatarIndex;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF141A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        side: BorderSide(color: Colors.white12),
      ),
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            final bool en = widget.isEnglish;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Modal
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          en ? 'Edit Profile' : 'Ubah Profil',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close, color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Pilihan Avatar
                    Text(
                      en ? 'CHOOSE AVATAR' : 'PILIH AVATAR',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 70,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _kAvatars.length,
                        separatorBuilder: (BuildContext context, int index) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final isSelected = tempAvatarIndex == idx;
                          final item = _kAvatars[idx];
                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                tempAvatarIndex = idx;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF42CFFF)
                                      : Colors.white24,
                                  width: isSelected ? 2.5 : 1.2,
                                ),
                              ),
                              child: _buildAvatarWidget(item, radius: 26),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Nama Pengguna
                    Text(
                      en ? 'USERNAME' : 'NAMA PENGGUNA',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFF202727),
                        hintText: en ? 'Enter your name' : 'Masukkan nama Anda',
                        hintStyle: const TextStyle(color: Colors.white38),
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Color(0xFF42CFFF),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Color(0xFF42CFFF),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Aksi
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white70,
                              side: const BorderSide(color: Colors.white24),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(en ? 'Cancel' : 'Batal'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              final trimmed = nameController.text.trim();
                              if (trimmed.isNotEmpty) {
                                _saveProfile(trimmed, tempAvatarIndex);
                              } else {
                                _saveProfile(
                                  en ? 'AlgoQuest Player' : 'Pemain AlgoQuest',
                                  tempAvatarIndex,
                                );
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF42CFFF),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              en ? 'Save' : 'Simpan',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentAvatar = _kAvatars[_avatarIndex.clamp(0, _kAvatars.length - 1)];
    final resolvedUsername = _displayName.isNotEmpty
        ? _displayName
        : (widget.username.isNotEmpty
            ? widget.username
            : (widget.isEnglish ? 'AlgoQuest Player' : 'Pemain AlgoQuest'));

    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: ValueListenableBuilder<int>(
          valueListenable: MapProgress.revision,
          builder: (BuildContext context, int revision, Widget? child) {
            final int totalStars = MapProgress.totalStars();
            final int level = 1 + totalStars ~/ 3;
            final int intoLevel = totalStars % 3;
            final double levelProgress = intoLevel / 3.0;
            final int xp = totalStars * 100;
            final String rankTitle = _rank(totalStars);

            return Column(
              children: [
                AppHeader(
                  title: 'Profile',
                  isEnglish: widget.isEnglish,
                  onLanguageChanged: widget.onLanguageChanged,
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
                                  _buildAvatarWidget(currentAvatar, radius: 50),
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
                                    child: Text(
                                      'LV $level',
                                      style: const TextStyle(
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
                                resolvedUsername,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                rankTitle,
                                style: const TextStyle(color: Colors.white70),
                              ),

                              const SizedBox(height: 16),

                              // BAR XP
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: LinearProgressIndicator(
                                        value: levelProgress.clamp(0.0, 1.0),
                                        minHeight: 8,
                                        backgroundColor: const Color(0x66000000),
                                        valueColor: const AlwaysStoppedAnimation(
                                          Color(0xFF42CFFF),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '$xp XP',
                                    style: const TextStyle(
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
                                  onPressed: () => _openEditProfileSheet(context),
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: Text(
                                    widget.isEnglish ? 'Edit Profile' : 'Ubah Profil',
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

                        // RINGKAS SINGKAT (HANYA STREAK DAN BINTANG)
                        Row(
                          children: [
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
                                value: totalStars.toString(),
                                label: widget.isEnglish ? 'Stars' : 'Bintang',
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // MENU AKUN
                        Text(
                          widget.isEnglish ? 'ACCOUNT' : 'AKUN',
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
                                label: widget.isEnglish ? 'Achievements' : 'Prestasi',
                                value: widget.isEnglish ? '12 badges' : '12 lencana',
                              ),
                              const Divider(color: Colors.white10, height: 1),
                              _MenuRow(
                                icon: Icons.history,
                                label: widget.isEnglish
                                    ? 'Quest History'
                                    : 'Riwayat Quest',
                                value: widget.isEnglish ? '7 quests' : '7 quest',
                              ),
                              const Divider(color: Colors.white10, height: 1),
                              _MenuRow(
                                icon: Icons.favorite_border,
                                label: widget.isEnglish ? 'Favorites' : 'Favorit',
                              ),
                              const Divider(color: Colors.white10, height: 1),
                              _MenuRow(
                                icon: Icons.help_outline,
                                label: widget.isEnglish
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
            );
          },
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
