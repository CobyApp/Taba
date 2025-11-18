import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/empty_state.dart';
import 'package:taba_app/presentation/widgets/loading_indicator.dart';
import 'package:taba_app/presentation/widgets/bouquet/friend_story_strip.dart';
import 'package:taba_app/presentation/widgets/bouquet/friend_summary_card.dart';
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
    
    // 스크롤이 하단 근처에 도달하면 다음 페이지 로드
    if (position.pixels >= position.maxScrollExtent * 0.9) {
      final friendId = _selectedBouquet.friend.user.id;
      final hasMore = _hasMorePages[friendId] ?? false;
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
      final flowers = await _repository.getFriendLetters(
        friendId: friendId,
        page: currentPage,
        size: 20,
      );
      
      if (mounted) {
        setState(() {
          if (reset) {
            _loadedFlowers[friendId] = flowers;
          } else {
            // 기존 목록에 추가 (중복 제거)
            final existingIds = _loadedFlowers[friendId]?.map((f) => f.id).toSet() ?? {};
            final newFlowers = flowers.where((f) => !existingIds.contains(f.id)).toList();
            _loadedFlowers[friendId] = [...(_loadedFlowers[friendId] ?? []), ...newFlowers];
          }
          
          // 페이지네이션 정보 업데이트
          _currentPages[friendId] = currentPage + 1;
          
          // 더 불러올 페이지가 있는지 확인 (응답이 비어있거나 20개 미만이면 마지막 페이지로 간주)
          _hasMorePages[friendId] = flowers.length >= 20;
          
          _loadingFlowers[friendId] = false;
          
          // 읽은 편지 ID 업데이트
          _readFlowerIds.addAll(
            flowers.where((f) => (f.isRead ?? false) || f.sentByMe).map((f) => f.id),
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

  int _unreadFor(FriendBouquet bouquet) {
    final flowers = _loadedFlowers[bouquet.friend.user.id] ?? [];
    return flowers
        .where(
          (flower) =>
              !flower.sentByMe && (flower.isRead == false) && !_readFlowerIds.contains(flower.id),
        )
        .length;
  }

  void _openFlower(SharedFlower flower) {
    if (!flower.sentByMe && (flower.isRead == false) && !_readFlowerIds.contains(flower.id)) {
      setState(() {
        _readFlowerIds.add(flower.id);
      });
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LetterDetailScreen(
          letter: flower.letter,
          friendName: _selectedBouquet.friend.user.nickname,
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
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                child: FriendSummaryCard(
                  bouquet: selected,
                  unreadCount: isLoading ? 0 : unread,
                  bouquetName: _resolveBouquetName(selected),
                  onTap: () => _openBouquetDetail(selected),
                ),
              ),
            ),
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
        .map((f) => '• ${f.title} (${f.flower.emoji})')
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

  void _openBouquetDetail(FriendBouquet bouquet) {
    TabaModalSheet.show(
      context: context,
      child: BouquetDetailSheet(
        bouquet: bouquet,
        bouquetName: _resolveBouquetName(bouquet),
        loadedFlowers: _loadedFlowers[bouquet.friend.user.id],
        onSaveName: (name) => _saveBouquetName(bouquet, name),
        onShare: () => _shareBouquet(bouquet),
        onFlowerTap: _openFlower,
      ),
    );
  }

  void _saveBouquetName(FriendBouquet bouquet, String name) {
    if (name.isEmpty) return;
    setState(() {
      _customBouquetNames[bouquet.friend.user.id] = name;
    });
  }

  void _composeLetterToSelectedFriend() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const WriteLetterPage(),
      ),
    );
  }
}

