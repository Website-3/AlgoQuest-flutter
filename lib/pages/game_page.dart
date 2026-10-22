import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/juice.dart';
import '../widgets/dungeon_board.dart';
import '../widgets/hero_token.dart';
import '../widgets/monster_token.dart';
import '../widgets/quiz_dialog.dart';
import 'map_page.dart';

// ============================================================
// GAME PAGE — ARENA LOGIKA (FANTASY RPG DUNGEON)
// ============================================================
// Alur permainan:
//   1. Karakter berada di dalam labirin dungeon.
//   2. Pemain menyusun blok perintah (Maju / Belok / Serang).
//   3. Tekan JALANKAN (RUN CODE) -> karakter bergerak sesuai urutan.
//   4. Kalahkan monster -> lanjut menjawab soal kuis logika.

// ---------- Palet Warna Fantasy RPG ----------
const Color _kBg = Color(0xFF070F14);
const Color _kPanelBg = Color(0xFF0B1723);
const Color _kPanelBgAlt = Color(0xFF0E1F2E);
const Color _kBorderGold = Color(0xFFC89738);
const Color _kBorderBlue = Color(0xFF1E3A52);
const Color _kCyan = Color(0xFF38BDF8);
const Color _kGold = Color(0xFFFFC043);
const Color _kOrange = Color(0xFFFF7A29);
const Color _kCrimson = Color(0xFFFF3856);
const Color _kGreen = Color(0xFF4ADE80);
const Color _kText = Color(0xFFEDF5F7);
const Color _kMuted = Color(0xFF8CA0B3);

class GamePage extends StatefulWidget {
  final int region;
  final int level;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onBack;

  /// Dipanggil setelah pemain menekan "Kembali ke Peta" atau lanjut.
  final void Function(int stars)? onFinished;

  /// Khusus pratinjau: memaksa animasi serangan ke posisi tertentu (0..1).
  final double? debugAttack;

  const GamePage({
    super.key,
    required this.region,
    required this.level,
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onBack,
    this.onFinished,
    this.debugAttack,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late MazeLevel _level;
  late MazeEngine _engine;

  final List<CommandBlock> _blocks = <CommandBlock>[];
  bool _running = false;

  /// Animasi serangan: karakter menerjang + tebasan + angka damage.
  late final AnimationController _attackCtrl;

  bool get _en => widget.isEnglish;

  @override
  void initState() {
    super.initState();
    _attackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _loadLevel();

    // Pratinjau debug serangan jika disediakan.
    if (widget.debugAttack != null) {
      for (final GameCommand command in _level.solution) {
        _engine.apply(command);
      }
      _attackCtrl.value = widget.debugAttack!.clamp(0.0, 1.0);
    }
  }

  @override
  void dispose() {
    _attackCtrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GamePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region || oldWidget.level != widget.level) {
      setState(() {
        _blocks.clear();
        _attackCtrl.reset();
        _loadLevel();
      });
    }
  }

  void _loadLevel() {
    _level = MazeCatalog.level(widget.region, widget.level);
    _engine = MazeEngine(_level);
  }

  // ----------------------------------------------------------
  // Aksi Blok & Logika Permainan
  // ----------------------------------------------------------
  void _addBlock(GameCommand command) {
    if (_running) return;
    final bool canMerge =
        _blocks.isNotEmpty &&
        _blocks.last.command == command &&
        _blocks.last.count < 9;
    if (!canMerge && _blocks.length >= _level.maxBlocks) {
      Juice.error();
      _toast(_en ? 'Block limit reached.' : 'Batas blok tercapai.');
      return;
    }
    Juice.click();
    setState(() {
      if (canMerge) {
        _blocks.last.count++;
      } else {
        _blocks.add(CommandBlock(command));
      }
    });
  }

  void _decBlock(int index) {
    if (_running) return;
    Juice.click();
    setState(() {
      if (_blocks[index].count > 1) {
        _blocks[index].count--;
      } else {
        _blocks.removeAt(index);
      }
    });
  }

  void _removeBlock(int index) {
    if (_running) return;
    Juice.click();
    setState(() => _blocks.removeAt(index));
  }

  void _clearBlocks() {
    if (_running) return;
    Juice.click();
    setState(() {
      _blocks.clear();
      _engine.reset();
      _attackCtrl.reset();
    });
  }

  Future<void> _run() async {
    if (_running) return;
    if (_blocks.isEmpty) {
      Juice.error();
      _toast(
        _en
            ? 'Add some command blocks first.'
            : 'Tambahkan blok perintah dulu.',
      );
      return;
    }

    Juice.click();
    setState(() {
      _running = true;
      _engine.reset();
      _attackCtrl.reset();
    });

    final List<GameCommand> commands = expandBlocks(_blocks);
    for (final GameCommand command in commands) {
      if (!mounted) return;
      if (_engine.defeated) break;

      final StepOutcome outcome = _engine.apply(command);
      setState(() {});

      if (outcome == StepOutcome.hit) {
        // Animasi serangan pedang & guncangan monster.
        Juice.attack();
        _attackCtrl.forward(from: 0);
        await Future<void>.delayed(const Duration(milliseconds: 440));
      } else {
        if (outcome == StepOutcome.blocked || outcome == StepOutcome.missed) {
          Juice.error();
        }
        await Future<void>.delayed(const Duration(milliseconds: 240));
      }
    }

    if (!mounted) return;
    setState(() => _running = false);

    if (_engine.defeated) {
      await _showVictory(_computeStars());
    } else {
      Juice.error();
      _toast(
        _en
            ? 'Monster is not defeated yet. Try again!'
            : 'Monster belum kalah. Coba lagi!',
      );
    }
  }

  int _computeStars() {
    final int steps = _engine.steps;
    if (steps <= _level.par) return 3;
    if (steps <= _level.par + 3) return 2;
    return 1;
  }

  Future<void> _showVictory(int stars) async {
    if (stars > MapProgress.starsOf(widget.region, widget.level)) {
      MapProgress.setStars(widget.region, widget.level, stars);
    }

    Juice.victory();
    Juice.star();

    final bool? next = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) => _victoryDialog(ctx, stars),
    );

