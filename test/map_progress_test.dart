import 'dart:convert';

import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUp(MapProgress.reset);

  test('bintang tersimpan per level', () {
    MapProgress.setStars(0, 0, 2);

    expect(MapProgress.starsOf(0, 0), 2);
    expect(MapProgress.starsOf(0, 1), 0);
  });

  test('level berikutnya terbuka setelah level sebelumnya selesai', () {
    expect(MapProgress.isLevelUnlocked(0, 1), isFalse);

    MapProgress.setStars(0, 0, 1);

    expect(MapProgress.isLevelUnlocked(0, 1), isTrue);
  });

  test('wilayah berikutnya butuh minimal 2 bintang di semua level', () {
    expect(MapProgress.isRegionUnlocked(1), isFalse);

    for (var l = 0; l < MapProgress.levelsPerRegion; l++) {
      MapProgress.setStars(0, l, 2);
    }

    expect(MapProgress.isRegionReady(0), isTrue);
    expect(MapProgress.isRegionUnlocked(1), isTrue);
  });

  test('wilayah 1 selalu terbuka', () {
    expect(MapProgress.isRegionUnlocked(0), isTrue);
    expect(MapProgress.isLevelUnlocked(0, 0), isTrue);
  });

  test('totalStars & regionStars menjumlahkan bintang', () {
    MapProgress.setStars(0, 0, 3);
    MapProgress.setStars(0, 1, 2);

    expect(MapProgress.totalStars(), 5);
    expect(MapProgress.regionStars(0), 5);
    expect(MapProgress.completedLevels(), 2);
  });

  test('setStars membatasi nilai 0..3', () {
    MapProgress.setStars(0, 0, 9);
    expect(MapProgress.starsOf(0, 0), 3);

    MapProgress.setStars(0, 0, -2);
    expect(MapProgress.starsOf(0, 0), 0);
  });

  test('bintang maksimum seluruh peta adalah 45', () {
    expect(
      MapProgress.maxTotalStars(),
      MapProgress.totalLevels * MapProgress.maxStars,
    );
    expect(MapProgress.maxTotalStars(), 45);
  });

  test('progres tersimpan lalu dimuat kembali', () async {
    MapProgress.setStars(1, 2, 3);
    await MapProgress.save();

    // Kosongkan memori, lalu muat dari penyimpanan.
    MapProgress.reset();
    expect(MapProgress.starsOf(1, 2), 0);

    await MapProgress.load();
    expect(MapProgress.starsOf(1, 2), 3);
  });

  test('migrasi simpanan lama dua mode memakai bintang terbaik', () async {
    final List<int> adventure = List<int>.filled(MapProgress.totalLevels, 0);
    final List<int> logic = List<int>.filled(MapProgress.totalLevels, 0);
    adventure[0] = 3;
    adventure[1] = 1;
    logic[0] = 1;
    logic[1] = 3;

    SharedPreferences.setMockInitialValues(<String, Object>{
      'map_progress_v1': jsonEncode(<String, Object>{
        'adventure': adventure,
        'logic': logic,
        'story': <bool>[true, false, false, false, false],
        'quiz': List<bool>.filled(MapProgress.totalLevels, false),
      }),
    });

    MapProgress.reset();
    await MapProgress.load();

    expect(MapProgress.starsOf(0, 0), 3);
    expect(MapProgress.starsOf(0, 1), 3);
    expect(MapProgress.isStorySeen(0), isTrue);
  });

  test('helpers jumlah: readyRegions', () {
    MapProgress.setStars(0, 0, 2);
    MapProgress.setStars(0, 1, 2);
    MapProgress.setStars(0, 2, 2);

    expect(MapProgress.readyRegions(), 1);
    expect(MapProgress.totalStars(), 6);
  });

  test('cerita wilayah ditandai sudah dibaca & bertahan setelah simpan', () async {
    expect(MapProgress.isStorySeen(2), isFalse);

    MapProgress.markStorySeen(2);
    expect(MapProgress.isStorySeen(2), isTrue);
    expect(MapProgress.isStorySeen(0), isFalse);

    await MapProgress.save();
    MapProgress.storySeen[2] = false; // lupakan di memori
    await MapProgress.load();
    expect(MapProgress.isStorySeen(2), isTrue);
  });

  test('soal benar dihitung sekali per level & tersimpan', () async {
    expect(MapProgress.quizCorrectCount(), 0);
    expect(MapProgress.isQuizCorrect(0, 0), isFalse);

    MapProgress.markQuizCorrect(0, 0);
    MapProgress.markQuizCorrect(0, 0); // ganda tidak menambah
    MapProgress.markQuizCorrect(3, 1);
    expect(MapProgress.quizCorrectCount(), 2);
    expect(MapProgress.isQuizCorrect(0, 0), isTrue);
    expect(MapProgress.isQuizCorrect(3, 1), isTrue);
    expect(MapProgress.isQuizCorrect(0, 1), isFalse);

    await MapProgress.save();
    MapProgress.quizCorrect[0] = false;
    MapProgress.quizCorrect[10] = false;
    await MapProgress.load();
    expect(MapProgress.isQuizCorrect(0, 0), isTrue);
    expect(MapProgress.isQuizCorrect(3, 1), isTrue);
  });
}
