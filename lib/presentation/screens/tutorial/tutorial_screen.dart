import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';

class TutorialScreen extends StatefulWidget {
  const TutorialScreen({
    super.key,
    required this.onFinish,
    required this.onSkip,
  });

  final VoidCallback onFinish;
  final VoidCallback onSkip;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _controller = PageController();
  int _index = 0;

  final List<_TutorialPage> _pages = const [
    _TutorialPage(
      title: 'Neon Lettering',
      subtitle: '편지를 꽃으로 변환해 밤하늘로 날려보내요.',
      emoji: '🌸',
      badge: 'WELCOME',
      gradient: AppColors.gradientHeroPink,
    ),
    _TutorialPage(
      title: 'Make It Retro',
      subtitle: 'Y2K 템플릿, 픽셀 폰트, 스티커로 마음껏 꾸며보세요.',
      emoji: '💌',
      badge: 'STEP 1',
      gradient: AppColors.gradientHeroBlue,
    ),
    _TutorialPage(
      title: 'Catch Floating Letters',
      subtitle: '하늘에 떠다니는 꽃을 탭해 익명의 편지를 읽어봐요.',
      emoji: '🌈',
      badge: 'STEP 2',
      gradient: AppColors.gradientSky,
    ),
    _TutorialPage(
      title: 'Curate Your Bouquet',
      subtitle: '마음에 드는 편지를 모아 나만의 꽃다발을 완성하세요.',
      emoji: '💐',
      badge: 'FINAL',
      gradient: AppColors.gradientDusk,
    ),
  ];

  void _next() {
    if (_index == _pages.length - 1) {
      widget.onFinish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.gradientGalaxy,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'Neo Tutorial',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: widget.onSkip,
                      child: const Text('SKIP'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final page = _pages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: page.gradient,
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(120),
                              blurRadius: 40,
                              offset: const Offset(0, 20),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(60),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(page.badge),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                page.title,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                page.subtitle,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  page.emoji,
                                  style: const TextStyle(fontSize: 96),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (_index + 1) / _pages.length,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.gradientHeroPink,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _next,
                      child: Text(
                        _index == _pages.length - 1 ? 'NEON SKY 입장' : 'NEXT',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TutorialPage {
  const _TutorialPage({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.badge,
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final String badge;
  final List<Color> gradient;
}
