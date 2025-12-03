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
import 'package:taba_app/presentation/widgets/app_logo.dart';
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
    this.onLoadMoreWithPagination,
    this.onLanguageFilterChanged,
    this.onUserBlocked,
    this.floatingActionButton,
  });

  final List<Letter> letters;
  final List<NotificationItem> notifications;
  final int unreadBouquetCount;
  final VoidCallback? onOpenBouquet;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onRefresh;
  final Future<List<Letter>> Function(int page)? onLoadMore;
  final Future<({List<Letter> letters, bool hasMore})> Function(int page)? onLoadMoreWithPagination;
  final Function(List<String>)? onLanguageFilterChanged;
  final Function(String blockedUserId)? onUserBlocked; // 사용자 차단 시 콜백
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
  // 읽음 상태 오버라이드: 편지 ID -> 읽음 상태 (true: 읽음, false: 읽지 않음)
  final Map<String, bool> _readStatusOverrides = {};
  // 차단된 사용자 ID 목록 (즉시 필터링용)
  final Set<String> _blockedUserIds = {};

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _allLetters.addAll(widget.letters);
    // 한 페이지에 10개씩 표시
    _pageLetters[0] = widget.letters.take(10).toList();
    // 초기 데이터가 있으면 다음 페이지가 있다고 가정
    _hasMorePages = widget.letters.length >= 10;
  }

  @override
  void didUpdateWidget(covariant SkyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 첫 페이지 데이터가 업데이트되면 초기화
    if (oldWidget.letters != widget.letters && _currentPage == 0) {
      _allLetters.clear();
      _allLetters.addAll(widget.letters);
      _pageLetters.clear();
      // 한 페이지에 10개씩 표시
      _pageLetters[0] = widget.letters.take(10).toList();
      _hasMorePages = widget.letters.length >= 10;
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
      bool hasMore = false;
      
      if (widget.onLoadMoreWithPagination != null) {
        // 페이징 정보를 포함한 API 호출
        final result = await widget.onLoadMoreWithPagination!(pageIndex);
        newLetters = result.letters;
        hasMore = result.hasMore;
      } else if (widget.onLoadMore != null) {
        // 기존 방식 (하위 호환성)
        newLetters = await widget.onLoadMore!(pageIndex);
        // 10개 미만이면 마지막 페이지로 간주
        hasMore = newLetters.length >= 10;
      } else {
        // onLoadMore가 없으면 기존 데이터에서 가져오기
        const itemsPerPage = 10; // 한 페이지에 10개
        final startIndex = pageIndex * itemsPerPage;
        if (startIndex < _allLetters.length) {
          final endIndex = (startIndex + itemsPerPage < _allLetters.length)
              ? startIndex + itemsPerPage
              : _allLetters.length;
          newLetters = _allLetters.sublist(startIndex, endIndex);
          hasMore = endIndex < _allLetters.length;
        } else {
          hasMore = false;
        }
      }
      
      if (mounted) {
        setState(() {
          _pageLetters[pageIndex] = newLetters;
          // 중복 제거하여 추가
          final existingIds = _allLetters.map((l) => l.id).toSet();
          final uniqueNewLetters = newLetters.where((l) => !existingIds.contains(l.id)).toList();
          _allLetters.addAll(uniqueNewLetters);
          // PageResponse의 last 필드를 사용하여 더 불러올 페이지가 있는지 확인
          _hasMorePages = hasMore;
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
                  child: AppLogo(
                    fontSize: 20,
                    letterSpacing: 2,
                    color: Colors.white,
                    shadows: [], // NavHeader에서는 그림자 제거
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
                      ? Align(
                          alignment: Alignment.topCenter,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.12 - 40,
                            ),
                            child: EmptyState(
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
                            ),
                          ),
                        )
                  : NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        // 스크롤 진행률에 따라 다음 페이지 미리 로드
                        if (notification is ScrollUpdateNotification) {
                          final position = _pageController.position;
                          if (position.hasPixels && position.hasContentDimensions) {
                            final page = _pageController.page?.round() ?? 0;
                            final progress = (position.pixels / position.maxScrollExtent).clamp(0.0, 1.0);
                            
                            // 현재 페이지가 변경되면 다음 페이지들 미리 로드
                            if (page != _currentPage) {
                              _currentPage = page;
                              // 빌드 완료 후 로드
                              Future.microtask(() {
                                if (mounted) {
                                  _loadPage(page + 1);
                                  if (_hasMorePages) {
                                    _loadPage(page + 2);
                                  }
                                }
                              });
                            }
                            
                            // 스크롤이 80% 이상 진행되면 다음 페이지 미리 로드
                            if (progress > 0.8 && _hasMorePages && !_isLoadingMore) {
                              final nextPage = page + 1;
                              if (!_pageLetters.containsKey(nextPage)) {
                                Future.microtask(() {
                                  if (mounted) {
                                    _loadPage(nextPage);
                                  }
                                });
                              }
                            }
                          }
                        }
                        return false;
                      },
                      child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        _currentPage = page;
                          // 다음 페이지와 그 다음 페이지 미리 로드 (빌드 완료 후)
                          Future.microtask(() {
                            if (mounted) {
                        _loadPage(page + 1);
                        if (_hasMorePages) {
                          _loadPage(page + 2);
                        }
                            }
                          });
                      },
                      itemBuilder: (context, index) {
                        // 페이지가 로드되지 않았으면 빌드 완료 후 로드 시도
                        if (!_pageLetters.containsKey(index)) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted && !_pageLetters.containsKey(index)) {
                          _loadPage(index);
                            }
                          });
                        }
                        
                        final pageLetters = _pageLetters[index] ?? [];
                        
                        // 로딩 중이면 로딩 인디케이터 표시
                        if (pageLetters.isEmpty && (_isLoadingMore || index > 0)) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white70,
                            ),
                          );
                        }
                        
                        return _SkyCanvas(
                          letters: pageLetters,
                          readStatusOverrides: _readStatusOverrides,
                          onTap: (letter) => _openSeedBloom(context, letter),
                        );
                      },
                      itemCount: _hasMorePages 
                          ? _pageLetters.length + 1  // 다음 페이지가 있으면 +1
                          : _pageLetters.length > 0 
                              ? _pageLetters.length 
                              : 1,  // 최소 1페이지는 있어야 함
                      ),
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
        );
      },
    );
    if (shouldOpen == true && context.mounted) {
      _openLetterPreview(context, letter);
    }
  }

  Future<void> _openLetterPreview(BuildContext context, Letter letter) async {
    final result = await Navigator.of(context).push(
      PageRouteBuilder<dynamic>(
        opaque: false,
        barrierColor: Colors.black.withAlpha(204),
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            child: LetterDetailScreen(
              letter: letter,
              friendName: letter.sender.nickname,
            ),
          );
        },
      ),
    );
    
    // 결과 처리
    if (result == null) return;
    
    // 차단된 경우 처리
    if (result is Map && result['blocked'] == true) {
      final blockedUserId = result['blockedUserId'] as String?;
      if (blockedUserId != null) {
        setState(() {
          // 차단된 사용자 ID 추가
          _blockedUserIds.add(blockedUserId);
          
          // 해당 사용자의 편지를 모든 페이지에서 제거
          _allLetters.removeWhere((l) => l.sender.id == blockedUserId);
          for (final pageIndex in _pageLetters.keys.toList()) {
            _pageLetters[pageIndex] = _pageLetters[pageIndex]!
                .where((l) => l.sender.id != blockedUserId)
                .toList();
          }
          
          // 위치 캐시 초기화 (재계산 필요)
        });
        
        // 부모에게 차단 알림
        widget.onUserBlocked?.call(blockedUserId);
      }
      return;
    }
    
    // 편지를 읽었거나 삭제되었으면 해당 편지의 읽음 상태만 업데이트
    // 전체 새로고침 대신 해당 편지만 꽃으로 표시
    if (result == true) {
      // 편지를 읽었으므로 읽음 상태를 true로 설정
      setState(() {
        _readStatusOverrides[letter.id] = true;
      });
    }
  }
}

