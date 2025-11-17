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
      title: 'Welcome to Taba',
      subtitle: '떠다니는 씨앗을 잡아 꽃을 피워보세요.',
      emoji: '🌱',
      gradient: AppColors.gradientHeroPink,
    ),
    _TutorialPage(
      title: 'Catch seeds',
      subtitle: '하늘에서 반짝이는 씨앗을 탭해 편지를 열어봐요.',
      emoji: '✨',
      gradient: AppColors.gradientHeroBlue,
    ),
    _TutorialPage(
      title: 'Bloom flowers',
      subtitle: '씨앗을 피워 꽃과 함께 마음을 주고받아요.',
      emoji: '🌸',
      gradient: AppColors.gradientSky,
    ),
    _TutorialPage(
      title: 'Your bouquet',
      subtitle: '좋아하는 편지를 모아 나만의 꽃다발을 만들어요.',
      emoji: '💐',
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: widget.onSkip, child: const Text('건너뛰기')),
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
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
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
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Spacer(),
                                    Text(page.emoji, style: const TextStyle(fontSize: 96)),
                                    const SizedBox(height: 16),
                                    Text(
                                      page.title,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.headlineSmall,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      page.subtitle,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                                    ),
                                    const Spacer(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(
                  children: [
                    Row(
                      children: List.generate(_pages.length, (i) {
                        final active = i == _index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: active ? 18 : 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white38,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                    const Spacer(),
                    IntrinsicWidth(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: _next,
                          child: Text(_index == _pages.length - 1 ? '시작하기' : '다음'),
                        ),
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
    required this.gradient,
  });

  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
}
