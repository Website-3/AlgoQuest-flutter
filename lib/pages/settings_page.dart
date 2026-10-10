import 'package:flutter/material.dart';
import '../services/app_settings.dart';
import '../services/audio_service.dart';
import '../services/juice.dart';
import '../widgets/app_header.dart';
import '../widgets/settings_card.dart';

// ============================================================
// SETTINGS PAGE
// ============================================================

class SettingsPage extends StatefulWidget {
  final bool isEnglish;
  final VoidCallback onLanguageChanged;

  /// Dipanggil saat tombol "Keluar" ditekan (logout dari sesi).
  final VoidCallback? onLogout;

  const SettingsPage({
    super.key,
    required this.isEnglish,
    required this.onLanguageChanged,
    this.onLogout,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool soundOn = GameAudio.instance.enabled;
  bool hapticsOn = Juice.hapticsEnabled;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Settings',
              isEnglish: widget.isEnglish,
              onLanguageChanged: widget.onLanguageChanged,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BAHASA
                    _SectionTitle(
                      widget.isEnglish ? 'LANGUAGE' : 'BAHASA',
                    ),

                    const SizedBox(height: 12),

                    SettingsCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.translate,
                            color: Colors.white70,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.isEnglish
                                  ? 'App Language'
                                  : 'Bahasa Aplikasi',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          _LanguageChip(
                            label: 'ID',
                            selected: !widget.isEnglish,
                            onTap: () {
                              if (widget.isEnglish) {
                                widget.onLanguageChanged();
                              }
                            },
                          ),
                          const SizedBox(width: 8),
                          _LanguageChip(
                            label: 'EN',
                            selected: widget.isEnglish,
                            onTap: () {
                              if (!widget.isEnglish) {
                                widget.onLanguageChanged();
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // PREFERENSI
                    _SectionTitle(
                      widget.isEnglish ? 'PREFERENCES' : 'PREFERENSI',
                    ),

                    const SizedBox(height: 12),

                    SettingsCard(
                      child: Column(
                        children: [
                          _SwitchTile(
                            icon: Icons.volume_up_outlined,
                            title: widget.isEnglish
                                ? 'Sound Effects'
                                : 'Efek Suara',
                            value: soundOn,
                            onChanged: (v) {
                              setState(() => soundOn = v);
                              AppSettings.setSound(v);
                              if (v) Juice.click();
                            },
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _SwitchTile(
                            icon: Icons.vibration,
                            title: widget.isEnglish ? 'Vibration' : 'Getaran',
                            value: hapticsOn,
                            onChanged: (v) {
                              setState(() => hapticsOn = v);
                              AppSettings.setHaptics(v);
                              if (v) Juice.click();
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // TENTANG
                    _SectionTitle(widget.isEnglish ? 'ABOUT' : 'TENTANG'),

                    const SizedBox(height: 12),

                    SettingsCard(
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.sports_esports_outlined,
                            label: 'AlgoQuest',
                            value: isEnglishValue(),
                          ),
                          const Divider(color: Colors.white10, height: 1),
                          _InfoRow(
                            icon: Icons.info_outline,
                            label: widget.isEnglish ? 'Version' : 'Versi',
                            value: '1.0.0+1',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // KELUAR
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: widget.onLogout,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF5A5A),
                          side: const BorderSide(color: Color(0xFF7A2E2E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.logout),
                            const SizedBox(width: 8),
                            Text(
                              widget.isEnglish ? 'Log Out' : 'Keluar',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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

  String isEnglishValue() {
    return widget.isEnglish ? 'Logic Adventure' : 'Petualangan Logika';
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        letterSpacing: 2,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 16)),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: const Color(0xFF42CFFF),
          inactiveTrackColor: const Color(0xFF363B39),
          thumbColor: WidgetStateProperty.resolveWith<Color>(
            (Set<WidgetState> states) => states.contains(WidgetState.selected)
                ? const Color(0xFF0B100F)
                : const Color(0xFF8A9795),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: const TextStyle(fontSize: 16)),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}

class _LanguageChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF42CFFF) : const Color(0xFF303635),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

