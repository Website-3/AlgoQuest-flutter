import 'package:flutter_application_1/pages/map_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kosongkan seluruh progres (state statis) sebelum tiap tes.
void resetProgress() {
  for (var r = 0; r < MapProgress.regionCount; r++) {
    for (var l = 0; l < MapProgress.levelsPerRegion; l++) {
      MapProgress.setStars(r, l, GameMode.adventure, 0);
      MapProgress.setStars(r, l, GameMode.logic, 0);
    }
  }
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  setUp(resetProgress);

  test('bintang tersimpan terpisah untuk tiap mode', () {
    MapProgress.setStars(0, 0, GameMode.adventure, 3);

    expect(MapProgress.starsOf(0, 0, GameMode.adventure), 3);
    expect(MapProgress.starsOf(0, 0, GameMode.logic), 0);
    expect(MapProgress.bestStarsOf(0, 0), 3);
  });

  test('bestStarsOf mengambil nilai tertinggi antar mode', () {
    MapProgress.setStars(0, 0, GameMode.adventure, 1);
    MapProgress.setStars(0, 0, GameMode.logic, 2);

    expect(MapProgress.bestStarsOf(0, 0), 2);
  });

  test('level berikutnya terbuka dari mode mana pun', () {
    expect(MapProgress.isLevelUnlocked(0, 1), isFalse);

    MapProgress.setStars(0, 0, GameMode.adventure, 1);

    expect(MapProgress.isLevelUnlocked(0, 1), isTrue);
  });

  test('wilayah berikutnya butuh minimal 2 bintang di semua level', () {
    expect(MapProgress.isRegionUnlocked(1), isFalse);

    for (var l = 0; l < MapProgress.levelsPerRegion; l++) {
      MapProgress.setStars(0, l, GameMode.logic, 2);
    }

    expect(MapProgress.isRegionReady(0), isTrue);
    expect(MapProgress.isRegionUnlocked(1), isTrue);
  });

  test('wilayah 1 selalu terbuka', () {
    expect(MapProgress.isRegionUnlocked(0), isTrue);
    expect(MapProgress.isLevelUnlocked(0, 0), isTrue);
  });

  test('totalStars & regionStars menjumlahkan kedua mode', () {
    MapProgress.setStars(0, 0, GameMode.adventure, 3);
    MapProgress.setStars(0, 0, GameMode.logic, 2);

    expect(MapProgress.totalStars(), 5);
    expect(MapProgress.regionStars(0), 5);
    expect(MapProgress.completedLevels(), 1);
  });

  test('setStars membatasi nilai 0..3', () {
    MapProgress.setStars(0, 0, GameMode.adventure, 9);
    expect(MapProgress.starsOf(0, 0, GameMode.adventure), 3);

    MapProgress.setStars(0, 0, GameMode.adventure, -2);
    expect(MapProgress.starsOf(0, 0, GameMode.adventure), 0);
  });

  test('progres tersimpan lalu dimuat kembali (mode terpisah)', () async {
    MapProgress.setStars(1, 2, GameMode.adventure, 3);
    MapProgress.setStars(1, 2, GameMode.logic, 1);
    await MapProgress.save();

    // Kosongkan memori, lalu muat dari penyimpanan.
    MapProgress.reset();
    expect(MapProgress.starsOf(1, 2, GameMode.adventure), 0);

    await MapProgress.load();
    expect(MapProgress.starsOf(1, 2, GameMode.adventure), 3);
    expect(MapProgress.starsOf(1, 2, GameMode.logic), 1);
  });

  test('helpers jumlah: modeStars, maxTotalStars, readyRegions', () {
    MapProgress.setStars(0, 0, GameMode.adventure, 2);
    MapProgress.setStars(0, 1, GameMode.adventure, 2);
    MapProgress.setStars(0, 2, GameMode.adventure, 2);

    expect(MapProgress.modeStars(GameMode.adventure), 6);
    expect(MapProgress.modeStars(GameMode.logic), 0);
    expect(MapProgress.maxTotalStars(), 90);
    expect(MapProgress.readyRegions(), 1);
  });
}
