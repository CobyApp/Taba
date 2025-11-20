import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';

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

  List<_TutorialPage> _getPages(Locale locale) {
    return [
      _TutorialPage(
        title: AppStrings.tutorialPage1Title(locale),
        subtitle: AppStrings.tutorialPage1Subtitle(locale),
        svgAsset: 'assets/svg/welcome_letter.svg', // 환영 - 편지 아이콘
      ),
      _TutorialPage(
        title: AppStrings.tutorialPage2Title(locale),
        subtitle: AppStrings.tutorialPage2Subtitle(locale),
        svgAsset: 'assets/svg/seed_bubble.svg', // 씨앗 잡기
      ),
      _TutorialPage(
        title: AppStrings.tutorialPage3Title(locale),
        subtitle: AppStrings.tutorialPage3Subtitle(locale),
        svgAsset: 'assets/svg/friendship_connection.svg', // 새로운 인연과 우정
      ),
    ];
  }

  void _next() {
    if (_index == _getPages(AppLocaleController.localeNotifier.value).length - 1) {
      widget.onFinish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0024), // 어두운 배경
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            final pages = _getPages(locale);
            
            return Column(
              children: [
                // 상단 스킵 버튼
                Padding(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: MediaQuery.of(context).padding.top + AppSpacing.md,
                    bottom: AppSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: widget.onSkip,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Text(
                          AppStrings.skipTutorial(locale),
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                // 페이지 뷰
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemCount: pages.length,
                    itemBuilder: (context, index) {
                      final page = pages[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.md,
                        ),
                        child: TabaCard(
                          padding: const EdgeInsets.all(AppSpacing.xl * 1.5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SVG 이미지
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF1A0016).withOpacity(0.3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withAlpha(100),
                                      blurRadius: 20,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: SvgPicture.asset(
                                      page.svgAsset,
                                      fit: BoxFit.contain,
                                      placeholderBuilder: (context) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Colors.white54,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xl * 1.5),
                              // 제목
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              // 부제목
                              Text(
                                page.subtitle,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // 하단 인디케이터 및 버튼
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: Column(
                    children: [
                      // 페이지 인디케이터
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(pages.length, (i) {
                          final active = i == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: active ? 24 : 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: active ? AppColors.neonPink : Colors.white.withAlpha(60),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // 다음/시작하기 버튼
                      TabaButton(
                        onPressed: _next,
                        label: _index == pages.length - 1
                            ? AppStrings.tutorialStart(locale)
                            : AppStrings.tutorialNext(locale),
                        icon: _index == pages.length - 1 ? Icons.auto_awesome : Icons.arrow_forward,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TutorialPage {
  const _TutorialPage({
    required this.title,
    required this.subtitle,
    required this.svgAsset,
  });

  final String title;
  final String subtitle;
  final String svgAsset;
}
