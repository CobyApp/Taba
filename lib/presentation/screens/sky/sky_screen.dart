import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/presentation/screens/common/letter_detail_screen.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/empty_state.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class SkyScreen extends StatefulWidget {
  const SkyScreen({
    super.key,
    required this.letters,
    required this.notifications,
    this.unreadBouquetCount = 0,
    this.onOpenBouquet,
    this.onOpenSettings,
    this.onRefresh,
    this.onLoadMore,
    this.floatingActionButton,
  });

  final List<Letter> letters;
  final List<NotificationItem> notifications;
  final int unreadBouquetCount;
  final VoidCallback? onOpenBouquet;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onRefresh;
  final Future<List<Letter>> Function(int page)? onLoadMore;
  final Widget? floatingActionButton;

  @override
  State<SkyScreen> createState() => _SkyScreenState();
}

class _SkyScreenState extends State<SkyScreen> {
  static final _random = math.Random();
  late PageController _pageController;
  final List<Letter> _allLetters = [];
  final Map<int, List<Letter>> _pageLetters = {}; // 페이지별 편지 목록
  int _currentPage = 0;
  bool _isLoadingMore = false;
  bool _hasMorePages = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _allLetters.addAll(widget.letters);
    _pageLetters[0] = List.from(widget.letters);
    // 초기 데이터가 있으면 다음 페이지가 있다고 가정
    _hasMorePages = widget.letters.length >= 20;
  }

  @override
  void didUpdateWidget(covariant SkyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 첫 페이지 데이터가 업데이트되면 초기화
    if (oldWidget.letters != widget.letters && _currentPage == 0) {
      _allLetters.clear();
      _allLetters.addAll(widget.letters);
      _pageLetters.clear();
      _pageLetters[0] = List.from(widget.letters);
      _hasMorePages = widget.letters.length >= 20;
      _currentPage = 0;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadPage(int pageIndex) async {
    // 이미 로드된 페이지면 스킵
    if (_pageLetters.containsKey(pageIndex)) return;
    
    // 로딩 중이면 스킵
    if (_isLoadingMore) return;
    
    // 더 불러올 페이지가 없으면 스킵
    if (!_hasMorePages && pageIndex > 0) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      List<Letter> newLetters = [];
      
      if (widget.onLoadMore != null) {
        // API에서 다음 페이지 로드
        newLetters = await widget.onLoadMore!(pageIndex);
      } else {
        // onLoadMore가 없으면 기존 데이터에서 가져오기
        const itemsPerPage = 20;
        final startIndex = pageIndex * itemsPerPage;
        if (startIndex < _allLetters.length) {
          final endIndex = (startIndex + itemsPerPage < _allLetters.length)
              ? startIndex + itemsPerPage
              : _allLetters.length;
          newLetters = _allLetters.sublist(startIndex, endIndex);
        }
      }
      
      if (mounted) {
        setState(() {
          _pageLetters[pageIndex] = newLetters;
          // 중복 제거하여 추가
          final existingIds = _allLetters.map((l) => l.id).toSet();
          final uniqueNewLetters = newLetters.where((l) => !existingIds.contains(l.id)).toList();
          _allLetters.addAll(uniqueNewLetters);
          // 20개 미만이면 마지막 페이지
          _hasMorePages = newLetters.length >= 20;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
          _hasMorePages = false; // 에러 발생 시 더 이상 시도하지 않음
        });
        print('페이지 로드 실패: $e');
      }
    }
  }

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
    final gradientGradient = _gradientForNow();
    final gradientColors = gradientGradient.colors;

    return GradientScaffold(
      gradient: gradientColors,
      floatingActionButton: widget.floatingActionButton,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ValueListenableBuilder<Locale>(
              valueListenable: AppLocaleController.localeNotifier,
              builder: (context, locale, _) {
                return NavHeader(
                  child: Text(
                    AppStrings.appName,
                    style: GoogleFonts.pressStart2p().copyWith(
                      fontSize: 20,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  actions: [
                    if (widget.onOpenBouquet != null)
                      NavIconButton(
                        icon: Icons.local_florist_outlined,
                        tooltip: AppStrings.myBouquetTooltip(locale),
                        onPressed: widget.onOpenBouquet!,
                        badge: widget.unreadBouquetCount,
                      ),
                    if (widget.onOpenSettings != null)
                      NavIconButton(
                        icon: Icons.settings_outlined,
                        tooltip: AppStrings.settingsTooltip(locale),
                        onPressed: widget.onOpenSettings!,
                      ),
                  ],
                );
              },
            ),
            Expanded(
              child: ValueListenableBuilder<Locale>(
                valueListenable: AppLocaleController.localeNotifier,
                builder: (context, locale, _) {
                  return widget.letters.isEmpty
                      ? EmptyState(
                          icon: Icons.cloud_outlined,
                          title: AppStrings.mainScreenEmptyTitle(locale),
                          subtitle: AppStrings.mainScreenEmptySubtitle(locale),
                          action: widget.onRefresh != null
                              ? TabaButton(
                                  onPressed: widget.onRefresh,
                                  label: AppStrings.refreshButton(locale),
                                  icon: Icons.refresh,
                                  isFullWidth: false,
                                )
                              : null,
                        )
                  : PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        _currentPage = page;
                        // 다음 페이지와 그 다음 페이지 미리 로드
                        _loadPage(page + 1);
                        if (_hasMorePages) {
                          _loadPage(page + 2);
                        }
                      },
                      itemBuilder: (context, index) {
                        // 페이지가 로드되지 않았으면 로드 시도
                        if (!_pageLetters.containsKey(index)) {
                          _loadPage(index);
                        }
                        
                        final pageLetters = _pageLetters[index] ?? [];
                        
                        // 로딩 중이면 로딩 인디케이터 표시
                        if (pageLetters.isEmpty && _isLoadingMore && index > 0) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                            ),
                          );
                        }
                        
                        return _SkyCanvas(
                          letters: pageLetters,
                          onTap: (letter) => _openSeedBloom(context, letter),
                        );
                      },
                      itemCount: _hasMorePages 
                          ? _pageLetters.length + 1  // 다음 페이지가 있으면 +1
                          : _pageLetters.length > 0 
                              ? _pageLetters.length 
                              : 1,  // 최소 1페이지는 있어야 함
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSeedBloom(BuildContext context, Letter letter) async {
    final locale = AppLocaleController.localeNotifier.value;
    final bloomFlower = _bloomCatalog[_random.nextInt(_bloomCatalog.length)];
    final shouldOpen = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'seed',
      barrierColor: Colors.black.withAlpha(220),
      pageBuilder: (context, animation, secondaryAnimation) {
        return _SeedBloomOverlay(
          letter: letter,
          bloomFlower: bloomFlower,
          locale: locale,
        );
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
            child: LetterDetailScreen(
              letter: letter,
              friendName: letter.isAnonymous ? null : letter.sender.nickname,
            ),
          );
        },
      ),
    );
  }
}

