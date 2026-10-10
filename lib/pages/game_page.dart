import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../services/juice.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_token.dart';
import '../widgets/monster_token.dart';
import 'map_page.dart';

// ============================================================
// GAME PAGE â€” INTI PERMAINAN (LABIRIN + MONSTER)
// ============================================================
// Alur permainan:
//   1. Karakter berada di dalam labirin.
//   2. Pemain menyusun blok perintah (Maju / Belok / Serang).
//   3. Tekan JALANKAN (RUN CODE) -> karakter bergerak.
//   4. Kalahkan monster -> lanjut menjawab soal (tahap berikutnya).

// ---------- Palet warna ----------
const Color _kBg = Color(0xFF0B100F);
const Color _kCard = Color(0xFF141A19);
const Color _kCardSoft = Color(0xFF1B2321);
const Color _kLine = Color(0xFF2A3432);
const Color _kCyan = Color(0xFF42CFFF);
const Color _kYellow = Color(0xFFFFB21A);
const Color _kOrange = Color(0xFFFF7A45);
const Color _kPink = Color(0xFFFF5E7E);
const Color _kGreen = Color(0xFF59C36A);
const Color _kRed = Color(0xFFB02A32);
const Color _kText = Color(0xFFDDE7E9);
const Color _kMuted = Color(0xFF8A9795);

class GamePage extends StatefulWidget {
  final int region;
  final int level;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onBack;

  /// Dipanggil setelah pemain menekan "Kembali ke Peta".
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