    if (!mounted) return;
    if (next == true) {
      final bool correct = await showQuizDialog(
        context,
        region: widget.region,
        level: widget.level,
        isEnglish: _en,
      );
      if (!mounted) return;
      if (correct) MapProgress.markQuizCorrect(widget.region, widget.level);
      widget.onFinished?.call(stars);
    } else {
      setState(() => _engine.reset());
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _kPanelBgAlt,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ----------------------------------------------------------
  // Tampilan Utama (Build)
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: Stack(
        children: <Widget>[
          // Latar belakang suasana dungeon halus
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.2),
                  radius: 1.2,
                  colors: <Color>[
                    const Color(0xFF0F1E29),
                    _kBg,
                  ],
                ),
              ),
            ),
          ),
          // Hiasan siluet daun/rambatan di sudut bawah (dungeon atmosphere)
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _RpgFoliagePainter()),
            ),
          ),
          // Konten antarmuka utama
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      // 1. Header Misi (Top Bar: Back, Quest Pill, Lang, Energy)
                      _rpgTopBar(),
                      const SizedBox(height: 5),

                      // 2. Banner Monster HP & Indikator Bintang
                      _monsterHpBanner(),
                      const SizedBox(height: 6),

                      // 3. Area Labirin Dungeon (Fokus Utama + Mini-map HUD)
                      Expanded(child: _mazeArena()),
                      const SizedBox(height: 6),

                      // 4. Panel Urutan Logika
                      _logicSequence(),
                      const SizedBox(height: 6),

                      // 5. Palet Tombol Perintah
                      _commandsPalette(),
                      const SizedBox(height: 6),

                      // 6. Tombol Aksi (Reset & JALANKAN)
                      _runButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 1. HEADER MISI: TOP BAR
  // ==========================================================
  Widget _rpgTopBar() {
    final GameRegion region = gameRegions[widget.region.clamp(0, 4)];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        children: <Widget>[
          // Tombol Kembali berbingkai RPG
          _rpgBackButton(),
          const SizedBox(width: 8),

          // Kapsul Info Quest & Wilayah
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 38),
              padding: const EdgeInsets.fromLTRB(6, 2, 8, 2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF0E2231), Color(0xFF0A1823)],
                ),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _kBorderGold, width: 1.4),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: <Widget>[
                  // Ikon Wilayah
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFF143825),
                      shape: BoxShape.circle,
                      border: Border.all(color: _kGreen, width: 1.2),
                    ),
                    child: Icon(
                      widget.region == 0 ? Icons.park_rounded : region.icon,
                      color: _kGreen,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Teks Quest & Nama Wilayah
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            // Label 'Quest' dipertahankan untuk kompatibilitas uji
                            const Text(
                              'Quest',
                              style: TextStyle(
                                color: _kGold,
                                fontSize: 9.0,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Text(
                              ' \u2022 ',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 9.0,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${_en ? 'REGION' : 'WILAYAH'} ${widget.region + 1} \u2022 LEVEL ${widget.level + 1}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _kGold,
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          region.name(_en),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Pilihan Bahasa (ID | EN)
          _rpgLanguagePill(),
          const SizedBox(width: 6),

          // Informasi Energi Pemain
          _rpgEnergyPill(),
        ],
      ),
    );
  }

  Widget _rpgBackButton() {
    return InkWell(
      onTap: widget.onBack,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Color(0xFF142433), Color(0xFF0C1620)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2B475D), width: 1.4),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Color(0xFFE2F1F8),
          size: 20,
        ),
      ),
    );
  }

  Widget _rpgLanguagePill() {
    return GestureDetector(
      onTap: widget.onLanguageChanged,
      child: Container(
        height: 34,
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E2C),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF264056)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: !_en ? _kCyan : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'ID',
                style: TextStyle(
                  color: !_en ? Colors.black : const Color(0xFF8CA0B3),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: _en ? _kCyan : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'EN',
                style: TextStyle(
                  color: _en ? Colors.black : const Color(0xFF8CA0B3),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rpgEnergyPill() {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF121B24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF9E772E), width: 1.2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFFFFB703).withValues(alpha: 0.15),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Row(
        children: <Widget>[
          Icon(Icons.bolt_rounded, color: Color(0xFFFFD700), size: 17),
          SizedBox(width: 3),
          Text(
            '42',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // 2. BANNER MONSTER HP & INDIKATOR BINTANG
  // ==========================================================
  Widget _monsterHpBanner() {
    final int stars = MapProgress.starsOf(widget.region, widget.level);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: _rpgPanelDecoration(),
      child: Row(
        children: <Widget>[
          // Ikon Kepala Monster Tengkorak Merah
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF3F131A),
              shape: BoxShape.circle,
              border: Border.all(color: _kCrimson, width: 1.2),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: _kCrimson.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Icon(
              Icons.dangerous_rounded,
              color: _kCrimson,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),

          // Nama Monster & Health Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _level.monsterName(_en),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'HP ${_engine.enemyHp}/${_level.enemyHp}',
                      style: const TextStyle(
                        color: _kCrimson,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    height: 7,
                    decoration: BoxDecoration(
                      color: const Color(0xFF141F2B),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (_level.enemyHp == 0
                              ? 0.0
                              : _engine.enemyHp / _level.enemyHp)
                          .clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: <Color>[Color(0xFFFF2A55), Color(0xFFFF6B8B)],
                          ),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: const Color(0xFFFF2A55)
                                  .withValues(alpha: 0.65),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Indikator 3 Bintang
          _starsRow(stars),
        ],
      ),
    );
  }

  Widget _starsRow(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        3,
        (int i) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 1),
          child: Icon(
            i < stars ? Icons.star_rounded : Icons.star_border_rounded,
            color: i < stars ? _kGold : const Color(0xFF334155),
            size: 20,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 3. AREA LABIRIN DUNGEON (Fokus Utama + Mini-Map HUD)
  // ==========================================================
  Widget _mazeArena() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double side = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        return Center(
          child: SizedBox(
            key: const ValueKey<String>('maze_arena'),
            width: side,
            height: side,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: _rpgPanelDecoration(goldBorder: true),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints inner) {
                  final double cell = inner.maxWidth / _level.size;
                  return AnimatedBuilder(
                    animation: _attackCtrl,
                    builder: (BuildContext context, _) {
                      final double t = _attackCtrl.value;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: <Widget>[
                          // Papan Dungeon 3D (Lantai ubin, dinding batu, obor berkedip)
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: DungeonBoard(level: _level),
                            ),
                          ),

                          // Efek Serangan: tebasan pedang & angka damage
                          _attackEffect(cell, t),

                          // Monster / Goblin (Posisi & Animasi Guncangan)
                          _token(
                            key: const ValueKey<String>('monster'),
                            cell: cell,
                            row: _level.monster.row,
                            col: _level.monster.col,
                            child: Transform.translate(
                              offset: _shakeOffset(cell, t),
                              child: _monsterToken(cell * 0.92, t),
                            ),
                          ),

                          // Karakter Petualang (Hero Token + Posisi + Menerjang)
                          _token(
                            key: const ValueKey<String>('player'),
                            cell: cell,
                            row: _engine.row,
                            col: _engine.col,
                            child: Transform.translate(
                              offset: _lungeOffset(cell, t),
                              child: _heroToken(cell * 1.02),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _token({
    required Key key,
    required double cell,
    required int row,
    required int col,
    required Widget child,
  }) {
    return AnimatedPositioned(
      key: key,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      left: col * cell,
      top: row * cell,
      width: cell,
      height: cell,
      child: Center(child: child),
    );
  }

  // ---- Animasi Serangan ----
  Offset _lungeOffset(double cell, double t) {
    double p;
    if (t <= 0) {
      p = 0;
    } else if (t < 0.35) {
      p = Curves.easeOut.transform(t / 0.35);
    } else if (t < 0.6) {
      p = 1;
    } else {
      p = (1 - (t - 0.6) / 0.4).clamp(0.0, 1.0);
    }
    final double amount = p * cell * 0.42;
    return Offset(kDirCol[_engine.dir] * amount, kDirRow[_engine.dir] * amount);
  }

  Offset _shakeOffset(double cell, double t) {
    if (t < 0.35 || t > 0.75) return Offset.zero;
    final double local = (t - 0.35) / 0.4;
    final double damp = 1 - local;
    return Offset(math.sin(local * math.pi * 7) * cell * 0.16 * damp, 0);
  }

  double _hitFlash(double t) {
    if (t < 0.35 || t > 0.68) return 0;
    final double local = (t - 0.35) / 0.33;
    return (1 - (local * 2 - 1).abs()).clamp(0.0, 1.0);
  }

  double _slashOpacity(double t) {
    if (t < 0.33 || t > 0.72) return 0;
    final double local = (t - 0.33) / 0.39;
    if (local < 0.3) return (local / 0.3).clamp(0.0, 1.0);
    return (1 - (local - 0.3) / 0.7).clamp(0.0, 1.0);
  }

  double _damageProgress(double t) {
    if (t < 0.3) return 0;
    return ((t - 0.3) / 0.7).clamp(0.0, 1.0);
  }

  Widget _attackEffect(double cell, double t) {
    final double slash = _slashOpacity(t);
    final double dmg = _damageProgress(t);
    if (slash <= 0 && dmg <= 0) return const SizedBox.shrink();

    final Pos m = _level.monster;
    return Positioned(
      left: m.col * cell,
      top: m.row * cell,
      width: cell,
      height: cell,
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            if (slash > 0)
              Positioned.fill(
                child: Opacity(
                  opacity: slash,
                  child: CustomPaint(painter: _SlashPainter()),
                ),
              ),
            if (dmg > 0)
              Positioned(
                left: 0,
                right: 0,
                top: -cell * (0.45 + dmg * 1.05),
                child: Opacity(
                  opacity: (1 - dmg).clamp(0.0, 1.0),
                  child: _damageNumber('1'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _damageNumber(String value) {
    final TextStyle stroke = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = const Color(0xFF0F1416),
    );
    const TextStyle fill = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w900,
      color: _kGold,
    );
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text('-$value', textAlign: TextAlign.center, style: stroke),
        Text('-$value', textAlign: TextAlign.center, style: fill),
      ],
    );
  }

  Widget _heroToken(double size) {
    return HeroToken(size: size, facing: _engine.dir);
  }

  Widget _monsterToken(double size, double t) {
    final bool dead = _engine.defeated;
    final double flash = _hitFlash(t);
    return Opacity(
      opacity: dead ? 0.35 : 1,
      child: Transform.scale(
        scale: 1 + flash * 0.18,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: dead
                ? null
                : <BoxShadow>[
                    BoxShadow(
                      color: (flash > 0 ? Colors.white : _kCrimson).withValues(
                        alpha: flash > 0 ? 0.7 : 0.45,
                      ),
                      blurRadius: flash > 0 ? 20 : 12,
                    ),
                  ],
          ),
          child: MonsterToken(
            size: size,
            flash: flash,
            defeated: dead,
            tint: _kCrimson,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 4. PANEL URUTAN LOGIKA
  // ==========================================================
  Widget _logicSequence() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      decoration: _rpgPanelDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Baris Judul, Penghitung Blok, dan Tombol Hapus
          Row(
            children: <Widget>[
              // Ikon Code </>
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C2438),
                  shape: BoxShape.circle,
                  border: Border.all(color: _kCyan, width: 1.2),
                ),
                child: const Icon(Icons.code_rounded, color: _kCyan, size: 16),
              ),
              const SizedBox(width: 8),

              // Judul URUTAN LOGIKA
              Text(
                _en ? 'LOGIC SEQUENCE' : 'URUTAN LOGIKA',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),

              // Penghitung Blok (mis. 0/8)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0E2232),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF1E3A52)),
                ),
                child: Text(
                  '${_blocks.length}/${_level.maxBlocks}',
                  style: const TextStyle(
                    color: _kCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Tombol Hapus Merah
              InkWell(
                onTap: (_running || _blocks.isEmpty) ? null : _clearBlocks,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF381219),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _blocks.isEmpty
                          ? const Color(0xFF422026)
                          : const Color(0xFFFF4D6D).withValues(alpha: 0.7),
                    ),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: _blocks.isEmpty
                        ? const Color(0xFF75454E)
                        : const Color(0xFFFF5E7E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),

          // Area Tampilan Urutan Blok (Slot Bernomor saat kosong)
          SizedBox(
            height: 52,
            child: _blocks.isEmpty ? _emptyStepSlots() : _activeBlockList(),
          ),
          const SizedBox(height: 6),

          // Baris Status Langkah & Informasi
          _rpgStatusLine(),
        ],
      ),
    );
  }

  /// Tampilan 8 slot lingkaran bernomor (1..8) saat blok belum ditambahkan.
  Widget _emptyStepSlots() {
    final int max = _level.maxBlocks;
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List<Widget>.generate(max, (int i) {
                return Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF263D52),
                      style: BorderStyle.solid,
                      width: 1.1,
                    ),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(
                      color: Color(0xFF5A758E),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 3),
            Text(
              _en
                  ? 'Tap a command below to add a block\u2026'
                  : 'Ketuk perintah di bawah untuk menambahkan blok\u2026',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: _kMuted, fontSize: 10.5),
            ),
          ],
        );
      },
    );
  }

  /// Daftar blok yang tersusun dalam scroll horizontal.
  Widget _activeBlockList() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List<Widget>.generate(_blocks.length, (int i) {
          return Padding(
            padding: const EdgeInsets.only(right: 7),
            child: _rpgBlockPill(i),
          );
        }),
      ),
    );
  }

  Widget _rpgBlockPill(int index) {
    final CommandBlock block = _blocks[index];
    final Color color = _commandColor(block.command);

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        border: Border.all(color: color.withValues(alpha: 0.8), width: 1.3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // Nomor Langkah Urutan
          Container(
            width: 17,
            height: 17,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: color,
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 5),

          // Ikon & Teks Perintah (kompatibel penuh dengan pengujian pill text)
          _rpgCommandIcon(block.command, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            block.count > 1
                ? '${block.command.pill(_en)}  \u00D7${block.count}'
                : block.command.pill(_en),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 5),

          // Tombol Kurang (-)
          GestureDetector(
            onTap: () => _decBlock(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.remove_circle_outline,
                size: 15,
                color: _kMuted,
              ),
            ),
          ),
          // Tombol Hapus (x)
          GestureDetector(
            onTap: () => _removeBlock(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              child: const Icon(
                Icons.close_rounded,
                size: 15,
                color: _kMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rpgStatusLine() {
    final StepOutcome? last = _engine.last;
    final bool warn = last == StepOutcome.blocked || last == StepOutcome.missed;
    return Container(
      padding: const EdgeInsets.only(top: 4),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFF162534), width: 1)),
      ),
      child: Row(
        children: <Widget>[
          Icon(
            warn ? Icons.warning_amber_rounded : Icons.explore_outlined,
            size: 15,
            color: warn ? _kOrange : _kCyan,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: warn ? _kOrange : const Color(0xFFB0C4D5),
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            _en ? 'Steps ${_engine.steps}' : 'Langkah ${_engine.steps}',
            style: const TextStyle(
              color: _kGold,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String get _statusText {
    switch (_engine.last) {
      case StepOutcome.moved:
        return _en ? 'Moving forward.' : 'Maju satu langkah.';
      case StepOutcome.turned:
        return _en ? 'Turning.' : 'Berputar arah.';
      case StepOutcome.hit:
        return _en ? 'Hit! Monster HP -1.' : 'Serang! HP monster -1.';
      case StepOutcome.missed:
        return _en
            ? 'Missed! Face the monster first.'
            : 'Meleset! Hadapkan ke monster dulu.';
      case StepOutcome.blocked:
        return _en ? 'Blocked by a wall!' : 'Terhalang dinding!';
      case null:
        return _en
            ? 'Arrange blocks, then press RUN CODE.'
            : 'Susun blok, lalu tekan JALANKAN.';
    }
  }

  // ==========================================================
  // 5. PALET TOMBOL PERINTAH
  // ==========================================================
  Widget _commandsPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // Label Header Kecil Bergaya RPG
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 5),
          child: Text(
            _en ? 'AVAILABLE COMMANDS' : 'PERINTAH TERSEDIA',
            style: const TextStyle(
              color: _kGold,
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(child: _commandButton(GameCommand.forward)),
            const SizedBox(width: 8),
            Expanded(child: _commandButton(GameCommand.turnRight)),
            const SizedBox(width: 8),
            Expanded(child: _commandButton(GameCommand.turnLeft)),
            const SizedBox(width: 8),
            Expanded(child: _commandButton(GameCommand.attack)),
          ],
        ),
      ],
    );
  }

  Widget _commandButton(GameCommand command) {
    final Color color = _commandColor(command);
    final bool enabled = !_running && _blocks.length < _level.maxBlocks;

    // Gradien khusus per aksi RPG
    List<Color> gradientColors;
    switch (command) {
      case GameCommand.forward:
        gradientColors = enabled
            ? const <Color>[Color(0xFF0F3252), Color(0xFF0A1C2C)]
            : const <Color>[Color(0xFF0B1723), Color(0xFF081017)];
        break;
      case GameCommand.turnRight:
      case GameCommand.turnLeft:
        gradientColors = enabled
            ? const <Color>[Color(0xFF3D2A08), Color(0xFF221603)]
            : const <Color>[Color(0xFF191307), Color(0xFF100B03)];
        break;
      case GameCommand.attack:
        gradientColors = enabled
            ? const <Color>[Color(0xFF451419), Color(0xFF270A0D)]
            : const <Color>[Color(0xFF1A0A0C), Color(0xFF110507)];
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey<String>('cmd_${command.name}'),
        onTap: enabled ? () => _addBlock(command) : null,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: gradientColors,
            ),
            border: Border.all(
              color: enabled
                  ? color.withValues(alpha: 0.85)
                  : color.withValues(alpha: 0.25),
              width: 1.3,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: enabled
                ? <BoxShadow>[
                    BoxShadow(
                      color: color.withValues(alpha: 0.22),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : <BoxShadow>[],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Ikon Perintah
              _rpgCommandIcon(
                command,
                size: 20,
                color: enabled ? color : color.withValues(alpha: 0.4),
              ),
              const SizedBox(height: 3),

              // Label Nama Perintah
              Text(
                command.pill(_en),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: enabled ? color : color.withValues(alpha: 0.4),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // 6. TOMBOL AKSI (RESET & JALANKAN)
  // ==========================================================
  Widget _runButtons() {
    return Row(
      children: <Widget>[
        // Tombol Reset Urutan
        Expanded(
          flex: 1,
          child: InkWell(
            onTap: (_running || _blocks.isEmpty) ? null : _clearBlocks,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: <Color>[Color(0xFF132332), Color(0xFF0C1721)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: (_running || _blocks.isEmpty)
                      ? const Color(0xFF1C2B38)
                      : const Color(0xFF2E4B65),
                  width: 1.3,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.replay_rounded,
                    size: 19,
                    color: (_running || _blocks.isEmpty)
                        ? const Color(0xFF4A6072)
                        : _kCyan,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _en ? 'Reset' : 'Reset',
                    style: TextStyle(
                      color: (_running || _blocks.isEmpty)
                          ? const Color(0xFF4A6072)
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Tombol Utama JALANKAN (Sayap Emas Fantasy RPG)
        Expanded(
          flex: 2,
          child: _rpgRunButton(),
        ),
      ],
    );
  }

  Widget _rpgRunButton() {
    return SizedBox(
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: <Widget>[
          // Sayap / Ornamen Emas di Sisi Kiri & Kanan
          if (!_running)
            const Positioned.fill(
              child: CustomPaint(
                painter: _RpgButtonWingsPainter(color: Color(0xFFFFB21A)),
              ),
            ),

          // Tombol Inti
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _running
                      ? const <Color>[Color(0xFF283642), Color(0xFF1B2630)]
                      : const <Color>[Color(0xFFFF9E0B), Color(0xFFFF5200)],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _running
                      ? const Color(0xFF3E4F5E)
                      : const Color(0xFFFFDE7A),
                  width: 1.6,
                ),
                boxShadow: _running
                    ? <BoxShadow>[]
                    : <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFFFF6A00).withValues(alpha: 0.55),
                          blurRadius: 16,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _running ? null : _run,
                  borderRadius: BorderRadius.circular(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _running
                            ? Icons.hourglass_top_rounded
                            : Icons.play_arrow_rounded,
                        color: _running ? const Color(0xFF8CA0B3) : Colors.black,
                        size: 22,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _running
                            ? (_en ? 'RUNNING\u2026' : 'MENJALANKAN\u2026')
                            : (_en ? 'RUN CODE' : 'JALANKAN'),
                        style: TextStyle(
                          color:
                              _running ? const Color(0xFF8CA0B3) : Colors.black,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // DIALOG KEMENANGAN (POPUP RPG)
  // ==========================================================
  Widget _victoryDialog(BuildContext ctx, int stars) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF132537), Color(0xFF0C1722)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _kBorderGold, width: 1.8),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 24,
            ),
            BoxShadow(
              color: _kBorderGold.withValues(alpha: 0.25),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Piala / Bintang Kemenangan Emas
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF2C2411),
                shape: BoxShape.circle,
                border: Border.all(color: _kGold, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _kGold.withValues(alpha: 0.45),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: _kGold,
                size: 38,
              ),
            ),
            const SizedBox(height: 14),

            Text(
              _en ? 'MONSTER DEFEATED!' : 'MONSTER DIKALAHKAN!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _level.monsterName(_en),
              style: const TextStyle(color: _kMuted, fontSize: 13),
            ),
            const SizedBox(height: 16),

            // 3 Bintang Emas Berkilau
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                3,
                (int i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Icon(
                    i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                    color: i < stars ? _kGold : const Color(0xFF334155),
                    size: 38,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Perbandingan Langkah & Par
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _statPill(_en ? 'Steps' : 'Langkah', '${_engine.steps}'),
                const SizedBox(width: 10),
                _statPill('Par', '${_level.par}'),
              ],
            ),
            const SizedBox(height: 22),

            // Tombol Ulangi & Lanjut
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Juice.click();
                      Navigator.of(ctx).pop(false);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kText,
                      side: const BorderSide(color: Color(0xFF2E465D)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_en ? 'Retry' : 'Ulangi'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Juice.click();
                      Navigator.of(ctx).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9E0B),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                    ),
                    child: Text(
                      _en ? 'Next \u25B8' : 'Lanjut \u25B8',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E2C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF243E56)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: const TextStyle(color: _kMuted, fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // HELPER DEKORASI & IKON RPG
  // ==========================================================
  BoxDecoration _rpgPanelDecoration({bool goldBorder = false}) {
    return BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[Color(0xFF0F202F), Color(0xFF0A1521)],
      ),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: goldBorder ? _kBorderGold : _kBorderBlue,
        width: 1.4,
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  Color _commandColor(GameCommand command) {
    switch (command) {
      case GameCommand.forward:
        return _kCyan;
      case GameCommand.turnRight:
      case GameCommand.turnLeft:
        return _kGold;
      case GameCommand.attack:
        return const Color(0xFFFF5252);
    }
  }

  Widget _rpgCommandIcon(
    GameCommand command, {
    required double size,
    required Color color,
  }) {
    switch (command) {
      case GameCommand.forward:
        return Icon(Icons.arrow_upward_rounded, size: size, color: color);
      case GameCommand.turnRight:
        return Icon(Icons.turn_right_rounded, size: size, color: color);
      case GameCommand.turnLeft:
        return Icon(Icons.turn_left_rounded, size: size, color: color);
      case GameCommand.attack:
        return _RpgSwordIcon(size: size, color: color);
    }
  }
}

// ============================================================
// IKON PEDANG RPG SERANG (Custom Vector Painter)
// ============================================================
class _RpgSwordIcon extends StatelessWidget {
  final double size;
  final Color color;

  const _RpgSwordIcon({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _SwordPainter(color: color)),
    );
  }
}

class _SwordPainter extends CustomPainter {
  final Color color;

  _SwordPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Paint bladePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final Paint hiltPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.12
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Bilah pedang diagonal
    final Path blade = Path()
      ..moveTo(s * 0.88, s * 0.12) // Ujung pedang
      ..lineTo(s * 0.58, s * 0.22)
      ..lineTo(s * 0.38, s * 0.58)
      ..lineTo(s * 0.46, s * 0.66)
      ..lineTo(s * 0.82, s * 0.46)
      ..close();
    canvas.drawPath(blade, bladePaint);

    // Gagang pelindung silang (Crossguard)
    canvas.drawLine(
      Offset(s * 0.22, s * 0.64),
      Offset(s * 0.44, s * 0.86),
      hiltPaint,
    );

    // Pegangan (Hilt)
    canvas.drawLine(
      Offset(s * 0.33, s * 0.75),
      Offset(s * 0.14, s * 0.94),
      hiltPaint..strokeWidth = s * 0.14,
    );
  }

  @override
  bool shouldRepaint(covariant _SwordPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ============================================================
// SAYAP ORNAMEN TOMBOL JALANKAN RPG
// ============================================================
class _RpgButtonWingsPainter extends CustomPainter {
  final Color color;

  const _RpgButtonWingsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final double h = size.height;
    final double w = size.width;
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // Sayap lancip kiri
    final Path leftWing = Path()
      ..moveTo(10, h * 0.25)
      ..lineTo(0, h * 0.50)
      ..lineTo(10, h * 0.75)
      ..close();
    canvas.drawPath(leftWing, paint);

    // Sayap lancip kanan
    final Path rightWing = Path()
      ..moveTo(w - 10, h * 0.25)
      ..lineTo(w, h * 0.50)
      ..lineTo(w - 10, h * 0.75)
      ..close();
    canvas.drawPath(rightWing, paint);
  }

  @override
  bool shouldRepaint(covariant _RpgButtonWingsPainter oldDelegate) => false;
}

// ============================================================
// HIASAN RAMBATAN DAUN / FOLIAGE (Dungeon Atmosphere)
// ============================================================
class _RpgFoliagePainter extends CustomPainter {
  const _RpgFoliagePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final Paint leafDark = Paint()..color = const Color(0x330B1C16);
    final Paint leafMid = Paint()..color = const Color(0x4D0E291F);

    // Daun di sudut kiri bawah
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(10, h - 15),
        width: 70,
        height: 45,
      ),
      leafDark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(35, h - 35),
        width: 55,
        height: 35,
      ),
      leafMid,
    );

    // Daun di sudut kanan bawah
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w - 10, h - 15),
        width: 70,
        height: 45,
      ),
      leafDark,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w - 35, h - 35),
        width: 55,
        height: 35,
      ),
      leafMid,
    );
  }

  @override
  bool shouldRepaint(covariant _RpgFoliagePainter oldDelegate) => false;
}

// ============================================================
// EFEK TEBASAN PEDANG SAAT MENYERANG
// ============================================================
class _SlashPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;
    final Path path = Path()
      ..moveTo(s * 0.12, s * 0.2)
      ..lineTo(s * 0.88, s * 0.8)
      ..moveTo(s * 0.3, s * 0.1)
      ..lineTo(s * 0.96, s * 0.6);

    final Paint glow = Paint()
      ..color = const Color(0xFFFF7A29).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.24
      ..strokeCap = StrokeCap.round;
    final Paint core = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.10
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, glow);
    canvas.drawPath(path, core);
  }

  @override
  bool shouldRepaint(covariant _SlashPainter oldDelegate) => false;
}