/// 하늘 캔버스 - 씨앗들이 고정 위치에 배치됨
class _SkyCanvas extends StatefulWidget {
  const _SkyCanvas({
    required this.letters,
    required this.onTap,
  });

  final List<Letter> letters;
  final ValueChanged<Letter> onTap;

  @override
  State<_SkyCanvas> createState() => _SkyCanvasState();
}

class _SkyCanvasState extends State<_SkyCanvas> {
  late List<_StarDot> _stars;
  
  @override
  void initState() {
    super.initState();
    // 초기화 시 한 번만 별 생성
    _stars = [];
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        
        // 별이 아직 생성되지 않았거나 화면 크기가 변경된 경우에만 생성
        if (_stars.isEmpty || 
            (_stars.isNotEmpty && 
             (_stars.first.width != width || _stars.first.height != height))) {
          _stars = _generateBackgroundDots(width, height);
        }
        
        return Stack(
          children: [
            // 배경 장식
            ..._stars.map((star) => Positioned(
              left: star.x,
              top: star.y,
              child: Container(
                width: star.size,
                height: star.size,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(star.alpha),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha(star.alpha ~/ 2),
                      blurRadius: star.size * 2.5,
                      spreadRadius: star.size * 0.8,
                    ),
                  ],
                ),
              ),
            )).toList(),
            // 고정된 씨앗들
            ...widget.letters.map((letter) {
              final position = _getFixedPosition(letter.id, width, height);
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onTap: () => widget.onTap(letter),
                  child: _SeedOrb(letter: letter),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // 편지 ID 기반으로 고정 위치 계산 (같은 ID면 항상 같은 위치)
  Offset _getFixedPosition(String letterId, double width, double height) {
    final hash = letterId.hashCode;
    final random = math.Random(hash);
    
    // 화면에서 안전한 영역 내의 고정 위치
    final x = 32 + (random.nextDouble() * (width - 120));
    final y = 120 + (random.nextDouble() * (height - 200));
    
    return Offset(x, y);
  }

  List<_StarDot> _generateBackgroundDots(double width, double height) {
    final dots = <_StarDot>[];
    // 더 랜덤한 별 생성을 위해 여러 시드 사용
    final baseSeed = DateTime.now().millisecondsSinceEpoch;
    final random = math.Random(baseSeed);
    final count = random.nextInt(15) + 10; // 10~24개의 별 생성
    
    for (int i = 0; i < count; i++) {
      // 각 별마다 약간씩 다른 시드를 사용
      final starRandom = math.Random(baseSeed + i * 137);
      final x = starRandom.nextDouble() * width;
      final y = starRandom.nextDouble() * height;
      final alpha = starRandom.nextInt(60) + 20; // 20~79 범위의 투명도
      final size = starRandom.nextDouble() * 14 + 2; // 2~16 크기 범위
      
      dots.add(_StarDot(
        x: x,
        y: y,
        size: size,
        alpha: alpha,
        width: width,
        height: height,
      ));
    }
    
    return dots;
  }
}

class _StarDot {
  const _StarDot({
    required this.x,
    required this.y,
    required this.size,
    required this.alpha,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double size;
  final int alpha;
  final double width;
  final double height;
}

class _SeedOrb extends StatelessWidget {
  const _SeedOrb({required this.letter});

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocaleController.localeNotifier.value;
    return Semantics(
      label: '씨앗',
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SvgPicture.asset(
          'assets/svg/seed_bubble.svg',
          fit: BoxFit.contain,
        ),
      ),
    );
  }
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

class _SeedBloomOverlay extends StatefulWidget {
  const _SeedBloomOverlay({
    required this.letter,
    required this.bloomFlower,
    required this.locale,
  });

  final Letter letter;
  final _BloomSpec bloomFlower;
  final Locale locale;

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
  late final String _randomMessage;

  @override
  void initState() {
    super.initState();
    _randomMessage = _getRandomBloomMessage(widget.locale);
  }

  String _getRandomBloomMessage(Locale locale) {
    final messages = [
      '씨앗으로부터 꽃을 피워볼까요?',
      '이 씨앗에서 아름다운 꽃이 피어날 거예요',
      '씨앗을 열어 꽃을 만나보세요',
      '작은 씨앗에서 큰 꽃이 피어나요',
      '씨앗 속에 숨겨진 꽃을 발견해보세요',
    ];
    final random = DateTime.now().millisecondsSinceEpoch % messages.length;
    return messages[random];
  }

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
    return Stack(
      children: [
        // 배경 탭 시 닫기
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(false),
            child: Container(color: Colors.transparent),
          ),
        ),
        // 모달 컨텐츠
        Center(
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
                    // 왼쪽 위 닫기 버튼
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 24,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
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
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _randomMessage,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    // 부가 설명 제거
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _isBlooming ? null : _handleBloom,
                      icon: const Icon(Icons.auto_awesome),
                      label: Text(
                        _isBlooming 
                            ? AppStrings.blooming(widget.locale)
                            : AppStrings.bloomButton(widget.locale),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
