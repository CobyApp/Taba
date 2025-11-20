import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/empty_state.dart';
import 'package:taba_app/presentation/widgets/loading_indicator.dart';
import 'package:taba_app/presentation/widgets/bouquet/friend_story_strip.dart';
import 'package:taba_app/presentation/widgets/bouquet/chat_messages_list.dart';
import 'package:taba_app/presentation/widgets/bouquet/bouquet_detail_sheet.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/screens/write/write_letter_page.dart';
import 'package:taba_app/presentation/screens/common/letter_detail_screen.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class BouquetScreen extends StatefulWidget {
  const BouquetScreen({super.key, required this.friendBouquets});

  final List<FriendBouquet> friendBouquets;

  @override
  State<BouquetScreen> createState() => _BouquetScreenState();
}

class _BouquetScreenState extends State<BouquetScreen> {
  final _repository = DataRepository.instance;
  int _selectedIndex = 0;
  late Set<String> _readFlowerIds;
  final Map<String, String> _customBouquetNames = {};
  final Map<String, List<SharedFlower>> _loadedFlowers = {}; // 친구별 편지 목록 캐시
  final Map<String, bool> _loadingFlowers = {}; // 로딩 상태
  final Map<String, bool> _hasMorePages = {}; // 친구별 더 불러올 페이지가 있는지
  final Map<String, int> _currentPages = {}; // 친구별 현재 페이지 번호
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _readFlowerIds = {};
    // 초기 선택된 친구의 편지 목록 로드
    if (widget.friendBouquets.isNotEmpty) {
      _loadFriendLetters(widget.friendBouquets[_selectedIndex].friend.user.id, reset: true);
    }
    
    // 무한 스크롤을 위한 스크롤 리스너
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _onScroll() {
    // 스크롤 컨트롤러가 연결되어 있고 스크롤이 가능한 경우에만 처리
    if (!_scrollController.hasClients) return;
    
    final position = _scrollController.position;
    if (!position.hasContentDimensions) return;
    
    // 스크롤이 하단 근처(90%)에 도달하면 다음 페이지 로드
    final threshold = position.maxScrollExtent * 0.9;
    if (position.pixels >= threshold) {
      final friendId = _selectedBouquet.friend.user.id;
      final hasMore = _hasMorePages[friendId] ?? true; // 기본값 true
      final isLoading = _loadingFlowers[friendId] ?? false;
      
      if (hasMore && !isLoading) {
        _loadFriendLetters(friendId, reset: false);
      }
    }
  }

  FriendBouquet get _selectedBouquet => widget.friendBouquets[_selectedIndex];
  String _resolveBouquetName(FriendBouquet bouquet) =>
      _customBouquetNames[bouquet.friend.user.id] ?? bouquet.bouquetName;

  List<SharedFlower> get _selectedFlowers {
    final friendId = _selectedBouquet.friend.user.id;
    return _loadedFlowers[friendId] ?? [];
  }

  void _selectFriend(int index) {
    if (index == _selectedIndex) return;
    setState(() => _selectedIndex = index);
    // 선택된 친구의 편지 목록이 없으면 로드
    final friendId = widget.friendBouquets[index].friend.user.id;
    if (!_loadedFlowers.containsKey(friendId) && !(_loadingFlowers[friendId] ?? false)) {
      _loadFriendLetters(friendId, reset: true);
    }
  }

