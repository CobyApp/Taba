import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/presentation/screens/common/letter_detail_screen.dart';
import 'package:taba_app/data/models/notification.dart';

class SkyScreen extends StatelessWidget {
  const SkyScreen({
    super.key,
    required this.letters,
    required this.notifications,
    this.unreadBouquetCount = 0,
    this.onOpenBouquet,
    this.onOpenSettings,
  });

  final List<Letter> letters;
  final List<NotificationItem> notifications;
  final int unreadBouquetCount;
  final VoidCallback? onOpenBouquet;
  final VoidCallback? onOpenSettings;
  static final _random = math.Random();

  LinearGradient _gradientForNow() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) {
      return const LinearGradient(
        colors: AppColors.gradientSky,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );
    }
    if (hour >= 12 && hour < 18) {
      return const LinearGradient(
        colors: AppColors.gradientHeroBlue,
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
      );
    }
    return const LinearGradient(
      colors: AppColors.gradientDusk,
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final gradient = _gradientForNow();

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Text(
                    'Taba',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontSize: 28,
                          letterSpacing: 2,
                          color: Colors.white,
                          fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily,
                        ),
                  ),
                  const Spacer(),
                  if (onOpenBouquet != null)
                    _HeaderIconButton(
                      icon: Icons.local_florist_outlined,
                      tooltip: '내 꽃다발',
                      onPressed: onOpenBouquet!,
                      badge: unreadBouquetCount,
                    ),
                  if (onOpenSettings != null)
                    _HeaderIconButton(
                      icon: Icons.settings_outlined,
                      tooltip: '설정',
                      onPressed: onOpenSettings!,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _FloatingFlowerField(
                      letters: letters,
                      onTap: (letter) => _openSeedBloom(context, letter),
                    ),
                  ),
                  Positioned(
                    left: 32,
                    top: 32,
                    child: _glowDot(Colors.white.withAlpha(77)),
                  ),
                  Positioned(
                    right: 48,
                    top: 120,
                    child: _glowDot(Colors.white.withAlpha(51), size: 22),
                  ),
                  Positioned(
                    right: 26,
                    bottom: 150,
                    child: _glowDot(Colors.white.withAlpha(64), size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowDot(Color color, {double size = 16}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size),
        boxShadow: [BoxShadow(color: color, blurRadius: 24, spreadRadius: 6)],
      ),
    );
  }

  Future<void> _openSeedBloom(BuildContext context, Letter letter) async {
    final bloomFlower = _bloomCatalog[_random.nextInt(_bloomCatalog.length)];
    final shouldOpen = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'seed',
      barrierColor: Colors.black.withAlpha(220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SeedBloomOverlay(letter: letter, bloomFlower: bloomFlower);
      },
    );
    if (shouldOpen == true && context.mounted) {
      _openLetterPreview(context, letter);
    }
  }

  void _openLetterPreview(BuildContext context, Letter letter) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black.withAlpha(204),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: LetterDetailScreen( // unified detail
              letter: letter,
              friendName: letter.isAnonymous ? null : letter.sender.nickname,
            ),
          );
        },
      ),
    );
  }
}

class _FloatingFlowerField extends StatefulWidget {
  const _FloatingFlowerField({required this.letters, required this.onTap});

  final List<Letter> letters;
  final ValueChanged<Letter> onTap;

  @override
  State<_FloatingFlowerField> createState() => _FloatingFlowerFieldState();
}

class _BloomSpec {
  const _BloomSpec(this.name, this.emoji);
  final String name;
  final String emoji;
}

