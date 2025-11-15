import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';

class SkyScreen extends StatelessWidget {
  const SkyScreen({
    super.key,
    required this.letters,
    required this.notifications,
  });

  final List<Letter> letters;
  final List<NotificationItem> notifications;

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
    final filters = [
      '전체',
      '장미 🌹',
      '튤립 🌷',
      '해바라기 🌻',
      '벚꽃 🌸',
      '데이지 🌼',
      '라벤더 💜',
    ];

    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withAlpha(77),
                    child: const Icon(
                      Icons.local_florist_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Letters to Neon Skies',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(fontSize: 22),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '지금 하늘은 레트로 글리치 모드예요. 떠다니는 꽃을 잡아 이야기를 열어보세요.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        onPressed: () => _openNotificationSheet(context),
                        icon: const Icon(
                          Icons.notifications_active_outlined,
                          color: Colors.white,
                        ),
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.neonPink,
                                AppColors.neonPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${notifications.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: filters.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final selected = index == 0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: selected
                          ? const LinearGradient(
                              colors: [
                                AppColors.neonPink,
                                AppColors.neonPurple,
                              ],
                            )
                          : null,
                      color: selected ? null : Colors.white.withAlpha(28),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: Colors.white.withAlpha(40)),
                    ),
                    child: Text(
                      filters[index],
                      style: TextStyle(
                        color: selected
                            ? Colors.white
                            : Colors.white.withAlpha(220),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        itemCount: letters.length,
                        itemBuilder: (context, index) {
                          final letter = letters[index];
                          return _FloatingFlowerCard(
                            letter: letter,
                            delay: index * 300,
                            onTap: () => _openLetterPreview(context, letter),
                          );
                        },
                      ),
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

  void _openNotificationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('알림 센터', style: Theme.of(context).textTheme.titleLarge),
                const Spacer(),
                const Icon(Icons.tune_rounded, color: Colors.white),
              ],
            ),
            const SizedBox(height: 18),
            ...notifications.map(
              (n) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.neonPink.withAlpha(60),
                  child: Text(
                    n.category.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(n.title),
                subtitle: Text('${n.subtitle} · ${n.timeAgo}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLetterPreview(BuildContext context, Letter letter) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LetterPreviewSheet(letter: letter),
    );
  }
}

class _FloatingFlowerCard extends StatefulWidget {
  const _FloatingFlowerCard({
    required this.letter,
    required this.delay,
    required this.onTap,
  });

  final Letter letter;
  final int delay;
  final VoidCallback onTap;

  @override
  State<_FloatingFlowerCard> createState() => _FloatingFlowerCardState();
}

class _FloatingFlowerCardState extends State<_FloatingFlowerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final offset = (_controller.value - 0.5) * 10;
        return Transform.translate(offset: Offset(0, offset), child: child);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withAlpha(30), Colors.white.withAlpha(12)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withAlpha(40)),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonPink.withAlpha(40),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                _FlowerAvatar(type: widget.letter.flower),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.letter.senderDisplay,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.letter.preview,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            widget.letter.timeAgo(),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
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

class _LetterPreviewSheet extends StatelessWidget {
  const _LetterPreviewSheet({required this.letter});

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: .62,
      maxChildSize: .95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 56,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _FlowerAvatar(type: letter.flower),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        letter.senderDisplay,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        '${letter.sentAt.year}.${letter.sentAt.month}.${letter.sentAt.day}  ·  ${letter.timeAgo()}',
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                letter.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: Container(
                    decoration: BoxDecoration(
                      color: letter.template?.background ?? Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.outline),
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      letter.content,
                      style: TextStyle(
                        color:
                            letter.template?.textColor ?? AppColors.textPrimary,
                        fontFamily: letter.template?.fontFamily,
                        fontSize: letter.template?.fontSize ?? 16,
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  _ActionButton(icon: Icons.favorite_border, label: '좋아요'),
                  _ActionButton(icon: Icons.reply, label: '답장'),
                  _ActionButton(
                    icon: Icons.local_florist_outlined,
                    label: '꽃다발',
                  ),
                  _ActionButton(icon: Icons.share, label: '공유'),
                  _ActionButton(icon: Icons.more_horiz, label: '더보기'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.card,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
