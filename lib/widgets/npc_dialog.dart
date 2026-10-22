import 'package:flutter/material.dart';

import '../services/juice.dart';
import '../services/story_service.dart';

// ============================================================
// DIALOG NPC — CERITA WILAYAH + PETUNJUK
// ============================================================
// Menampilkan gambar Profesor Bit (logo_npc.png), narasi wilayah,
// dan satu petunjuk logika. Dipakai saat pemain pertama membuka
// sebuah wilayah, dan bisa dibuka ulang lewat ikon buku pada kartu
// wilayah di Peta.

const Color _kCard = Color(0xFF1D2221);
const Color _kCyan = Color(0xFF42CFFF);
const Color _kYellow = Color(0xFFFFB21A);
const Color _kText = Color(0xFFDDE7E9);

/// Buka dialog cerita wilayah. [region] berbasis 0.
Future<void> showNpcStory(
  BuildContext context, {
  required int region,
  required bool isEnglish,
}) {
  final RegionStory story = StoryCatalog.story(region);
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => _NpcStoryDialog(
      story: story,
      isEnglish: isEnglish,
    ),
  );
}

class _NpcStoryDialog extends StatelessWidget {
  final RegionStory story;
  final bool isEnglish;

  const _NpcStoryDialog({required this.story, required this.isEnglish});

  @override
  Widget build(BuildContext context) {
    final bool en = isEnglish;
    final Size size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: _kCard,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: size.height * 0.78),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ---- KEPALA: NPC + NAMA ----
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _kCyan.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _kCyan.withValues(alpha: 0.5),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/images/logo_npc.png',
                      fit: BoxFit.cover,
                      errorBuilder:
                          (BuildContext context, Object error, StackTrace? st) =>
                              const Icon(Icons.face_retouching_natural,
                                  color: _kCyan, size: 30),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          en
                              ? StoryCatalog.npcNameEn
                              : StoryCatalog.npcNameId,
                          style: const TextStyle(
                            color: _kCyan,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          story.title(en),
                          style: const TextStyle(
                            color: _kText,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ---- NARASI (bisa digulir bila panjang) ----
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      for (final String p in story.paragraphs(en))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            p,
                            style: const TextStyle(
                              color: _kText,
                              fontSize: 13.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // ---- KOTAK PETUNJUK ----
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kYellow.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kYellow.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Icon(Icons.lightbulb, color: _kYellow, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        story.hint(en),
                        style: const TextStyle(
                          color: Color(0xFFFFD98A),
                          fontSize: 12.5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ---- TOMBOL ----
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Juice.click();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    en ? 'Got it!' : 'Mengerti!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