    // Pratinjau: tempatkan karakter di depan monster dan bekukan
    // animasi serangan pada satu frame tertentu.
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
  // Aksi
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
        // Animasi menyerang monster.
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
    if (stars >
        MapProgress.starsOf(widget.region, widget.level, GameMode.logic)) {
      MapProgress.setStars(widget.region, widget.level, GameMode.logic, stars);
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
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) => _soalDialog(ctx),
      );
      if (!mounted) return;
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
          backgroundColor: _kCardSoft,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // ----------------------------------------------------------
  // Build
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AppHeader(
              title: 'Quest',
              isEnglish: _en,
              onLanguageChanged: widget.onLanguageChanged,
              onBack: widget.onBack,
            ),
            Expanded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _levelBanner(),
                        const SizedBox(height: 10),
                        Expanded(child: _mazeArena()),
                        const SizedBox(height: 10),
                        _logicSequence(),
                        const SizedBox(height: 10),
                        _commandsPalette(),
                        const SizedBox(height: 10),
                        _runButtons(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Banner level + HP monster ----------
  Widget _levelBanner() {
    final GameRegion region = gameRegions[widget.region.clamp(0, 4)];
    final int stars = MapProgress.starsOf(
      widget.region,
      widget.level,
      GameMode.logic,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: region.color.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: region.color.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(region.icon, color: region.color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      '${_en ? 'REGION' : 'WILAYAH'} ${widget.region + 1}'
                      '  \u00B7  ${_en ? 'LEVEL' : 'LEVEL'} ${widget.level + 1}',
                      style: TextStyle(
                        color: region.color,
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      region.name(_en),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _kText,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _starsRow(stars),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              const Icon(Icons.pest_control, color: _kPink, size: 15),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _level.monsterName(_en),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _kText,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'HP ${_engine.enemyHp}/${_level.enemyHp}',
                style: const TextStyle(
                  color: _kPink,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: _level.enemyHp == 0 ? 0 : _engine.enemyHp / _level.enemyHp,
              minHeight: 9,
              backgroundColor: _kCardSoft,
              valueColor: const AlwaysStoppedAnimation<Color>(_kPink),
            ),
          ),
        ],
      ),
    );
  }

  Widget _starsRow(int stars) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(
        3,
        (int i) => Icon(
          i < stars ? Icons.star_rounded : Icons.star_border_rounded,
          color: i < stars ? _kYellow : _kLine,
          size: 18,
        ),
      ),
    );
  }

  // ---------- Arena labirin ----------
  Widget _mazeArena() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double side = math.min(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: _cardDecoration(),
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
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _MazePainter(level: _level),
                            ),
                          ),
                          // Efek serangan: tebasan + angka damage.
                          _attackEffect(cell, t),
                          _token(
                            key: const ValueKey<String>('monster'),
                            cell: cell,
                            row: _level.monster.row,
                            col: _level.monster.col,
                            child: Transform.translate(
                              offset: _shakeOffset(cell, t),
                              child: _monsterToken(cell * 0.9, t),
                            ),
                          ),
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

  // ---- Animasi serangan ----

  /// Karakter menerjang ke arah monster lalu kembali.
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

  /// Monster terguncang saat terkena serangan.
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

  /// Angka damage dengan garis tepi gelap agar terbaca di mana saja.
  Widget _damageNumber(String value) {
    final TextStyle stroke = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..color = const Color(0xFF101414),
    );
    const TextStyle fill = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w900,
      color: _kYellow,
    );
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text('-$value', textAlign: TextAlign.center, style: stroke),
        Text('-$value', textAlign: TextAlign.center, style: fill),
      ],
    );
  }

  /// Karakter pemain (bentuk orang, bukan kursor) + penunjuk arah hadap.
  /// Memakai widget bersama [HeroToken] agar konsisten dengan Mode
  /// Petualangan.
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
                      color: (flash > 0 ? Colors.white : _kPink).withValues(
                        alpha: flash > 0 ? 0.7 : 0.4,
                      ),
                      blurRadius: flash > 0 ? 20 : 12,
                    ),
                  ],
          ),
          child: MonsterToken(
            size: size,
            flash: flash,
            defeated: dead,
            tint: _kRed,
          ),
        ),
      ),
    );
  }

  // ---------- Urutan logika (blok pemain) ----------
  Widget _logicSequence() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.account_tree_outlined, color: _kCyan, size: 18),
              const SizedBox(width: 8),
              Text(
                _en ? 'LOGIC SEQUENCE' : 'URUTAN LOGIKA',
                style: const TextStyle(
                  color: _kText,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kCardSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_blocks.length}/${_level.maxBlocks}',
                  style: const TextStyle(
                    color: _kMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: (_running || _blocks.isEmpty) ? null : _clearBlocks,
                icon: const Icon(Icons.delete_outline, size: 18),
                color: _kMuted,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                tooltip: _en ? 'Clear' : 'Hapus',
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 60,
            child: _blocks.isEmpty
                ? _dropZone()
                : SingleChildScrollView(child: _blockList()),
          ),
          const SizedBox(height: 8),
          _statusLine(),
        ],
      ),
    );
  }

  Widget _dropZone() {
    return CustomPaint(
      painter: _DashedBorderPainter(color: _kLine, radius: 12, dash: 6, gap: 5),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        alignment: Alignment.center,
        child: Text(
          _en
              ? 'Tap a command below to add a block\u2026'
              : 'Ketuk perintah di bawah untuk menambah blok\u2026',
          textAlign: TextAlign.center,
          style: const TextStyle(color: _kMuted, fontSize: 12.5),
        ),
      ),
    );
  }

  Widget _blockList() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List<Widget>.generate(_blocks.length, (int i) => _blockPill(i)),
    );
  }

  Widget _blockPill(int index) {
    final CommandBlock block = _blocks[index];
    final Color color = _commandColor(block.command);
    return Container(
      padding: const EdgeInsets.fromLTRB(9, 5, 4, 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(_commandIcon(block.command), size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            block.count > 1
                ? '${block.command.pill(_en)}  \u00D7${block.count}'
                : block.command.pill(_en),
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => _decBlock(index),
            child: const Icon(
              Icons.remove_circle_outline,
              size: 16,
              color: _kMuted,
            ),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: () => _removeBlock(index),
            child: const Icon(Icons.close_rounded, size: 15, color: _kMuted),
          ),
        ],
      ),
    );
  }

  Widget _statusLine() {
    final StepOutcome? last = _engine.last;
    final bool warn = last == StepOutcome.blocked || last == StepOutcome.missed;
    return Row(
      children: <Widget>[
        Icon(
          warn ? Icons.warning_amber_rounded : Icons.terminal_rounded,
          size: 15,
          color: warn ? _kOrange : _kMuted,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            _statusText,
            style: TextStyle(color: warn ? _kOrange : _kMuted, fontSize: 12.5),
          ),
        ),
        Text(
          _en ? 'Steps ${_engine.steps}' : 'Langkah ${_engine.steps}',
          style: const TextStyle(
            color: _kMuted,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String get _statusText {
    switch (_engine.last) {
      case StepOutcome.moved:
        return _en ? 'Moving forward.' : 'Maju satu langkah.';
      case StepOutcome.turned:
        return _en ? 'Turning.' : 'Berputar.';
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

  // ---------- Perintah tersedia ----------
  Widget _commandsPalette() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _en ? 'AVAILABLE COMMANDS' : 'PERINTAH TERSEDIA',
          style: const TextStyle(
            color: _kMuted,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
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
    return InkWell(
      key: ValueKey<String>('cmd_${command.name}'),
      onTap: enabled ? () => _addBlock(command) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: enabled ? 0.16 : 0.06),
          border: Border.all(
            color: color.withValues(alpha: enabled ? 0.7 : 0.25),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: <Widget>[
            Icon(
              _commandIcon(command),
              color: enabled ? color : color.withValues(alpha: 0.4),
              size: 20,
            ),
            const SizedBox(height: 4),
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
    );
  }

  // ---------- Tombol jalankan ----------
  Widget _runButtons() {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton.icon(
            onPressed: (_running || _blocks.isEmpty) ? null : _clearBlocks,
            icon: const Icon(Icons.delete_sweep_outlined, size: 20),
            label: Text(_en ? 'Clear' : 'Hapus'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _kMuted,
              side: const BorderSide(color: _kLine),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _running
                    ? const <Color>[Color(0xFF3A4442), Color(0xFF3A4442)]
                    : const <Color>[_kOrange, _kYellow],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: _running
                  ? const <BoxShadow>[]
                  : <BoxShadow>[
                      BoxShadow(
                        color: _kOrange.withValues(alpha: 0.4),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _running ? null : _run,
                borderRadius: BorderRadius.circular(14),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        _running
                            ? Icons.hourglass_top_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _running
                            ? (_en ? 'RUNNING\u2026' : 'MENJALANKAN\u2026')
                            : (_en ? 'RUN CODE' : 'JALANKAN'),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------- Dialog ----------
  Widget _victoryDialog(BuildContext ctx, int stars) {
    return Dialog(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _kGreen.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: _kGreen,
                size: 34,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _en ? 'MONSTER DEFEATED!' : 'MONSTER DIKALAHKAN!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _level.monsterName(_en),
              style: const TextStyle(color: _kMuted, fontSize: 13),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                3,
                (int i) => Icon(
                  i < stars ? Icons.star_rounded : Icons.star_border_rounded,
                  color: i < stars ? _kYellow : _kLine,
                  size: 38,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _statPill(_en ? 'Steps' : 'Langkah', '${_engine.steps}'),
                const SizedBox(width: 8),
                _statPill('Par', '${_level.par}'),
              ],
            ),
            const SizedBox(height: 20),
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
                      side: const BorderSide(color: _kLine),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(_en ? 'Retry' : 'Ulangi'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Juice.click();
                      Navigator.of(ctx).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kOrange,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _en ? 'Next \u25B8' : 'Lanjut \u25B8',
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
  }

  Widget _soalDialog(BuildContext ctx) {
    return Dialog(
      backgroundColor: _kCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _kCyan.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.quiz_rounded, color: _kCyan, size: 34),
            ),
            const SizedBox(height: 14),
            Text(
              _en ? 'QUESTION' : 'SOAL',
              style: const TextStyle(
                color: _kText,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _en
                  ? 'The monster is defeated. The question for this level will be available in the next update.'
                  : 'Monster sudah dikalahkan. Soal untuk level ini akan hadir di pembaruan berikutnya.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _kMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kCyan,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _en ? 'Back to Map' : 'Kembali ke Peta',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statPill(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kCardSoft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: const TextStyle(color: _kMuted, fontSize: 12)),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              color: _kText,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Helper ----------
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: _kCard,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _kLine),
    );
  }

  Color _commandColor(GameCommand command) {
    switch (command) {
      case GameCommand.forward:
        return _kCyan;
      case GameCommand.turnRight:
      case GameCommand.turnLeft:
        return _kYellow;
      case GameCommand.attack:
        return _kOrange;
    }
  }

  IconData _commandIcon(GameCommand command) {
    switch (command) {
      case GameCommand.forward:
        return Icons.arrow_upward_rounded;
      case GameCommand.turnRight:
        return Icons.turn_right_rounded;
      case GameCommand.turnLeft:
        return Icons.turn_left_rounded;
      case GameCommand.attack:
        return Icons.local_fire_department_rounded;
    }
  }
}

/// Efek tebasan saat menyerang.
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
      ..color = _kOrange.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.22
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

// ============================================================
// PELUKIS LABIRIN
// ============================================================
class _MazePainter extends CustomPainter {
  final MazeLevel level;

  _MazePainter({required this.level});

  @override
  void paint(Canvas canvas, Size size) {
    final double cell = size.width / level.size;

    final Paint floor = Paint()..color = const Color(0xFF0E1615);
    final Paint floorAlt = Paint()..color = const Color(0xFF0A100F);
    final Paint wall = Paint()..color = const Color(0xFF27312F);
    final Paint wallTop = Paint()
      ..color = const Color(0xFF3D4B47)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final Paint wallShadow = Paint()
      ..color = const Color(0xFF141B19)
      ..strokeWidth = 2;
    final Paint wallEdge = Paint()
      ..color = const Color(0xFF33403D)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.save();
    canvas.clipRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
    );

    for (var r = 0; r < level.size; r++) {
      for (var c = 0; c < level.size; c++) {
        final Rect rect = Rect.fromLTWH(c * cell, r * cell, cell, cell);
        // Lantai papan catur halus supaya ada tekstur.
        canvas.drawRect(rect, (r + c) % 2 == 0 ? floor : floorAlt);
        canvas.drawRect(rect, grid);
        if (level.walls[r][c]) {
          final Rect wr = rect.deflate(cell * 0.05);
          final RRect rr = RRect.fromRectAndRadius(
            wr,
            Radius.circular(cell * 0.2),
          );
          canvas.drawRRect(rr, wall);
          canvas.drawRRect(rr, wallEdge);
          // Sisi atas terang & sisi bawah gelap → kesan dinding bertebal.
          canvas.drawLine(
            Offset(wr.left + cell * 0.2, wr.top + 1.5),
            Offset(wr.right - cell * 0.2, wr.top + 1.5),
            wallTop,
          );
          canvas.drawLine(
            Offset(wr.left + cell * 0.2, wr.bottom - 1.5),
            Offset(wr.right - cell * 0.2, wr.bottom - 1.5),
            wallShadow,
          );
        }
      }
    }
    canvas.restore();

    // Bingkai luar arena.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)),
      Paint()
        ..color = const Color(0xFF243230).withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant _MazePainter oldDelegate) =>
      oldDelegate.level != level;
}

// ============================================================
// GARIS PUTUS-PUTUS (drop zone)
// ============================================================
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dash;
  final double gap;

  const _DashedBorderPainter({
    required this.color,
    this.radius = 10,
    this.dash = 6,
    this.gap = 5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.radius != radius ||
      oldDelegate.dash != dash ||
      oldDelegate.gap != gap;
}
