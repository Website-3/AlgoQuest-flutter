import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/services/story_service.dart';

void main() {
  test('ada cerita untuk 5 wilayah', () {
    expect(StoryCatalog.stories.length, 5);
  });

  test('tiap cerita lengkap dalam dua bahasa', () {
    for (int i = 0; i < StoryCatalog.stories.length; i++) {
      final RegionStory s = StoryCatalog.stories[i];

      expect(s.titleId.trim(), isNotEmpty, reason: 'wilayah $i');
      expect(s.titleEn.trim(), isNotEmpty, reason: 'wilayah $i');
      expect(s.hintId.trim(), isNotEmpty, reason: 'wilayah $i');
      expect(s.hintEn.trim(), isNotEmpty, reason: 'wilayah $i');

      // Minimal satu paragraf, jumlah sama di kedua bahasa.
      expect(s.paragraphsId.length, greaterThanOrEqualTo(1), reason: 'wilayah $i');
      expect(s.paragraphsEn.length, s.paragraphsId.length, reason: 'wilayah $i');
      for (final String p in <String>[...s.paragraphsId, ...s.paragraphsEn]) {
        expect(p.trim(), isNotEmpty, reason: 'wilayah $i');
      }
    }
  });

  test('nama NPC terisi', () {
    expect(StoryCatalog.npcNameId.trim(), isNotEmpty);
    expect(StoryCatalog.npcNameEn.trim(), isNotEmpty);
  });

  test('story(region) mengembalikan cerita yang benar & aman (clamp)', () {
    expect(StoryCatalog.story(0), same(StoryCatalog.stories[0]));
    expect(StoryCatalog.story(4), same(StoryCatalog.stories[4]));
    expect(StoryCatalog.story(99), same(StoryCatalog.stories[4]));
    expect(StoryCatalog.story(-3), same(StoryCatalog.stories[0]));
  });

  test('helper title/paragraphs/hint mengikuti bahasa', () {
    final RegionStory s = StoryCatalog.story(0);
    expect(s.title(true), s.titleEn);
    expect(s.title(false), s.titleId);
    expect(s.paragraphs(true), s.paragraphsEn);
    expect(s.hint(false), s.hintId);
  });
}
