import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../services/game_service.dart';
import '../widgets/app_header.dart';
import 'map_page.dart';

// ============================================================
// GAME PAGE — INTI PERMAINAN
// ============================================================
// Halaman tempat pemain memakai logika pemrograman untuk
// menyelesaikan tantangan. Terdiri dari:
//   1. Arena permainan (grid + karakter/boss) + bar HP
//   2. Blok perintah yang tersedia (drag & drop / ketuk)
//   3. Area penyusunan alur kode (Execution Sequence)
//   4. Indikator status: HP, kuota blok, energi, nilai
//   5. Tombol EKSEKUSI / RUN CODE

class GamePage extends StatefulWidget {
  final int region;
  final int level;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onBack;

  /// Dipanggil setelah pemain memilih "Kembali ke Peta".
  final void Function(int stars)? onFinished;

  const GamePage({
    super.key,
    required this.region,
    required this.level,
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onBack,
    this.onFinished,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final LevelDefinition _level;
  late final GameEngine _engine;

  /// Susunan blok milik pemain (berlaku lintas percobaan).
  final List<ScriptBlock> _script = <ScriptBlock>[];
  final ScrollController _logCtrl = ScrollController();

  bool _running = false;
  bool _showTip = false;
  int _energy = 5;
  GameStep? _lastStep;

  bool get _en => widget.isEnglish;

  int get _used => countBlocks(_script);

  // ----------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _level = kLevels[widget.region * 3 + widget.level];
    _engine = GameEngine(_level);
    _engine.start(_script);
    _engine.log
      ..clear()
      ..add(_en ? '> Ready. Arrange blocks then press RUN.' : '> Siap. Susun blok lalu tekan EKSEKUSI.');
  }

  @override
  void dispose() {
    _logCtrl.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // BANTU
  // ----------------------------------------------------------
  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF164653),
          content: Text(msg),
        ),
      );
  }

  void _scrollLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_logCtrl.hasClients) return;
      _logCtrl.animateTo(
        _logCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    });
  }

  // ----------------------------------------------------------
  // AKSI BLOK
  // ----------------------------------------------------------
  void _addBlock(BlockKind kind, List<ScriptBlock> target) {
    if (_running) return;
    if (_used >= _level.maxBlocks) {
      _snack(
        _en
            ? 'Block quota full ($_used/${_level.maxBlocks}).'
            : 'Kuota blok penuh ($_used/${_level.maxBlocks}).',
      );
      return;
    }
    setState(() => target.add(ScriptBlock(kind)));
  }

  void _removeBlock(List<ScriptBlock> target, ScriptBlock block) {
    if (_running) return;
    setState(() => target.remove(block));
  }

  void _moveBlock(List<ScriptBlock> target, int index, int delta) {
    if (_running) return;
    final int to = index + delta;
    if (to < 0 || to >= target.length) return;
    setState(() {
      final ScriptBlock b = target.removeAt(index);
      target.insert(to, b);
    });
  }

  void _resetBoard() {
    if (_running) return;
    setState(() {
      _engine.start(_script);
      _engine.log
        ..clear()
        ..add(_en ? '> Board reset.' : '> Papan diatur ulang.');
      _lastStep = null;
    });
  }

  void _clearScript() {
    if (_running) return;
    setState(() {
      _script.clear();
      _engine.start(_script);
      _engine.log
        ..clear()
        ..add(_en ? '> Blocks cleared.' : '> Blok dibersihkan.');
      _lastStep = null;
    });
  }

  // ----------------------------------------------------------
  // PILIH BLOK (untuk zona dalam / layar kecil)
  // ----------------------------------------------------------
  Future<void> _pickBlock(List<ScriptBlock> target) async {
    if (_running) return;

    final BlockKind? picked = await showModalBottomSheet<BlockKind>(
      context: context,
      backgroundColor: const Color(0xFF202524),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _en ? 'Choose a command' : 'Pilih Blok Perintah',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_used / ${_level.maxBlocks} ${_en ? 'blocks used' : 'blok terpakai'}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final BlockKind k in _level.palette)
                      _chipBody(
                        kBlockTypes[k]!,
                        onTap: () => Navigator.of(ctx).pop(k),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || picked == null) return;
    _addBlock(picked, target);
  }

  // ----------------------------------------------------------
  // EKSEKUSI
  // ----------------------------------------------------------
  Future<void> _runCode() async {
    if (_running) return;

    if (_script.isEmpty) {
      _snack(
        _en
            ? 'Arrange at least one block first.'
            : 'Susun minimal satu blok dulu.',
      );
      return;
    }

    if (_energy <= 0) {
      await _refillEnergy();
      return;
    }

    setState(() {
      _running = true;
      _energy--;
      _lastStep = null;
    });

    _engine.start(_script);
    setState(() {});
    _scrollLog();

    while (mounted && !_engine.finished) {
      final GameStep? step = _engine.nextStep();
      if (step == null) break;
      setState(() => _lastStep = step);
      _scrollLog();
      await Future<void>.delayed(const Duration(milliseconds: 520));
    }

    if (!mounted) return;
    setState(() => _running = false);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _lastStep = null);
    await _showResult();
  }

  Future<void> _refillEnergy() async {
    final bool refill =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext ctx) => AlertDialog(
            backgroundColor: const Color(0xFF202524),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Text(
              _en ? 'Energy empty' : 'Energi habis',
              style: const TextStyle(color: Colors.white, fontSize: 17),
            ),
            content: Text(
              _en
                  ? 'You have used every execution attempt. Refill for free?'
                  : 'Kamu sudah memakai semua percobaan eksekusi. Isi ulang gratis?',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(
                  'Nanti',
                  style: TextStyle(color: Colors.white60),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB21A),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Isi Ulang'),
              ),
            ],
          ),
        ) ??
        false;

    if (!mounted || !refill) return;
    setState(() => _energy = 5);
  }

  // ----------------------------------------------------------
  // HASIL AKHIR
  // ----------------------------------------------------------
  Future<void> _showResult() async {
    final bool won = _engine.won;
    int stars = 0;

    if (won) {
      final int used = _used;
      if (used <= _level.par) {
        stars = 3;
      } else if (used <= _level.par + 2) {
        stars = 2;
      } else {
        stars = 1;
      }
      if (stars > MapProgress.starsOf(widget.region, widget.level)) {
        MapProgress.setStars(widget.region, widget.level, stars);
      }
    }

    if (!mounted) return;

    final String? action = await showDialog<String>(
      context: context,
      builder: (BuildContext ctx) {
        final Color tone = won
            ? const Color(0xFF59C36A)
            : const Color(0xFFFF6B4A);

        return AlertDialog(
          backgroundColor: const Color(0xFF202524),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                won ? Icons.emoji_events : Icons.error_outline,
                color: tone,
                size: 46,
              ),
              const SizedBox(height: 10),
              Text(
                won
                    ? (_en ? 'Challenge cleared!' : 'Tantangan selesai!')
                    : (_en ? 'Not yet' : 'Belum berhasil'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _engine.resultNote,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12.5,
                  height: 1.4,
                ),
              ),
              if (won) ...[
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < 3; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Icon(
                          i < stars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: 34,
                          color: i < stars
                              ? const Color(0xFFFFC15C)
                              : Colors.white24,
                        ),
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              _resultRow(
                _en ? 'Blocks used' : 'Blok dipakai',
                '$_used / ${_level.maxBlocks}',
              ),
              _resultRow(_en ? 'Steps' : 'Langkah', '${_engine.steps}'),
              _resultRow(
                _en ? 'Energy left' : 'Sisa energi',
                '$_energy',
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop('again'),
              child: Text(
                _en ? 'Retry' : 'Ulangi',
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop('map'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42CFFF),
                foregroundColor: Colors.black,
              ),
              child: Text(
                _en ? 'Back to Map' : 'Kembali ke Peta',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || action == null) return;

    if (action == 'map') {
      widget.onFinished?.call(stars);
      return;
    }

    setState(() {
      _engine.start(_script);
      _engine.log
        ..clear()
        ..add(_en ? '> Ready. Try again.' : '> Siap. Coba lagi.');
      _lastStep = null;
    });
  }

  Widget _resultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF42CFFF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // BUILD
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101414),
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Quest',
              isEnglish: _en,
              onLanguageChanged: widget.onLanguageChanged,
              onBack: widget.onBack,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _objectiveCard(),
                    const SizedBox(height: 14),
                    _arenaCard(),
                    const SizedBox(height: 14),
                    _statusRow(),
                    const SizedBox(height: 14),
                    _paletteCard(),
                    const SizedBox(height: 14),
                    _scriptCard(),
                    const SizedBox(height: 14),
                    _consoleCard(),
                    const SizedBox(height: 16),
                    _runButton(),
                    const SizedBox(height: 10),
                    _resetRow(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // 1. KARTU TUJUAN + ATTACK STRATEGY
  // ----------------------------------------------------------
  Widget _objectiveCard() {
    final GameRegion r = gameRegions[widget.region];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF202524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: r.color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: r.color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(r.icon, color: r.color, size: 24),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level ${widget.level + 1} · ${_level.materi(_en)}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _level.goal(_en),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          InkWell(
            onTap: () => setState(() => _showTip = !_showTip),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF262116),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF725E2E)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    size: 16,
                    color: Color(0xFFFFC15C),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Attack Strategy',
                      style: TextStyle(
                        color: Color(0xFFFFC15C),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Icon(
                    _showTip ? Icons.expand_less : Icons.expand_more,
                    color: const Color(0xFFFFC15C),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          if (_showTip) ...[
            const SizedBox(height: 8),
            Text(
              _level.tip(_en),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // 2. AREA GAMEPLAY (ARENA + HP)
  // ----------------------------------------------------------
  Widget _arenaCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          if (_engine.hasEnemy) ...[
            _hpBar(
              label: _en ? 'Enemy' : 'Musuh',
              hp: _engine.enemyHp,
              max: _level.enemyHp,
              color: const Color(0xFFFF6B4A),
              icon: Icons.whatshot,
            ),
            const SizedBox(height: 10),
          ],
          _arenaGrid(),
          const SizedBox(height: 10),
          _hpBar(
            label: _en ? 'Character' : 'Karakter',
            hp: _engine.playerHp,
            max: 100,
            color: const Color(0xFF42CFFF),
            icon: Icons.favorite,
          ),
        ],
      ),
    );
  }

  Widget _hpBar({
    required String label,
    required int hp,
    required int max,
    required Color color,
    required IconData icon,
  }) {
    final double value = max <= 0 ? 0 : (hp / max).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const Spacer(),
            Text(
              'HP: $hp/$max',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOut,
            tween: Tween<double>(begin: 1, end: value),
            builder: (BuildContext ctx, double v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: const Color(0xFF2A302F),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }

  double _cellSize(double maxWidth) {
    double cell = (maxWidth - 6) / _engine.cols;
    const double maxArenaHeight = 224;
    if (cell * _engine.rows > maxArenaHeight) {
      cell = maxArenaHeight / _engine.rows;
    }
    return cell;
  }

  Widget _arenaGrid() {
    return LayoutBuilder(
      builder: (BuildContext ctx, BoxConstraints c) {
        final double cell = _cellSize(c.maxWidth - 24);
        final double w = cell * _engine.cols;
        final double h = cell * _engine.rows;

        final List<Widget> children = <Widget>[];

        // Ubin grid
        for (int y = 0; y < _engine.rows; y++) {
          for (int x = 0; x < _engine.cols; x++) {
            children.add(
              Positioned(
                left: x * cell,
                top: y * cell,
                child: _tile(x, y, cell),
              ),
            );
          }
        }

        // Kristal
        for (final int key in _engine.crystals) {
          final int cx = key % _engine.cols;
          final int cy = key ~/ _engine.cols;
          children.add(
            Positioned(
              left: cx * cell + 3,
              top: cy * cell + 3,
              child: SizedBox(
                width: cell - 6,
                height: cell - 6,
                child: Icon(
                  Icons.diamond,
                  size: cell * 0.45,
                  color: const Color(0xFF59C36A),
                ),
              ),
            ),
          );
        }

        // Musuh / boss
        if (_engine.enemyAlive && _engine.enemyX >= 0) {
          children.add(
            Positioned(
              left: _engine.enemyX * cell + 3,
              top: _engine.enemyY * cell + 3,
              child: _enemyToken(cell),
            ),
          );
        }

        // Karakter
        children.add(
          AnimatedPositioned(
            key: ValueKey<String>('p'),
            left: _engine.px * cell + 3,
            top: _engine.py * cell + 3,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: _playerToken(cell),
          ),
        );

        return Center(
          child: Container(
            width: w + 6,
            height: h + 6,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF0A0E0E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Stack(children: children),
          ),
        );
      },
    );
  }

  Widget _tile(int x, int y, double cell) {
    final bool isWall = _engine.wall[y][x];
    final bool isGoal = _engine.goal[y][x];

    Color fill = isWall ? const Color(0xFF242A29) : const Color(0xFF141918);
    if (isGoal) fill = const Color(0xFF3A3315);

    return Container(
      width: cell,
      height: cell,
      padding: const EdgeInsets.all(1.5),
      child: Container(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isWall ? Colors.white10 : Colors.white.withValues(alpha: 0.05),
          ),
        ),
        child: isGoal
            ? Icon(
                Icons.flag,
                size: cell * 0.42,
                color: const Color(0xFFFFC15C),
              )
            : null,
      ),
    );
  }

  Widget _enemyToken(double cell) {
    final bool hit = _lastStep?.attacked == true && _lastStep!.ok;

    return AnimatedScale(
      scale: hit ? 1.18 : 1.0,
      duration: const Duration(milliseconds: 180),
      child: Container(
        width: cell - 6,
        height: cell - 6,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hit ? const Color(0xFFFF3B1F) : const Color(0xFFB90016),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B4A).withValues(
                alpha: hit ? 0.85 : 0.3,
              ),
              blurRadius: hit ? 16 : 8,
            ),
          ],
        ),
        child: Icon(
          Icons.whatshot,
          size: cell * 0.46,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _playerToken(double cell) {
    final bool hurt = _lastStep?.hitPlayer == true;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: cell - 6,
      height: cell - 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: hurt ? const Color(0xFFFF6B4A) : const Color(0xFF42CFFF),
        boxShadow: [
          BoxShadow(
            color: (hurt ? const Color(0xFFFF6B4A) : const Color(0xFF42CFFF))
                .withValues(alpha: 0.45),
            blurRadius: 10,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: _engine.dir.angle,
        child: Icon(
          Icons.navigation,
          size: cell * 0.5,
          color: const Color(0xFF06282F),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // 3. INDIKATOR STATUS
  // ----------------------------------------------------------
  Widget _statusRow() {
    final int used = _used;
    final bool full = used >= _level.maxBlocks;
    final bool showValue = _level.targetValue > 0 ||
        _level.palette.contains(BlockKind.addValue) ||
        _level.palette.contains(BlockKind.ifValue);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _statChip(
          icon: Icons.widgets_outlined,
          caption: _en ? 'Blocks' : 'Blok',
          label: '$used / ${_level.maxBlocks}',
          color: full
              ? const Color(0xFFFF6B4A)
              : const Color(0xFF42CFFF),
        ),
        _statChip(
          icon: Icons.bolt,
          caption: _en ? 'Energy' : 'Energi',
          label: '$_energy',
          color: _energy <= 1
              ? const Color(0xFFFF6B4A)
              : const Color(0xFFFFC15C),
        ),
        _statChip(
          icon: Icons.directions_walk,
          caption: _en ? 'Steps' : 'Langkah',
          label: '${_engine.steps}',
          color: const Color(0xFF8DE7F5),
        ),
        if (showValue)
          _statChip(
            icon: Icons.data_object,
            caption: _en ? 'Value' : 'Nilai',
            label: '${_engine.nilai}',
            color: const Color(0xFF08A9C8),
          ),
        if (_level.needCrystals)
          _statChip(
            icon: Icons.diamond,
            caption: _en ? 'Crystal' : 'Kristal',
            label: '${_engine.crystalsTaken}/${_engine.crystalsTotal}',
            color: const Color(0xFF59C36A),
          ),
      ],
    );
  }

  Widget _statChip({
    required IconData icon,
    required String caption,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$caption ',
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // 4. BLOK PERINTAH TERSEDIA
  // ----------------------------------------------------------
  Widget _paletteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF202524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'AVAILABLE COMMANDS',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              Text(
                '${_level.palette.length} ${_en ? 'blocks' : 'blok'}',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _en
                ? 'Tap a block, or drag it into the sequence below.'
                : 'Ketuk blok, atau seret ke urutan di bawah.',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 11),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final BlockKind k in _level.palette) _paletteChip(k),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paletteChip(BlockKind kind) {
    final BlockType t = kBlockTypes[kind]!;
    final Widget body = _chipBody(t);

    return Draggable<BlockType>(
      key: ValueKey<String>('palette_${kind.name}'),
      data: t,
      feedback: Material(
        color: Colors.transparent,
        child: body,
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: body),
      child: GestureDetector(
        onTap: () => _addBlock(kind, _script),
        child: body,
      ),
    );
  }

  Widget _chipBody(BlockType t, {VoidCallback? onTap}) {
    final Widget inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: t.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: t.color.withValues(alpha: 0.7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(t.icon, size: 14, color: t.color),
          const SizedBox(width: 6),
          Text(
            t.code(_en),
            style: TextStyle(
              color: t.color,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return inner;
    return GestureDetector(onTap: onTap, child: inner);
  }

  // ----------------------------------------------------------
  // 5. EXECUTION SEQUENCE (SUSUNAN KODE)
  // ----------------------------------------------------------
  Widget _scriptCard() {
    final int used = _used;
    final bool full = used >= _level.maxBlocks;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFF202524),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'EXECUTION SEQUENCE',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              Text(
                full
                    ? (_en ? 'QUOTA FULL' : 'KUOTA PENUH')
                    : '${_level.maxBlocks - used} ${_en ? 'left' : 'sisa'}',
                style: TextStyle(
                  color: full
                      ? const Color(0xFFFF6B4A)
                      : const Color(0xFF42CFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 11),

          if (_script.isEmpty)
            _emptySequence()
          else ...[
            _buildList(_script, 0),
            _dropZone(_script),
          ],

          if (_script.isEmpty) ...[
            const SizedBox(height: 8),
            _dropZone(_script),
          ],
        ],
      ),
    );
  }

  Widget _emptySequence() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Icon(
            Icons.drag_indicator,
            color: Colors.white24,
            size: 26,
          ),
          const SizedBox(height: 7),
          Text(
            _en
                ? 'No blocks yet. Tap a command or drop it here.'
                : 'Belum ada blok. Ketuk perintah atau jatuhkan blok di sini.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 11.5),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<ScriptBlock> list, int depth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < list.length; i++)
          _blockRow(list, i, list[i], depth),
      ],
    );
  }

  Widget _blockRow(
    List<ScriptBlock> list,
    int index,
    ScriptBlock b,
    int depth,
  ) {
    final Color c = b.type.color;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: c,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.label(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    if (b.kind == BlockKind.repeat ||
                        b.kind == BlockKind.addValue ||
                        b.kind == BlockKind.ifValue) ...[
                      const SizedBox(height: 6),
                      _paramRow(b),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Column(
                children: [
                  _miniBtn(
                    icon: Icons.keyboard_arrow_up,
                    color: Colors.white70,
                    onTap: _running || index == 0
                        ? null
                        : () => _moveBlock(list, index, -1),
                  ),
                  _miniBtn(
                    icon: Icons.keyboard_arrow_down,
                    color: Colors.white70,
                    onTap: _running || index == list.length - 1
                        ? null
                        : () => _moveBlock(list, index, 1),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              _miniBtn(
                icon: Icons.close,
                color: const Color(0xFFFF6B4A),
                onTap: _running
                    ? null
                    : () => _removeBlock(list, b),
              ),
            ],
          ),

          if (b.type.container) ...[
            const SizedBox(height: 8),
            _branch(b, thenBranch: true),
            if (b.hasElse) _branch(b, thenBranch: false),
          ],
        ],
      ),
    );
  }

  Widget _branch(ScriptBlock b, {required bool thenBranch}) {
    final Color c = b.type.color;
    final List<ScriptBlock> inner = thenBranch ? b.children : b.elseChildren;

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.fromLTRB(9, 9, 9, 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.32),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thenBranch ? 'LAKUKAN / THEN' : 'SELAINNYA / ELSE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: thenBranch ? c : Colors.white54,
            ),
          ),
          const SizedBox(height: 8),

          if (inner.isEmpty)
            Text(
              _en ? 'Empty' : 'Kosong',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            for (int i = 0; i < inner.length; i++)
              _blockRow(inner, i, inner[i], 1),

          _dropZone(inner, compact: true),
        ],
      ),
    );
  }

  /// Baris pengatur angka di dalam blok.
  Widget _paramRow(ScriptBlock b) {
    if (b.kind == BlockKind.repeat) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _paramLabel(_en ? 'Count' : 'Jumlah'),
          _stepBtn(
            Icons.remove,
            const Color(0xFFB07CFF),
            _running
                ? null
                : () => setState(() => b.count = (b.count - 1).clamp(1, 9)),
          ),
          _paramValue('${b.count}', const Color(0xFFB07CFF)),
          _stepBtn(
            Icons.add,
            const Color(0xFFB07CFF),
            _running
                ? null
                : () => setState(() => b.count = (b.count + 1).clamp(1, 9)),
          ),
          const SizedBox(width: 6),
          _paramLabel(_en ? 'times' : 'kali'),
        ],
      );
    }

    if (b.kind == BlockKind.addValue) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _paramLabel('nilai'),
          const SizedBox(width: 6),
          _stepBtn(
            Icons.swap_horiz,
            const Color(0xFF08A9C8),
            _running ? null : () => setState(() => b.op = b.op.next),
            tooltip: b.op.symbol,
          ),
          _paramValue(b.op.symbol, const Color(0xFF08A9C8)),
          _stepBtn(
            Icons.remove,
            const Color(0xFF08A9C8),
            _running
                ? null
                : () => setState(() => b.operand = (b.operand - 1).clamp(1, 9)),
          ),
          _paramValue('${b.operand}', const Color(0xFF08A9C8)),
          _stepBtn(
            Icons.add,
            const Color(0xFF08A9C8),
            _running
                ? null
                : () => setState(() => b.operand = (b.operand + 1).clamp(1, 9)),
          ),
        ],
      );
    }

    // ifValue
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _paramLabel(_en ? 'var' : 'nilai'),
        const SizedBox(width: 6),
        _stepBtn(
          Icons.compare_arrows,
          const Color(0xFFFFB21A),
          _running ? null : () => setState(() => b.cmp = b.cmp.next),
          tooltip: b.cmp.symbol,
        ),
        _paramValue(b.cmp.symbol, const Color(0xFFFFB21A)),
        _stepBtn(
          Icons.remove,
          const Color(0xFFFFB21A),
          _running
              ? null
              : () => setState(() => b.operand = (b.operand - 1).clamp(0, 9)),
        ),
        _paramValue('${b.operand}', const Color(0xFFFFB21A)),
        _stepBtn(
          Icons.add,
          const Color(0xFFFFB21A),
          _running
              ? null
              : () => setState(() => b.operand = (b.operand + 1).clamp(0, 9)),
        ),
      ],
    );
  }

  Widget _paramLabel(String text) => Text(
    text,
    style: const TextStyle(color: Colors.white54, fontSize: 11),
  );

  Widget _paramValue(String text, Color color) => ConstrainedBox(
    constraints: const BoxConstraints(minWidth: 26),
    child: Container(
      height: 24,
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      padding: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  Widget _stepBtn(
    IconData icon,
    Color color,
    VoidCallback? onTap, {
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 24,
        height: 24,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: onTap == null ? 0.07 : 0.18),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          size: 14,
          color: onTap == null ? Colors.white24 : color,
        ),
      ),
    );
  }

  Widget _miniBtn({
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7),
      child: Container(
        width: 26,
        height: 23,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: onTap == null ? 0.03 : 0.07),
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.white24 : color,
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // ZONA JATUH BLOK
  // ----------------------------------------------------------
  Widget _dropZone(List<ScriptBlock> target, {bool compact = false}) {
    return DragTarget<BlockType>(
      onWillAcceptWithDetails: (DragTargetDetails<BlockType> details) =>
          !_running && _used < _level.maxBlocks,
      onAcceptWithDetails: (DragTargetDetails<BlockType> details) =>
          _addBlock(details.data.kind, target),
      builder: (
        BuildContext ctx,
        List<BlockType?> accepted,
        List<dynamic> rejected,
      ) {
        final bool hot = accepted.isNotEmpty;
        final Color color = hot
            ? const Color(0xFF42CFFF)
            : Colors.white24;

        return GestureDetector(
          onTap: () => _pickBlock(target),
          child: CustomPaint(
            painter: _DashedPainter(color: color),
            child: Container(
              height: compact ? 40 : 46,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    size: 15,
                    color: hot ? const Color(0xFF42CFFF) : Colors.white38,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    'Drop next block here',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: hot
                          ? const Color(0xFF42CFFF)
                          : Colors.white38,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ----------------------------------------------------------
  // 6. KONSOL OUTPUT
  // ----------------------------------------------------------
  Widget _consoleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1416),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF164653)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.terminal,
                size: 14,
                color: Color(0xFF8DE7F5),
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'OUTPUT',
                  style: TextStyle(
                    color: Color(0xFF8DE7F5),
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.6,
                  ),
                ),
              ),
              Text(
                '${_engine.log.length} ${_en ? 'lines' : 'baris'}',
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(10),
            ),
            child: _engine.log.isEmpty
                ? const Center(
                    child: Text(
                      '...',
                      style: TextStyle(
                        color: Colors.white24,
                        fontSize: 12,
                      ),
                    ),
                  )
                : ListView(
                    controller: _logCtrl,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    children: [
                      for (final String line in _engine.log)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            line,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              height: 1.3,
                              color: _logColor(line),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Color _logColor(String line) {
    if (line.startsWith('✘')) return const Color(0xFFFF6B4A);
    if (line.startsWith('✔')) return const Color(0xFF59C36A);
    if (line.startsWith('⚔')) return const Color(0xFFFFC15C);
    return const Color(0xFF8DE7F5);
  }

  // ----------------------------------------------------------
  // 7. TOMBOL EKSEKUSI
  // ----------------------------------------------------------
  Widget _runButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _running ? null : _runCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB21A),
          foregroundColor: Colors.black,
          disabledBackgroundColor: const Color(0xFF3A3D3C),
          disabledForegroundColor: Colors.white38,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        icon: Icon(_running ? Icons.hourglass_top : Icons.play_arrow),
        label: Text(
          _running
              ? (_en ? 'RUNNING...' : 'MENJALANKAN...')
              : 'EKSEKUSI / RUN CODE',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _resetRow() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _running ? null : _resetBoard,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh, size: 16),
              label: Text(
                _en ? 'RESET ARENA' : 'ATUR ULANG',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: SizedBox(
            height: 44,
            child: OutlinedButton.icon(
              onPressed: _running ? null : _clearScript,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.delete_sweep_outlined, size: 16),
              label: Text(
                _en ? 'CLEAR BLOCKS' : 'HAPUS BLOK',
                style: const TextStyle(fontSize: 12.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// BORDER PUTUS-PUTUS UNTUK ZONA JATUH
// ============================================================
class _DashedPainter extends CustomPainter {
  _DashedPainter({required this.color});

  final Color color;

  static const double _radius = 10;
  static const double _dash = 7;
  static const double _gap = 6;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    final ui.Path path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size,
          const Radius.circular(_radius),
        ),
      );

    for (final ui.PathMetric metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        canvas.drawPath(metric.extractPath(dist, dist + _dash), paint);
        dist += _dash + _gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter oldDelegate) =>
      oldDelegate.color != color;
}
