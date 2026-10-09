import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../services/adventure_service.dart';
import '../services/game_service.dart';
import '../widgets/app_header.dart';
import '../widgets/hero_token.dart';
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
const Color _kRed = Color(0xFFB02A32);
const Color _kText = Color(0xFFDDE7E9);
const Color _kMuted = Color(0xFF8A9795);

/// Berapa sel labirin yang kira-kira terlihat di layar.
const double _visibleCells = 6.0;

class AdventurePage extends StatefulWidget {
  final int region;
  final int level;
  final bool isEnglish;
  final VoidCallback onLanguageChanged;
  final VoidCallback onBack;

  /// Dipanggil saat pemain pulang ke peta (skor dihitung tahap nanti).
  final void Function(int stars)? onFinished;

  const AdventurePage({
    super.key,
    required this.region,
    required this.level,
    required this.isEnglish,
    required this.onLanguageChanged,
    required this.onBack,
    this.onFinished,
  });

  @override
  State<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends State<AdventurePage>
    with SingleTickerProviderStateMixin {
  late MazeLevel _level;
  late AdventureService _service;
  late Ticker _ticker;
  Duration _lastElapsed = Duration.zero;

  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _keys = <LogicalKeyboardKey>{};
  Offset _kbInput = Offset.zero;
  Offset _joyInput = Offset.zero;

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
    _level = MazeCatalog.level(widget.region, widget.level);
    _service = AdventureService(_level);
    _lastElapsed = Duration.zero;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final double dt =
        (elapsed - _lastElapsed).inMicroseconds / 1000000.0;
    _lastElapsed = elapsed;
    _service.update(dt.clamp(0.0, 0.05));
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
              listenable: _service,
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
                    // Minimap (pojok kiri atas)
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Minimap(service: _service),
                    ),
                    // Petunjuk
                    Positioned(
                      left: 90,
                      right: 90,
                      top: 12,
                      child: Center(child: _hintChip()),
                    ),
                    // Joystick
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

    return Stack(
      children: <Widget>[
        // Karakter pemain
        Positioned(
          left: pcx - cellPx / 2,
          top: pcy - cellPx / 2,
          width: cellPx,
          height: cellPx,
          child: HeroToken(size: cellPx, facing: _service.facing),
        ),
        // Monster (muncul bila pernah terlihat; redup bila tak lagi
        // terlihat langsung).
        if (_service.isSeen(m.row, m.col))
          Positioned(
            left: (m.col + 0.05) * cellPx - camera.dx,
            top: (m.row + 0.05) * cellPx - camera.dy,
            width: cellPx * 0.9,
            height: cellPx * 0.9,
            child: Opacity(
              opacity: _monsterOpacity(),
              child: Container(
                decoration: BoxDecoration(
                  color: _kRed,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: _kPink.withValues(alpha: 0.55),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.pest_control_rounded,
                  color: Colors.white,
                  size: 26,
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
    final Paint dimPaint = Paint()
      ..color = _dimOverlay.withValues(alpha: 0.55);

    final double vr = AdventureService.visRadius;
    for (int r = 0; r < level.size; r++) {
      for (int c = 0; c < level.size; c++) {
        final Rect cell = Rect.fromLTWH(
          c * cellPx,
          r * cellPx,
          cellPx,
          cellPx,
        );

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
      ).createShader(
        Rect.fromCircle(center: pc, radius: vr * cellPx),
      );
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