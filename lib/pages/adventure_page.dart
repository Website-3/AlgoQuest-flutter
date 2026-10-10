import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../services/adventure_service.dart';
import '../services/combat_service.dart';
import '../services/game_service.dart';
import '../widgets/action_button.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_token.dart';
import '../widgets/hp_bar.dart';
import '../widgets/minimap.dart';
import '../widgets/virtual_joystick.dart';
import 'map_page.dart';

// ============================================================
// ADVENTURE PAGE — MODE PETUALANGAN
// ============================================================
// Pemain bergerak bebas di dalam labirin memakai joystick
// analog (di web juga WASD / panah). Kamera mengikuti pemain,
// jadi tidak seluruh peta terlihat. Tahap 1: gerak + kamera +
// collision. Tahap berikutnya: fog of war + minimap + tempur.

// ---------- Palet warna ----------
const Color _kBg = Color(0xFF0B100F);
const Color _kCard = Color(0xFF141A19);
const Color _kLine = Color(0xFF2A3432);
const Color _kCyan = Color(0xFF42CFFF);
const Color _kPink = Color(0xFFFF5E7E);
const Color _kYellow = Color(0xFFFFB21A);
const Color _kRed = Color(0xFFB02A32);
const Color _kText = Color(0xFFDDE7E9);
const Color _kMuted = Color(0xFF8A9795);

/// Berapa sel labirin yang kira-kira terlihat di layar.
const double _visibleCells = 6.0;

/// Jarak minimal ke monster agar tombol TEMPUR muncul.
const double _fightRange = 1.75;

class AdventurePage extends StatefulWidget {
  final int region;
  final int level;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onBack;

  /// Dipanggil saat pemain pulang ke peta (skor dihitung tahap nanti).
  final void Function(int stars)? onFinished;

  /// Khusus uji/preview: pakai labirin ini alih-alih katalog.
  final MazeLevel? debugLevel;

  /// Khusus uji/preview: langsung mulai tempur di samping monster.
  final bool debugStartFight;