/// 하늘 캔버스 - 씨앗들이 고정 위치에 배치됨
class _SkyCanvas extends StatefulWidget {
  const _SkyCanvas({
    required this.letters,
    required this.readStatusOverrides,
    required this.onTap,
  });

  final List<Letter> letters;
  final Map<String, bool> readStatusOverrides; // 읽음 상태 오버라이드
  final ValueChanged<Letter> onTap;

  @override
  State<_SkyCanvas> createState() => _SkyCanvasState();
}

class _SkyCanvasState extends State<_SkyCanvas> {
  late List<_StarDot> _stars;
  Map<String, Offset>? _positionCache; // 편지 위치 캐시
  double? _cachedWidth;
  double? _cachedHeight;
  
  @override
  void initState() {
    super.initState();
    // 초기화 시 한 번만 별 생성
    _stars = [];
    _positionCache = null;
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
        
        // 화면 크기가 변경되면 전체 위치 재계산
        if (_positionCache == null || 
            _cachedWidth != width || 
            _cachedHeight != height) {
          _positionCache = _calculateAllPositions(widget.letters, width, height);
          _cachedWidth = width;
          _cachedHeight = height;
        } else {
          // 화면 크기가 같으면, 캐시에 없는 새 편지만 위치 계산
          // (기존 편지들은 필터링되어도 원래 위치 유지)
          _addPositionsForNewLetters(widget.letters, width, height);
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
            // 고정된 씨앗들 (겹치지 않게 배치)
            // API 명세서: isRead 필드 (true: 읽음, false: 읽지 않음, null: 작성자인 경우 또는 비로그인 사용자)
            ...widget.letters.map((letter) {
              final position = _positionCache![letter.id] ?? Offset(0, 0);
              // 읽음 상태 확인: 오버라이드가 있으면 우선 사용, 없으면 원본 isRead 사용
              final isRead = widget.readStatusOverrides.containsKey(letter.id)
                  ? widget.readStatusOverrides[letter.id] == true
                  : letter.isRead == true;
              return Positioned(
                left: position.dx,
                top: position.dy,
                child: GestureDetector(
                  onTap: () => widget.onTap(letter),
                  child: isRead 
                      ? _FlowerOrb(letter: letter)
                      : _SeedOrb(letter: letter),
                ),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  // 모든 편지의 위치를 한 번에 계산하여 겹치지 않게 배치
  Map<String, Offset> _calculateAllPositions(List<Letter> allLetters, double width, double height) {
    final positions = <String, Offset>{};
    
    // 씨앗 크기와 최소 간격
    const seedSize = 56.0;
    const seedRadius = seedSize / 2; // 28px
    const shadowBlur = 12.0; // boxShadow blurRadius
    const shadowOffset = 4.0; // boxShadow offset y
    const extraPadding = 24.0; // 추가 여유 공간
    
    // 실제 씨앗이 차지하는 공간 (반지름 + shadow blur + 여유)
    final effectiveRadius = seedRadius + shadowBlur + extraPadding;
    const minDistance = seedSize + 20.0; // 씨앗 크기 + 여유 공간
    
    // 안전한 영역 (상하좌우 여유 공간 - 화면 밖으로 나가지 않도록)
    final safeArea = EdgeInsets.only(
      left: effectiveRadius,  // 씨앗 반지름 + shadow + 여유
      top: 120.0,
      right: effectiveRadius,
      bottom: 200.0,
    );
    
    final availableWidth = width - safeArea.left - safeArea.right;
    final availableHeight = height - safeArea.top - safeArea.bottom;
    
    // 최대 시도 횟수 증가
    const maxAttempts = 500;
    
    // 각 편지에 대해 겹치지 않는 위치 찾기
    for (final letter in allLetters) {
      final hash = letter.id.hashCode;
    final random = math.Random(hash);
    
      Offset? bestPosition;
      double bestDistance = 0;
      
      // 겹치지 않는 위치 찾기
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final x = safeArea.left + (random.nextDouble() * availableWidth);
        final y = safeArea.top + (random.nextDouble() * availableHeight);
        final candidate = Offset(x, y);
        
        // 화면 경계 체크 (씨앗 + shadow가 화면 밖으로 나가지 않도록)
        if (x < effectiveRadius || x > width - effectiveRadius ||
            y < effectiveRadius || y > height - effectiveRadius) {
          continue;
        }
        
        // 기존 위치들과 겹치는지 확인
        bool overlaps = false;
        double minDistToExisting = double.infinity;
        
        for (final existingPos in positions.values) {
          final distance = (candidate - existingPos).distance;
          minDistToExisting = math.min(minDistToExisting, distance);
          if (distance < minDistance) {
            overlaps = true;
            break;
          }
        }
        
        if (!overlaps) {
          // 겹치지 않는 위치를 찾았으면 바로 사용
          positions[letter.id] = candidate;
          bestPosition = null; // 더 이상 필요 없음
          break;
        }
        
        // 겹치지만, 가장 멀리 떨어진 위치를 저장 (최후의 수단)
        if (bestPosition == null || minDistToExisting > bestDistance) {
          bestPosition = candidate;
          bestDistance = minDistToExisting;
        }
      }
      
      // 최대 시도 횟수 내에 겹치지 않는 위치를 찾지 못한 경우
      // 최선의 위치 사용
      if (!positions.containsKey(letter.id)) {
        if (bestPosition != null) {
          positions[letter.id] = bestPosition;
        } else {
          // 완전 실패한 경우 (거의 없어야 함)
          final hash = letter.id.hashCode;
          final random = math.Random(hash);
          final x = safeArea.left + (random.nextDouble() * availableWidth);
          final y = safeArea.top + (random.nextDouble() * availableHeight);
          positions[letter.id] = Offset(x, y);
        }
      }
    }
    
    return positions;
  }

  // 캐시에 없는 새 편지만 위치를 추가 (기존 위치는 유지)
  void _addPositionsForNewLetters(List<Letter> allLetters, double width, double height) {
    if (_positionCache == null) return;
    
    // 캐시에 없는 편지 찾기
    final newLetters = allLetters.where((letter) => !_positionCache!.containsKey(letter.id)).toList();
    if (newLetters.isEmpty) return;
    
    // 씨앗 크기와 최소 간격
    const seedSize = 56.0;
    const seedRadius = seedSize / 2;
    const shadowBlur = 12.0;
    const extraPadding = 24.0;
    
    final effectiveRadius = seedRadius + shadowBlur + extraPadding;
    const minDistance = seedSize + 20.0;
    
    final safeArea = EdgeInsets.only(
      left: effectiveRadius,
      top: 120.0,
      right: effectiveRadius,
      bottom: 200.0,
    );
    
    final availableWidth = width - safeArea.left - safeArea.right;
    final availableHeight = height - safeArea.top - safeArea.bottom;
    
    const maxAttempts = 500;
    
    for (final letter in newLetters) {
      final hash = letter.id.hashCode;
      final random = math.Random(hash);
      
      Offset? bestPosition;
      double bestDistance = 0;
      
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        final x = safeArea.left + (random.nextDouble() * availableWidth);
        final y = safeArea.top + (random.nextDouble() * availableHeight);
        final candidate = Offset(x, y);
        
        if (x < effectiveRadius || x > width - effectiveRadius ||
            y < effectiveRadius || y > height - effectiveRadius) {
          continue;
        }
        
        bool overlaps = false;
        double minDistToExisting = double.infinity;
        
        for (final existingPos in _positionCache!.values) {
          final distance = (candidate - existingPos).distance;
          minDistToExisting = math.min(minDistToExisting, distance);
          if (distance < minDistance) {
            overlaps = true;
            break;
          }
        }
        
        if (!overlaps) {
          _positionCache![letter.id] = candidate;
          bestPosition = null;
          break;
        }
        
        if (bestPosition == null || minDistToExisting > bestDistance) {
          bestPosition = candidate;
          bestDistance = minDistToExisting;
        }
      }
      
      if (!_positionCache!.containsKey(letter.id)) {
        if (bestPosition != null) {
          _positionCache![letter.id] = bestPosition;
        } else {
          final x = safeArea.left + (random.nextDouble() * availableWidth);
          final y = safeArea.top + (random.nextDouble() * availableHeight);
          _positionCache![letter.id] = Offset(x, y);
        }
      }
    }
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
      label: AppStrings.seed(locale),
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

class _FlowerOrb extends StatelessWidget {
  const _FlowerOrb({required this.letter});

  final Letter letter;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocaleController.localeNotifier.value;
    return Semantics(
      label: AppStrings.flower(locale),
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
          'assets/svg/flower_bloom.svg',
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
  late final String _message; // 멘트를 한 번만 선택하고 고정

  @override
  void initState() {
    super.initState();
    // 초기화 시 한 번만 랜덤 메시지 선택
    final locale = AppLocaleController.localeNotifier.value;
    final messages = AppStrings.bloomSeedMessages(locale);
    final random = DateTime.now().millisecondsSinceEpoch % messages.length;
    _message = messages[random];
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
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
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
                          _message, // 고정된 멘트 사용
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
                                ? AppStrings.blooming(locale)
                                : AppStrings.bloomButton(locale),
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
      },
    );
  }
}
