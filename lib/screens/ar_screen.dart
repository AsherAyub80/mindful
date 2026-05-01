import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/glass_widgets.dart';

class ARScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const ARScreen({super.key, required this.onNavigate});

  @override
  State<ARScreen> createState() => _ARScreenState();
}

class _ARScreenState extends State<ARScreen> with TickerProviderStateMixin {
  double _progress = 0;
  bool _scanning = false;
  bool _placed = false;
  Timer? _scanTimer;

  late AnimationController _rotateController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanTimer?.cancel();
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startScan() {
    setState(() { _scanning = true; _progress = 0; });
    _scanTimer = Timer.periodic(const Duration(milliseconds: 40), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _progress += 2);
      if (_progress >= 100) {
        t.cancel();
        setState(() { _scanning = false; _placed = true; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Expanded(child: _buildCameraView()),
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Fake camera bg
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF0A1A1F), Color(0xFF0D2B20), Color(0xFF0A1520)],
            ),
          ),
        ),
        // Grid
        CustomPaint(painter: _GridPainter(), size: Size.infinite),
        // Corners
        const _CornerBrackets(),
        // Center content
        Center(child: _buildCenterContent()),
        // HUD top
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 0, right: 0,
          child: Center(child: _buildHUD()),
        ),
        // Back button
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 16,
          child: NeuButton(
            onTap: () => widget.onNavigate(1),
            borderRadius: 20, width: 40, height: 40, padding: EdgeInsets.zero,
            child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent() {
    if (_placed) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _rotateController,
            builder: (_, __) => Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_rotateController.value * 2 * math.pi),
              alignment: Alignment.center,
              child: const Text('🥗', style: TextStyle(fontSize: 90)),
            ),
          ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: Colors.white, fontSize: 13),
                children: [
                  TextSpan(text: 'Zen Buddha Bowl · '),
                  TextSpan(text: '420 kcal', style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (_scanning) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: SizedBox(
              width: 110, height: 110,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 110, height: 110,
                    child: CircularProgressIndicator(
                      value: _progress / 100,
                      strokeWidth: 3,
                      backgroundColor: AppColors.white20,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                    ),
                  ),
                  Container(
                    width: 90, height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      color: AppColors.primary.withOpacity(0.1),
                    ),
                    child: const Center(child: Text('🔍', style: TextStyle(fontSize: 36))),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Scanning surface… ${_progress.toInt()}%',
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      );
    }

    // Initial state
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2, style: BorderStyle.solid),
            color: AppColors.primary.withOpacity(0.08),
          ),
          child: const Center(child: Text('📷', style: TextStyle(fontSize: 40))),
        ),
        const SizedBox(height: 16),
        const Text('Point camera at a flat surface',
            style: TextStyle(color: AppColors.white50, fontSize: 13)),
      ],
    );
  }

  Widget _buildHUD() {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      borderRadius: 20,
      child: Text(
        _placed ? '✓ PLACED' : _scanning ? 'SCANNING...' : 'AR PREVIEW MODE',
        style: const TextStyle(
            color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xEB080F18),
        border: Border(top: BorderSide(color: AppColors.white15, width: 1)),
      ),
      child: _placed
          ? Row(
              children: [
                for (final item in [('🔄', 'Rotate'), ('📏', 'Scale'), ('💾', 'Save')])
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: item.$1 == '💾' ? 0 : 10),
                      child: NeuButton(
                        onTap: () {},
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(
                          children: [
                            Text(item.$1, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(item.$2, style: const TextStyle(color: AppColors.white50, fontSize: 11)),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : NeuButton(
              active: !_scanning,
              onTap: _scanning ? null : _startScan,
              padding: const EdgeInsets.symmetric(vertical: 14),
              width: double.infinity,
              child: Center(
                child: Text(
                  _scanning ? 'Scanning ${_progress.toInt()}%' : '🎯  Place Dish in AR',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withOpacity(0.08)
      ..strokeWidth = 0.5;
    for (int i = 1; i < 10; i++) {
      canvas.drawLine(Offset(0, size.height * i / 10), Offset(size.width, size.height * i / 10), paint);
      canvas.drawLine(Offset(size.width * i / 10, 0), Offset(size.width * i / 10, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CornerBrackets extends StatelessWidget {
  const _CornerBrackets();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: 64, left: 16, child: _Bracket(flipX: false, flipY: false)),
        Positioned(top: 64, right: 16, child: _Bracket(flipX: true, flipY: false)),
        Positioned(bottom: 16, left: 16, child: _Bracket(flipX: false, flipY: true)),
        Positioned(bottom: 16, right: 16, child: _Bracket(flipX: true, flipY: true)),
      ],
    );
  }
}

class _Bracket extends StatelessWidget {
  final bool flipX, flipY;
  const _Bracket({required this.flipX, required this.flipY});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: flipX ? -1 : 1,
      scaleY: flipY ? -1 : 1,
      child: SizedBox(
        width: 28, height: 28,
        child: CustomPaint(
          painter: _BracketPainter(),
        ),
      ),
    );
  }
}

class _BracketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(0, 0)
      ..lineTo(0, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