  const AdventurePage({
    super.key,
    required this.region,
    required this.level,
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onBack,
    this.onFinished,
    this.debugLevel,
    this.debugStartFight = false,
  });

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage>
    with SingleTickerProviderStateMixin {
  late MazeLevel _level;
  late AdventureService _service;
  late CombatService _combat;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _keys = <LogicalKeyboardKey>{};
  Offset _kbInput = Offset.zero;
  Offset _joyInput = Offset.zero;

  /// Cegah pemberian bintang dua kali untuk satu kemenangan.
  bool _rewarded = false;

  /// Cegah penanganan kekalahan dua kali.
  bool _lostHandled = false;

  /// Animasi hancurnya monster (0 → 1). 1 = tidak ada animasi.
  double _defeatAnim = 1;

  /// Jeda singkat sebelum panel hasil muncul agar efek terlihat dulu.
  double _resultDelay = 0;

  /// Animasi munculnya panel hasil (0 → 1) untuk efek bintang "pop".
  double _panelAnim = 0;

  bool get _en => widget.isEnglish;

  @override
  void initState() {
    super.initState();
    _load();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void didUpdateWidget(covariant AdventurePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.region != widget.region || oldWidget.level != widget.level) {
      _load();
    }
  }

  void _load() {
    _level =
        widget.debugLevel ?? MazeCatalog.level(widget.region, widget.level);
    _service = AdventureService(_level);
    _combat = CombatService.forLevel(widget.region, widget.level);
    _lastElapsed = Duration.zero;
    _rewarded = false;
    _lostHandled = false;
    _defeatAnim = 1;
    _resultDelay = 0;
    _panelAnim = 0;
    if (widget.debugStartFight) {
      _service.jumpTo(_level.monster.col + 0.5, _level.monster.row + 0.5 - 1.0);
      _combat.startFight();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final double dt = (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    final double s = dt.clamp(0.0, 0.05);
    _service.update(s);
    if (_combat.isFighting) {
      _service.setInput(Offset.zero); // pemain diam saat bertarung
      _combat.update(s);
      if (!_rewarded && _combat.phase == FightPhase.won) {
        _rewarded = true;
        _defeatAnim = 0; // mulai efek hancur
        _resultDelay = 1.0; // tunda panel hasil agar efek terlihat
        _awardVictory();
      }
      if (!_lostHandled && _combat.phase == FightPhase.lost) {
        _lostHandled = true;
        _resultDelay = 0.7;
      }
    }
    // Animasi halaman tetap berjalan meski tempur sudah usai.
    if (_defeatAnim < 1) {
      _defeatAnim = (_defeatAnim + s / 0.7).clamp(0.0, 1.0);
    }
    if (_resultDelay > 0) {
      _resultDelay = math.max(0.0, _resultDelay - s);
    }
    final bool ended =
        _combat.phase == FightPhase.won || _combat.phase == FightPhase.lost;
    if (ended && _resultDelay <= 0 && _panelAnim < 1) {
      _panelAnim = (_panelAnim + s / 0.5).clamp(0.0, 1.0);
    }
    // Paksa render ulang selama animasi pasca-tempur berlangsung: setelah
    // tempur usai, layanan tidak lagi mengabarkan perubahan, padahal kita
    // masih menganimasikan ledakan & panel hasil.
    final bool animating =
        _defeatAnim < 1 || _resultDelay > 0 || (ended && _panelAnim < 1);
    if (animating && mounted) {
      setState(() {});
    }
  }

  /// Reset status tempur halaman sebelum memulai ronde baru.
  void _resetFightState() {
    _rewarded = false;
    _lostHandled = false;
    _defeatAnim = 1;
    _resultDelay = 0;
    _panelAnim = 0;
  }

  void _startFight() {
    _resetFightState();
    _combat.startFight();
  }

  void _rematch() {
    _resetFightState();
    _combat.rematch();
  }

  /// Bintang dari sisa HP pemain saat menang (makin utuh makin banyak).
  int _victoryStars() {
    final double ratio = _combat.playerHpRatio;
    if (ratio >= 0.66) return 3;
    if (ratio >= 0.33) return 2;
    return 1;
  }

  /// Simpan bintang mode Petualangan untuk level ini.
  void _awardVictory() {
    final int stars = _victoryStars();
    if (stars >
        MapProgress.starsOf(widget.region, widget.level, GameMode.adventure)) {
      MapProgress.setStars(
        widget.region,
        widget.level,
        GameMode.adventure,
        stars,
      );
    }
  }

  // ----------------------------------------------------------
  // Input (joystick + keyboard)
  // ----------------------------------------------------------
  bool _onKeyEvent(KeyEvent event) {
    final LogicalKeyboardKey k = event.logicalKey;
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      _keys.add(k);
    } else if (event is KeyUpEvent) {
      _keys.remove(k);
    }
    _refreshKeyboard();
    return false;
  }

  void _refreshKeyboard() {
    double dx = 0;
    double dy = 0;
    if (_keys.contains(LogicalKeyboardKey.arrowUp) ||
        _keys.contains(LogicalKeyboardKey.keyW)) {
      dy -= 1;
    }
    if (_keys.contains(LogicalKeyboardKey.arrowDown) ||
        _keys.contains(LogicalKeyboardKey.keyS)) {
      dy += 1;
    }
    if (_keys.contains(LogicalKeyboardKey.arrowLeft) ||
        _keys.contains(LogicalKeyboardKey.keyA)) {
      dx -= 1;
    }
    if (_keys.contains(LogicalKeyboardKey.arrowRight) ||
        _keys.contains(LogicalKeyboardKey.keyD)) {
      dx += 1;
    }
    Offset v = Offset(dx, dy);
    if (v.distance > 1) v = v / v.distance;
    _kbInput = v;
    _applyInput();
  }

  void _applyInput() {
    if (_combat.isFighting) {
      _service.setInput(Offset.zero);
      return;
    }
    _service.setInput(_kbInput.distance > 0 ? _kbInput : _joyInput);
  }

  // ----------------------------------------------------------
  // Build
  // ----------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: KeyboardListener(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKeyEvent,
        child: SafeArea(
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
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          _banner(),
                          const SizedBox(height: 10),
                          Expanded(child: _arena()),
                        ],
                      ),
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

  // ---------- Banner level ----------
  Widget _banner() {
    final GameRegion region = gameRegions[widget.region.clamp(0, 4)];
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _kLine),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: region.color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: region.color.withValues(alpha: 0.5)),
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
                  '  \u00B7  LEVEL ${widget.level + 1}',
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
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _kPink.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kPink.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.pest_control, color: _kPink, size: 14),
                const SizedBox(width: 5),
                Text(
                  _en ? 'FIND' : 'CARI',
                  style: const TextStyle(
                    color: _kPink,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Arena ----------
  Widget _arena() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double vw = constraints.maxWidth;
        final double vh = constraints.maxHeight;
        return ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _kLine),
            ),
            child: ListenableBuilder(
              listenable: Listenable.merge(<Listenable>[_service, _combat]),
              builder: (BuildContext context, _) {
                final double cellPx = math.min(vw, vh) / _visibleCells;
                final double worldW = _level.size * cellPx;
                final double worldH = _level.size * cellPx;

                // Kamera mengikuti pemain, dijepit agar tidak
                // memperlihatkan area di luar labirin.
                double camX = _service.x * cellPx - vw / 2;
                double camY = _service.y * cellPx - vh / 2;
                camX = camX.clamp(0.0, math.max(0.0, worldW - vw));
                camY = camY.clamp(0.0, math.max(0.0, worldH - vh));
                final Offset camera = Offset(camX, camY);

                final bool fighting = _combat.isFighting;
                final bool exploring = _combat.phase == FightPhase.exploring;
                final bool ended =
                    _combat.phase == FightPhase.won ||
                    _combat.phase == FightPhase.lost;
                final bool showResult = ended && _resultDelay <= 0;
                final double mDist = _monsterDist;
                final bool inFightRange =
                    exploring &&
                    !_combat.monsterDefeated &&
                    mDist <= _fightRange;

                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _MazeWorldPainter(
                          level: _level,
                          service: _service,
                          cellPx: cellPx,
                          camera: camera,
                        ),
                      ),
                    ),
                    // Pemain + monster
                    Positioned.fill(child: _entitiesLayer(cellPx, camera)),
                    // Efek tempur (tebasan, HINDAR, teleport isyarat)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: _CombatFxPainter(
                            combat: _combat,
                            playerPos: Offset(
                              _service.x * cellPx - camera.dx,
                              _service.y * cellPx - camera.dy,
                            ),
                            monsterPos: Offset(
                              (_level.monster.col + 0.5) * cellPx - camera.dx,
                              (_level.monster.row + 0.5) * cellPx - camera.dy,
                            ),
                            cellPx: cellPx,
                            defeatAnim: _defeatAnim,
                          ),
                        ),
                      ),
                    ),
                    // Minimap (pojok kiri atas) — tersembunyi saat tempur
                    if (exploring)
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Minimap(
                          service: _service,
                          showMonster: !_combat.monsterDefeated,
                        ),
                      ),
                    // Petunjuk / bilah HP
                    if (fighting)
                      Positioned(
                        top: 10,
                        left: 12,
                        right: 12,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: HpBar(
                                label: _en ? 'YOU' : 'KAMU',
                                icon: Icons.sentiment_satisfied,
                                ratio: _combat.playerHpRatio,
                                color: _kCyan,
                                valueText:
                                    '${_combat.playerHp.round()}/${_combat.playerMaxHp}',
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: HpBar(
                                label: _en ? 'MONSTER' : 'MONSTER',
                                icon: Icons.pest_control,
                                ratio: _combat.monsterHpRatio,
                                color: _kRed,
                                valueText:
                                    '${_combat.monsterHp.round()}/${_combat.monsterMaxHp}',
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (exploring)
                      Positioned(
                        left: 90,
                        right: 90,
                        top: 12,
                        child: Center(child: _hintChip()),
                      ),
                    // Tombol TEMPUR (muncul saat dekat monster)
                    if (inFightRange)
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 18,
                        child: Center(child: _fightButton()),
                      ),
                    // Joystick (disembunyikan saat tempur)
                    if (exploring)
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: VirtualJoystick(
                          size: 118,
                          onChanged: (Offset v) {
                            setState(() => _joyInput = v);
                            _applyInput();
                          },
                        ),
                      ),
                    // Tombol aksi saat tempur
                    if (fighting)
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            ActionButton(
                              icon: Icons.sports_kabaddi,
                              label: _en ? 'ATTACK' : 'SERANG',
                              color: _kPink,
                              onTap: _combat.attack,
                              enabled: !_combat.attacking,
                            ),
                            ActionButton(
                              icon: Icons.auto_awesome,
                              label: _en ? 'SKILL' : 'SKILL',
                              color: _kCyan,
                              onTap: _combat.skill,
                              cooldown: _combat.skillCdRatio,
                              enabled: _combat.skillReady,
                            ),
                            ActionButton(
                              icon: Icons.shield,
                              label: _en ? 'DODGE' : 'DODGE',
                              color: const Color(0xFF35D07F),
                              onTap: _combat.dodge,
                              cooldown: _combat.dodgeCdRatio,
                              enabled: _combat.dodgeReady,
                            ),
                          ],
                        ),
                      ),
                    // Panel hasil (menang/kalah)
                    if (showResult) Positioned.fill(child: _resultPanel()),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _entitiesLayer(double cellPx, Offset camera) {
    final double pcx = _service.x * cellPx - camera.dx;
    final double pcy = _service.y * cellPx - camera.dy;
    final Pos m = _level.monster;
    final double mcx = (m.col + 0.5) * cellPx - camera.dx;
    final double mcy = (m.row + 0.5) * cellPx - camera.dy;

    // Geser pemain saat menyerang & monster saat menerkam.
    Offset playerLunge = Offset.zero;
    Offset monsterLunge = Offset.zero;
    if (_combat.isFighting || _combat.phase == FightPhase.won) {
      Offset dir = Offset(mcx - pcx, mcy - pcy);
      final double len = dir.distance;
      if (len < 0.001) {
        dir = const Offset(1, 0);
      } else {
        dir = dir / len;
      }
      if (_combat.attackT > 0) {
        playerLunge =
            dir * (math.sin(_combat.attackT * math.pi) * cellPx * 0.3);
      }
      if (_combat.monsterLungeT > 0) {
        monsterLunge =
            (-dir) *
            (math.sin(_combat.monsterLungeT * math.pi) * cellPx * 0.32);
      }
      if (_combat.shakeT > 0) {
        monsterLunge += Offset(
          math.sin(_combat.shakeT * 90) * 1.6,
          math.cos(_combat.shakeT * 70) * 1.6,
        );
      }
    }

    return Stack(
      children: <Widget>[
        // Karakter pemain
        Positioned(
          left: pcx + playerLunge.dx - cellPx / 2,
          top: pcy + playerLunge.dy - cellPx / 2,
          width: cellPx,
          height: cellPx,
          child: HeroToken(size: cellPx, facing: _service.facing),
        ),
        // Monster (muncul bila pernah terlihat & belum kalah; redup bila
        // tak lagi terlihat langsung). Saat kalah, ia membesar lalu
        // memudar sebagai efek hancur.
        if (_service.isSeen(m.row, m.col) &&
            (!_combat.monsterDefeated || _defeatAnim < 1))
          Positioned(
            left: mcx + monsterLunge.dx - cellPx * 0.45,
            top: mcy + monsterLunge.dy - cellPx * 0.45,
            width: cellPx * 0.9,
            height: cellPx * 0.9,
            child: Opacity(
              opacity: _combat.monsterDefeated
                  ? (1 - _defeatAnim)
                  : _monsterOpacity(),
              child: Transform.scale(
                scale: _combat.monsterDefeated ? 1 + _defeatAnim * 0.8 : 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: _combat.flashT > 0 ? Colors.white : _kRed,
                    borderRadius: BorderRadius.circular(11),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: _combat.flashT > 0
                            ? Colors.white
                            : _kPink.withValues(alpha: 0.55),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.pest_control_rounded,
                    color: Colors.redAccent,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  double _monsterOpacity() {
    final double dx = (_level.monster.col + 0.5) - _service.x;
    final double dy = (_level.monster.row + 0.5) - _service.y;
    final double v = math.sqrt(dx * dx + dy * dy);
    return v <= AdventureService.visRadius ? 1.0 : 0.45;
  }

  double get _monsterDist {
    final double dx = (_level.monster.col + 0.5) - _service.x;
    final double dy = (_level.monster.row + 0.5) - _service.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  // ---------- Tombol TEMPUR ----------
  Widget _fightButton() {
    return GestureDetector(
      onTap: _startFight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
        decoration: BoxDecoration(
          color: _kPink,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _kPink.withValues(alpha: 0.6),
              blurRadius: 22,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sports_kabaddi, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _en ? 'FIGHT!' : 'TEMPUR!',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Panel hasil (menang / kalah) ----------
  Widget _resultPanel() {
    final bool won = _combat.phase == FightPhase.won;
    final double panelT = _easeOutBack(_panelAnim);
    return Container(
      color: Colors.black.withValues(alpha: 0.62),
      alignment: Alignment.center,
      child: Opacity(
        opacity: _panelAnim.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.85 + 0.15 * panelT,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 34),
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            decoration: BoxDecoration(
              color: _kCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: won ? _kYellow.withValues(alpha: 0.6) : _kPink,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  won ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                  color: won ? _kYellow : _kPink,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  won
                      ? (_en ? 'VICTORY!' : 'MENANG!')
                      : (_en ? 'DEFEAT' : 'KALAH'),
                  style: TextStyle(
                    color: won ? _kYellow : _kPink,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  won
                      ? (_en
                            ? 'Monster defeated. Great logic!'
                            : 'Monster dikalahkan. Logikamu hebat!')
                      : (_en
                            ? 'Your hero fell. Try again!'
                            : 'Karaktermu tumbang. Coba lagi!'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _kMuted, fontSize: 12),
                ),
                if (won) ...<Widget>[
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: _popStar(
                            filled: i < _victoryStars(),
                            delay: 0.25 + i * 0.12,
                          ),
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          if (won && widget.onFinished != null) {
                            widget.onFinished!(_victoryStars());
                          } else {
                            widget.onBack();
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _kText,
                          side: const BorderSide(color: _kLine),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          _en ? 'TO MAP' : 'KE PETA',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton(
                        onPressed: won ? _combat.continueExploring : _rematch,
                        style: FilledButton.styleFrom(
                          backgroundColor: won ? _kCyan : _kPink,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          won
                              ? (_en ? 'CONTINUE' : 'LANJUT')
                              : (_en ? 'RETRY' : 'COBA LAGI'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Bintang dengan animasi "pop" berurutan mengikuti [_panelAnim].
  Widget _popStar({required bool filled, required double delay}) {
    if (!filled) {
      return const Icon(Icons.star_border_rounded, color: _kYellow, size: 30);
    }
    final double p = ((_panelAnim - delay) / 0.3).clamp(0.0, 1.0);
    return Transform.scale(
      scale: 0.3 + 0.7 * _easeOutBack(p),
      child: Opacity(
        opacity: p.clamp(0.0, 1.0),
        child: const Icon(
          Icons.star_rounded,
          color: _kYellow,
          size: 30,
          shadows: <Shadow>[Shadow(color: Color(0x66FFB21A), blurRadius: 12)],
        ),
      ),
    );
  }

  /// Kurva "pop": sedikit melewati batas lalu kembali (overshoot).
  static double _easeOutBack(double t) {
    const double c1 = 1.70158;
    const double c3 = c1 + 1;
    return 1 +
        c3 * math.pow(t - 1, 3).toDouble() +
        c1 * math.pow(t - 1, 2).toDouble();
  }

  Widget _hintChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF101615).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kLine),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sports_esports, color: _kCyan, size: 14),
            const SizedBox(width: 5),
            Text(
              _en
                  ? 'Joystick / WASD to explore'
                  : 'Joystick / WASD untuk jelajah',
              maxLines: 1,
              style: const TextStyle(color: _kMuted, fontSize: 10.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// PELUKIS DUNIA LABIRIN (dengan kamera + fog of war)
// ------------------------------------------------------------
class _MazeWorldPainter extends CustomPainter {
  final MazeLevel level;
  final AdventureService service;
  final double cellPx;
  final Offset camera;

  const _MazeWorldPainter({
    required this.level,
    required this.service,
    required this.cellPx,
    required this.camera,
  });

  static const Color _floor = Color(0xFF0E1413);
  static const Color _floorLine = Color(0xFF121918);
  static const Color _wall = Color(0xFF1C2422);
  static const Color _wallLine = Color(0xFF2A3432);
  static const Color _hidden = Color(0xFF070B0A);
  static const Color _dimOverlay = Color(0xFF050808);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    // Pindahkan gambar mengikuti kamera (koordinat dunia).
    canvas.translate(-camera.dx, -camera.dy);

    final Paint floorPaint = Paint()..color = _floor;
    final Paint tilePaint = Paint()
      ..color = _floorLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint wallPaint = Paint()..color = _wall;
    final Paint wallBorderPaint = Paint()
      ..color = _wallLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Paint hiddenPaint = Paint()..color = _hidden;
    final Paint dimPaint = Paint()..color = _dimOverlay.withValues(alpha: 0.55);

    final double vr = AdventureService.visRadius;
    for (int r = 0; r < level.size; r++) {
      for (int c = 0; c < level.size; c++) {
        final Rect cell = Rect.fromLTWH(c * cellPx, r * cellPx, cellPx, cellPx);

        // Fog of war: sel belum pernah terlihat = gelap pekat.
        if (!service.isSeen(r, c)) {
          canvas.drawRect(cell, hiddenPaint);
          continue;
        }

        if (level.walls[r][c]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(cell, const Radius.circular(4)),
            wallPaint,
          );
          canvas.drawRRect(
            RRect.fromRectAndRadius(cell, const Radius.circular(4)),
            wallBorderPaint,
          );
        } else {
          canvas.drawRect(cell, floorPaint);
          canvas.drawRect(cell, tilePaint);
        }

        // Sel yang sudah dijelajahi tetapi tidak sedang terlihat
        // langsung dibuat redup.
        final double dx = (c + 0.5) - service.x;
        final double dy = (r + 0.5) - service.y;
        if (dx * dx + dy * dy > vr * vr) {
          canvas.drawRect(cell, dimPaint);
        }
      }
    }

    // Cahaya radial lembut di sekitar pemain supaya tepi wilayah
    // terlihat tidak patah-patah.
    final Offset pc = Offset(service.x * cellPx, service.y * cellPx);
    final Paint glow = Paint()
      ..shader = RadialGradient(
        colors: <Color>[
          _dimOverlay.withValues(alpha: 0.0),
          _dimOverlay.withValues(alpha: 0.6),
        ],
        stops: const <double>[0.55, 1.0],
      ).createShader(Rect.fromCircle(center: pc, radius: vr * cellPx));
    canvas.drawCircle(pc, vr * cellPx, glow);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MazeWorldPainter oldDelegate) =>
      oldDelegate.level != level ||
      oldDelegate.service != service ||
      oldDelegate.cellPx != cellPx ||
      oldDelegate.camera != camera;
}

// ------------------------------------------------------------
// PELUKIS EFEK TEMPUR
// ------------------------------------------------------------
class _CombatFxPainter extends CustomPainter {
  const _CombatFxPainter({
    required this.combat,
    required this.playerPos,
    required this.monsterPos,
    required this.cellPx,
    required this.defeatAnim,
  });

  final CombatService combat;
  final Offset playerPos;
  final Offset monsterPos;
  final double cellPx;

  /// Animasi hancurnya monster (0 → 1). < 1 = sedang berlangsung.
  final double defeatAnim;

  @override
  void paint(Canvas canvas, Size size) {
    // Perisai saat mengelak.
    if (combat.dodgeWindow > 0) {
      canvas.drawCircle(
        playerPos,
        cellPx * 0.62,
        Paint()
          ..color = const Color(0xFF42CFFF).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    // Ledakan kecil saat monster tumbang: cincin yang mengembang lalu
    // memudar, plus percikan.
    if (defeatAnim < 1) {
      final double p = defeatAnim;
      canvas.drawCircle(
        monsterPos,
        cellPx * (0.4 + p * 0.9),
        Paint()
          ..color = const Color(0xFFFFB21A).withValues(alpha: (1 - p) * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5 * (1 - p) + 0.5,
      );
      canvas.drawCircle(
        monsterPos,
        cellPx * (0.2 + p * 0.55),
        Paint()
          ..color = const Color(0xFFFF5E5E).withValues(alpha: (1 - p) * 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5 * (1 - p),
      );
      for (int i = 0; i < 8; i++) {
        final double a = i * math.pi / 4 + p * 0.6;
        final double r = cellPx * (0.25 + p * 0.75);
        canvas.drawCircle(
          monsterPos + Offset(math.cos(a) * r, math.sin(a) * r),
          (1 - p) * cellPx * 0.07 + 1,
          Paint()..color = const Color(0xFFFFD166).withValues(alpha: 1 - p),
        );
      }
    }

    if (!combat.isFighting) return;

    // Isyarat monster (tanda seru + cincin) sebelum menerkam.
    if (combat.monsterTelegraphing) {
      final double p = 1 - (combat.teleTimer / CombatService.teleDuration);
      final double blink = (math.sin(combat.teleTimer * 40).abs() * 0.5 + 0.5);
      canvas.drawCircle(
        monsterPos,
        cellPx * (0.45 + p * 0.5),
        Paint()
          ..color = const Color(0xFFFF5E5E)
              .withValues(alpha: 0.25 + blink * 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: '!',
          style: TextStyle(
            color: const Color(0xFFFF5E5E).withValues(alpha: 0.4 + blink * 0.6),
            fontSize: cellPx * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, monsterPos + Offset(-tp.width / 2, -cellPx * 1.15));
    }

    // Tebasan saat pemain menyerang (0.45..0.75 dari animasi).
    if (combat.attackT > 0) {
      final double s = (combat.attackT - 0.45) / 0.3;
      if (s > 0 && s < 1) {
        final Color c = combat.isSkill
            ? const Color(0xFF42CFFF)
            : const Color(0xFFFFB21A);
        final double a0 = math.atan2(
          playerPos.dy - monsterPos.dy,
          playerPos.dx - monsterPos.dx,
        );
        canvas.drawArc(
          Rect.fromCircle(
            center: monsterPos,
            radius: cellPx * (0.8 + s * 0.45),
          ),
          a0 - 1.5 + s * 3.0,
          2.2 - s * 1.9,
          false,
          Paint()
            ..color = c.withValues(alpha: 1 - s)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 6 * (1 - s * 0.4)
            ..strokeCap = StrokeCap.round,
        );
      }
    }

    // Teks melayang (damage / HINDAR!).
    for (final FloatText t in combat.texts) {
      final Offset base = t.atMonster ? monsterPos : playerPos;
      final double yOff = -t.t * cellPx * 1.2;
      final TextPainter tp = TextPainter(
        text: TextSpan(
          text: t.text,
          style: TextStyle(
            color: t.color.withValues(alpha: (1 - t.t).clamp(0.0, 1.0)),
            fontSize: cellPx * 0.42,
            fontWeight: FontWeight.bold,
            shadows: const <Shadow>[
              Shadow(color: Colors.black87, blurRadius: 3),
            ],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, base + Offset(-tp.width / 2, -cellPx * 0.35 + yOff));
    }
  }

  @override
  bool shouldRepaint(covariant _CombatFxPainter oldDelegate) => true;
}