const List<_BloomSpec> _bloomCatalog = [
  _BloomSpec('네온 장미', '🌹'),
  _BloomSpec('핑크 튤립', '🌷'),
  _BloomSpec('라일락', '💜'),
  _BloomSpec('스파클 사쿠라', '🌸'),
  _BloomSpec('글로우 해바라기', '🌻'),
  _BloomSpec('코스믹 데이지', '🌼'),
  _BloomSpec('미드나잇 아이리스', '🌺'),
  _BloomSpec('홀로그램 라넌큘러스', '🌼'),
  _BloomSpec('아우로라 라일락', '💠'),
  _BloomSpec('메탈릭 포피', '🌺'),
];

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onPressed,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: Colors.white),
              ),
              if (badge > 0)
                Positioned(
                  right: -2,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.neonPink,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$badge',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
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

class _FloatingFlowerFieldState extends State<_FloatingFlowerField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late List<_FlowerParticle> _particles;
  final Map<String, Offset> _dragOffsets = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _particles = _generateParticles(widget.letters);
  }

  @override
  void didUpdateWidget(covariant _FloatingFlowerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _particles = _generateParticles(widget.letters);
    _cleanupDragOffsets();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<_FlowerParticle> _generateParticles(List<Letter> letters) {
    if (letters.isEmpty) return [];
    final random = math.Random();
    return letters.map((letter) {
      return _FlowerParticle(
        letter: letter,
        base: Offset(random.nextDouble(), random.nextDouble()),
        amplitude: random.nextDouble() * 0.08 + 0.02,
        scale: random.nextDouble() * 0.5 + 0.6,
        phase: random.nextDouble(),
        speed: random.nextDouble() * 0.6 + 0.4,
      );
    }).toList();
  }

  double _wrap(double value) {
    final result = value % 1;
    return result < 0 ? result + 1 : result;
  }

  void _cleanupDragOffsets() {
    final ids = _particles.map((p) => p.letter.id).toSet();
    _dragOffsets.removeWhere((key, value) => !ids.contains(key));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Stack(
              children: [
                for (final particle in _particles)
                  _buildFlower(
                    context,
                    particle,
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFlower(
    BuildContext context,
    _FlowerParticle particle,
    double width,
    double height,
  ) {
    final time = _controller.value;
    final horizontal =
        (particle.base.dx +
                math.sin((time + particle.phase) * 2 * math.pi) *
                    particle.amplitude)
            .clamp(0.05, 0.95);
    final travel = _wrap(
      particle.base.dy + time * particle.speed + particle.phase,
    );
    var left = horizontal * width;
    var top = travel * height;
    final dragOffset = _dragOffsets[particle.letter.id] ?? Offset.zero;
    left = (left + dragOffset.dx).clamp(16.0, math.max(width - 16.0, 16.0));
    top = (top + dragOffset.dy).clamp(80.0, math.max(height - 32.0, 80.0));
    final rotation = math.sin((time + particle.phase) * 2 * math.pi) * 0.4;

    return Positioned(
      left: left,
      top: top,
      child: Transform.rotate(
        angle: rotation,
        child: GestureDetector(
          onTap: () => widget.onTap(particle.letter),
          onPanUpdate: (details) {
            setState(() {
              final current = _dragOffsets[particle.letter.id] ?? Offset.zero;
              _dragOffsets[particle.letter.id] = current + details.delta;
            });
          },
          child: _SeedOrb(letter: particle.letter, scale: particle.scale),
        ),
      ),
    );
  }
}

class _SeedOrb extends StatelessWidget {
  const _SeedOrb({required this.letter, required this.scale});

  final Letter? letter;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final size = 52.0 * scale;
    return Semantics(
      label: letter != null ? '${letter!.flower.label} 씨앗' : '씨앗',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: size,
        height: size,
        child: SvgPicture.asset(
          'assets/svg/seed_bubble.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}


class _SeedBloomOverlay extends StatefulWidget {
  const _SeedBloomOverlay({
    required this.letter,
    required this.bloomFlower,
  });

  final Letter letter;
  final _BloomSpec bloomFlower;

  @override
  State<_SeedBloomOverlay> createState() => _SeedBloomOverlayState();
}

class _SeedBloomOverlayState extends State<_SeedBloomOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  )..repeat(reverse: true);
  bool _isBlooming = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleBloom() async {
    if (_isBlooming) return;
    setState(() => _isBlooming = true);
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: const Color(0xCC060018),
              border: Border.all(color: Colors.white12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 30,
                  spreadRadius: 8,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final scale = 1 + (_controller.value * 0.08);
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: _SeedOrb(
                    letter: widget.letter,
                    scale: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '씨앗을 꽃피워볼까요?',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  '${widget.bloomFlower.name}이 피어나면 편지를 볼 수 있어요.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isBlooming ? null : _handleBloom,
                  icon: const Icon(Icons.auto_awesome),
                  label: Text(_isBlooming ? '꽃 피우는 중...' : '꽃 피우기'),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.bloomFlower.emoji,
                  style: const TextStyle(fontSize: 36),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FlowerParticle {
  const _FlowerParticle({
    required this.letter,
    required this.base,
    required this.amplitude,
    required this.scale,
    required this.phase,
    required this.speed,
  });

  final Letter letter;
  final Offset base;
  final double amplitude;
  final double scale;
  final double phase;
  final double speed;
}

class _FlowerAvatar extends StatelessWidget {
  const _FlowerAvatar({required this.type});
  final FlowerType type;

  @override
  Widget build(BuildContext context) {
    final colors = {
      FlowerType.rose: AppColors.neonPink,
      FlowerType.tulip: AppColors.neonPurple,
      FlowerType.sakura: AppColors.neonCyan,
      FlowerType.sunflower: AppColors.cyberYellow,
      FlowerType.daisy: Colors.white,
      FlowerType.lavender: AppColors.neonBlue,
    };

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors[type]!.withAlpha(120), colors[type]!.withAlpha(40)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: type.asset != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(type.asset!, fit: BoxFit.contain),
            )
          : Center(
              child: Text(type.emoji, style: const TextStyle(fontSize: 28)),
            ),
    );
  }
}


class _LetterAction extends StatelessWidget {
  const _LetterAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withAlpha(30),
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}

Color _contrastOn(Color background) {
  final luminance = background.computeLuminance();
  return luminance > 0.6 ? AppColors.midnight : Colors.white;
}