  Future<void> _loadFriendLetters(String friendId, {bool reset = false}) async {
    if (_loadingFlowers[friendId] == true) return;
    
    // 리셋인 경우 현재 페이지를 0으로 초기화
    if (reset) {
      _currentPages[friendId] = 0;
      _hasMorePages[friendId] = true;
      _loadedFlowers[friendId] = [];
    }
    
    final currentPage = _currentPages[friendId] ?? 0;
    final hasMore = _hasMorePages[friendId] ?? true;
    
    // 더 불러올 페이지가 없으면 중단
    if (!hasMore && !reset) return;
    
    setState(() => _loadingFlowers[friendId] = true);
    
    try {
      // 페이징 정보를 포함한 API 호출
      final result = await _repository.getFriendLettersWithPagination(
        friendId: friendId,
        page: currentPage,
        size: 20,
      );
      
      if (mounted) {
        setState(() {
          List<SharedFlower> sortedFlowers;
          
          if (reset) {
            sortedFlowers = result.flowers;
          } else {
            // 기존 목록에 추가 (중복 제거)
            final existingIds = _loadedFlowers[friendId]?.map((f) => f.id).toSet() ?? {};
            final newFlowers = result.flowers.where((f) => !existingIds.contains(f.id)).toList();
            sortedFlowers = [...(_loadedFlowers[friendId] ?? []), ...newFlowers];
          }
          
          // 정렬: 첫 공개편지가 맨 위에 오도록
          sortedFlowers = _sortFlowersWithPublicFirst(sortedFlowers);
          
          _loadedFlowers[friendId] = sortedFlowers;
          
          // 페이지네이션 정보 업데이트
          _currentPages[friendId] = currentPage + 1;
          
          // PageResponse의 last 필드를 사용하여 더 불러올 페이지가 있는지 확인
          _hasMorePages[friendId] = result.hasMore;
          
          print('📄 편지 페이징: friendId=$friendId, page=$currentPage, loaded=${result.flowers.length}개, hasMore=${result.hasMore}');
          
          _loadingFlowers[friendId] = false;
          
          // 읽은 편지 ID 업데이트
          _readFlowerIds.addAll(
            result.flowers.where((f) => (f.isRead ?? false) || f.sentByMe).map((f) => f.id),
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingFlowers[friendId] = false;
          _hasMorePages[friendId] = false; // 에러 발생 시 더 이상 시도하지 않음
        });
        showTabaError(context, message: '편지 목록을 불러오는데 실패했습니다: $e');
      }
    }
  }

  /// 편지 목록을 정렬: 공개편지가 있으면 첫 공개편지부터 시간순으로 정렬, 없으면 그냥 시간순
  List<SharedFlower> _sortFlowersWithPublicFirst(List<SharedFlower> flowers) {
    if (flowers.isEmpty) return flowers;
    
    // 공개편지(PUBLIC) 찾기
    final publicFlowers = flowers.where((f) => f.letter.visibility == VisibilityScope.public).toList();
    
    if (publicFlowers.isEmpty) {
      // 공개편지가 없으면 시간순으로 정렬 (최신순)
      return flowers..sort((a, b) => b.sentAt.compareTo(a.sentAt));
    }
    
    // 첫 공개편지 찾기 (가장 오래된 공개편지)
    publicFlowers.sort((a, b) => a.sentAt.compareTo(b.sentAt));
    final firstPublicFlower = publicFlowers.first;
    final firstPublicFlowerSentAt = firstPublicFlower.sentAt;
    
    // 첫 공개편지 이후의 모든 편지들 (공개편지 포함)
    final allFlowers = List<SharedFlower>.from(flowers);
    
    // 모든 편지를 시간순으로 정렬 (최신순)
    allFlowers.sort((a, b) => b.sentAt.compareTo(a.sentAt));
    
    // 첫 공개편지가 가장 오래된 편지인 경우, 그대로 반환
    // 첫 공개편지가 중간에 있는 경우, 첫 공개편지부터 시작하도록 재정렬
    final firstPublicIndex = allFlowers.indexWhere((f) => f.id == firstPublicFlower.id);
    if (firstPublicIndex > 0) {
      // 첫 공개편지가 중간에 있으면, 첫 공개편지부터 시작하도록 재정렬
      final beforeFirstPublic = allFlowers.sublist(0, firstPublicIndex);
      final fromFirstPublic = allFlowers.sublist(firstPublicIndex);
      return [...fromFirstPublic, ...beforeFirstPublic];
    }
    
    return allFlowers;
  }

  int _unreadFor(FriendBouquet bouquet) {
    final flowers = _loadedFlowers[bouquet.friend.user.id] ?? [];
    return flowers
        .where(
          (flower) =>
              !flower.sentByMe && (flower.isRead == false) && !_readFlowerIds.contains(flower.id),
        )
        .length;
  }

  void _openFlower(SharedFlower flower) async {
    if (!flower.sentByMe && (flower.isRead == false) && !_readFlowerIds.contains(flower.id)) {
      setState(() {
        _readFlowerIds.add(flower.id);
      });
    }

    // 편지 상세 정보를 다시 조회하여 템플릿 정보를 포함한 전체 정보 가져오기
    Letter? fullLetter;
    try {
      fullLetter = await _repository.getLetter(flower.letter.id);
    } catch (e) {
      print('편지 상세 조회 실패: $e');
      // 조회 실패 시 기존 편지 정보 사용
      fullLetter = flower.letter;
    }

    // 편지 상세 조회에 실패한 경우 기존 편지 정보 사용
    Letter letterToShow = fullLetter ?? flower.letter;

    // 내가 보낸 편지인 경우, 편지의 sender 정보를 현재 사용자로 설정
    if (flower.sentByMe) {
      try {
        final currentUser = await _repository.getCurrentUser();
        if (currentUser != null) {
          // Letter 객체의 sender를 현재 사용자로 업데이트 (템플릿 정보는 유지)
          letterToShow = Letter(
            id: letterToShow.id,
            title: letterToShow.title,
            content: letterToShow.content,
            preview: letterToShow.preview,
            sender: currentUser, // 현재 사용자로 설정
            visibility: letterToShow.visibility,
            sentAt: letterToShow.sentAt,
            views: letterToShow.views,
            attachedImages: letterToShow.attachedImages,
            template: letterToShow.template, // 템플릿 정보 유지
          );
        }
      } catch (e) {
        print('현재 사용자 정보 로드 실패: $e');
        // 에러가 발생해도 편지 상세 화면은 열림
      }
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LetterDetailScreen(
          letter: letterToShow,
          friendName: flower.sentByMe ? null : _selectedBouquet.friend.user.nickname,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        if (widget.friendBouquets.isEmpty) {
          return GradientScaffold(
            body: EmptyState(
              icon: Icons.local_florist_outlined,
              title: AppStrings.noBouquetYet(locale),
              subtitle: AppStrings.noBouquetSubtitle(locale),
            ),
          );
        }

        final selected = _selectedBouquet;
        final unread = _unreadFor(selected);
        final isLoading = _loadingFlowers[selected.friend.user.id] == true;

        return GradientScaffold(
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: TabaButton(
                onPressed: _composeLetterToSelectedFriend,
                label: AppStrings.sendLetterToFriend(locale),
                icon: Icons.edit,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                NavHeader(
                  showBackButton: true,
                ),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: FriendStoryStrip(
                      bouquets: widget.friendBouquets,
                      selectedIndex: _selectedIndex,
                      unreadResolver: _unreadFor,
                      onSelect: _selectFriend,
                    ),
                  ),
            // FriendSummaryCard 제거됨
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              sliver: _selectedFlowers.isEmpty && isLoading
                  ? SliverToBoxAdapter(
                      child: const TabaLoadingIndicator(),
                    )
                  : _selectedFlowers.isEmpty && !isLoading
                      ? SliverToBoxAdapter(
                          child: EmptyState(
                            icon: Icons.mail_outline,
                            title: AppStrings.noLettersYet(locale),
                            subtitle: AppStrings.writeLetterToStart(locale),
                          ),
                        )
                      : ChatMessagesList(
                          flowers: _selectedFlowers,
                          readFlowerIds: _readFlowerIds,
                          onOpen: _openFlower,
                          friendUser: selected.friend.user,
                        ),
            ),
                  // 무한 스크롤 로딩 인디케이터
                  if (isLoading && _selectedFlowers.isNotEmpty)
                    const SliverToBoxAdapter(
                      child: TabaInfiniteLoadingIndicator(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
      },
    );
  }

  void _shareBouquet(FriendBouquet bouquet) {
    final locale = AppLocaleController.localeNotifier.value;
    final flowers = _loadedFlowers[bouquet.friend.user.id] ?? [];
    final snippet = flowers
        .take(4)
        .map((f) => '• ${f.title}')
        .join('\n');
    final shareText = '''
${AppStrings.bouquetShareTitle(locale)}
${AppStrings.bouquetShareMessage(locale, bouquet.friend.user.nickname, flowers.length)}

$snippet

${AppStrings.inviteFriendsMessage(locale)}
${AppStrings.inviteCode(locale)}${bouquet.friend.inviteCode}
''';
    Clipboard.setData(ClipboardData(text: shareText));
    showTabaSuccess(
      context,
      title: AppStrings.bouquetShared(locale),
      message: AppStrings.shareBouquetMessage(locale, bouquet.friend.user.nickname),
    );
  }

  // 꽃다발 상세 기능 제거됨
  // void _openBouquetDetail(FriendBouquet bouquet) { ... }
  // void _saveBouquetName(FriendBouquet bouquet, String name) { ... }

  void _composeLetterToSelectedFriend() {
    final selectedFriendId = _selectedBouquet.friend.user.id;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WriteLetterPage(
          initialRecipient: selectedFriendId,
        ),
      ),
    );
  }
}

