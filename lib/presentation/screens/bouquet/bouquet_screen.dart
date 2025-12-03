import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/models/friend.dart';
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
  late List<FriendBouquet> _friendBouquets; // 상태로 관리하여 삭제된 친구 제거 가능
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
    _friendBouquets = List.from(widget.friendBouquets); // 상태로 복사
    _readFlowerIds = {};
    // 초기 선택된 친구의 편지 목록 로드
    if (_friendBouquets.isNotEmpty) {
      _loadFriendLetters(_friendBouquets[_selectedIndex].friend.user.id, reset: true);
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

  FriendBouquet get _selectedBouquet => _friendBouquets[_selectedIndex];
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
    final friendId = _friendBouquets[index].friend.user.id;
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
          
          // 서버에서 정렬된 순서 그대로 사용
          // 정렬 순서 확인 로깅
          print('📋 편지 정렬 확인 (friendId=$friendId):');
          for (int i = 0; i < sortedFlowers.length; i++) {
            final flower = sortedFlowers[i];
            print('  [$i] sentAt=${flower.sentAt.toIso8601String()}, sentByMe=${flower.sentByMe}, title=${flower.title}');
          }
          
          // 시간순 정렬 검증
          bool isTimeOrdered = true;
          for (int i = 1; i < sortedFlowers.length; i++) {
            if (sortedFlowers[i].sentAt.isBefore(sortedFlowers[i-1].sentAt)) {
              isTimeOrdered = false;
              print('  ⚠️ 시간순 정렬 위반: 인덱스 ${i-1}(${sortedFlowers[i-1].sentAt}) > 인덱스 $i(${sortedFlowers[i].sentAt})');
              break;
            }
          }
          
          // sentByMe로 분리되어 있는지 확인
          bool isSeparatedBySentByMe = true;
          bool? lastSentByMe;
          for (int i = 0; i < sortedFlowers.length; i++) {
            if (lastSentByMe != null && lastSentByMe != sortedFlowers[i].sentByMe) {
              // sentByMe가 바뀌는 지점이 있으면 분리되어 있지 않음
              isSeparatedBySentByMe = false;
              print('  ⚠️ sentByMe 분리 위반: 인덱스 ${i-1}($lastSentByMe) -> 인덱스 $i(${sortedFlowers[i].sentByMe})');
              break;
            }
            lastSentByMe = sortedFlowers[i].sentByMe;
          }
          
          print('  ✅ 시간순 정렬: $isTimeOrdered');
          print('  ✅ sentByMe 분리: $isSeparatedBySentByMe');
          if (isTimeOrdered && !isSeparatedBySentByMe) {
            print('  ✅ 결론: 시간순으로 섞여서 정렬됨 (친구 편지와 내 편지가 시간순으로 섞임)');
          } else if (!isTimeOrdered && isSeparatedBySentByMe) {
            print('  ⚠️ 결론: sentByMe로 분리되어 있지만 시간순이 아님');
          } else if (isTimeOrdered && isSeparatedBySentByMe) {
            print('  ⚠️ 결론: sentByMe로 분리되어 있고, 각 그룹 내에서 시간순 정렬됨');
          } else {
            print('  ⚠️ 결론: 시간순도 아니고 sentByMe로 분리되지도 않음');
          }
          
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
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: '${AppStrings.letterListLoadFailed(locale)}: $e');
      }
    }
  }


  /// UI 표시용: 각 친구별 읽지 않은 편지 개수 계산
  int _unreadFor(FriendBouquet bouquet) {
    final baseUnreadCount = bouquet.friend.unreadLetterCount;
    final flowers = _loadedFlowers[bouquet.friend.user.id] ?? [];
    final readCount = flowers
        .where(
          (flower) =>
              !flower.sentByMe && 
              ((flower.isRead == true) || _readFlowerIds.contains(flower.id)),
        )
        .length;
    
    return (baseUnreadCount - readCount).clamp(0, baseUnreadCount);
  }

  /// 예약전송 편지 안내 팝업 표시
  void _showScheduledLetterInfoDialog(BuildContext context, Locale locale, DateTime scheduledAt) {
    TabaModalSheet.show(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModalSheetHeader(
              title: AppStrings.scheduledLetterDialogTitle(locale),
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 24),
            Text(
              AppStrings.scheduledLetterDialogMessage(locale, scheduledAt),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            TabaButton(
              onPressed: () => Navigator.of(context).pop(),
              label: AppStrings.confirm(locale),
              isFullWidth: true,
            ),
          ],
        );
      },
    );
  }

  void _openFlower(SharedFlower flower) async {
    // 예약전송 편지 접근 제한 확인 (가장 먼저 체크)
    // API 명세서: 예약전송 편지는 받는 사람이 예약 시간 전까지 열람할 수 없음
    // 보낸 사람은 언제든지 열람 가능
    // API 명세서: 예약전송 편지의 경우 sentAt이 scheduledAt으로 표시됨
    if (!flower.sentByMe) {
      final now = DateTime.now();
      DateTime? scheduledTime;
      
      // scheduledAt이 있으면 사용, 없으면 sentAt이 미래인 경우 sentAt 사용
      if (flower.scheduledAt != null) {
        scheduledTime = flower.scheduledAt;
      } else if (flower.sentAt.isAfter(now)) {
        // sentAt이 미래인 경우 (예약전송 편지)
        scheduledTime = flower.sentAt;
      }
      
      if (scheduledTime != null && now.isBefore(scheduledTime)) {
        // 예약 시간 전이면 접근 불가 - 팝업으로 안내 (화면 이동 없음)
        final locale = AppLocaleController.localeNotifier.value;
        if (mounted) {
          _showScheduledLetterInfoDialog(context, locale, scheduledTime);
        }
        return;
      }
    }

    if (!flower.sentByMe && (flower.isRead == false) && !_readFlowerIds.contains(flower.id)) {
      setState(() {
        _readFlowerIds.add(flower.id);
        
        // 해당 친구의 unreadLetterCount 업데이트
        final friendId = _selectedBouquet.friend.user.id;
        final friendIndex = _friendBouquets.indexWhere((b) => b.friend.user.id == friendId);
        if (friendIndex != -1) {
          final bouquet = _friendBouquets[friendIndex];
          final updatedFriend = FriendProfile(
            user: bouquet.friend.user,
            lastLetterAt: bouquet.friend.lastLetterAt,
            friendCount: bouquet.friend.friendCount,
            sentLetters: bouquet.friend.sentLetters,
            inviteCode: bouquet.friend.inviteCode,
            unreadLetterCount: (bouquet.friend.unreadLetterCount - 1).clamp(0, bouquet.friend.unreadLetterCount),
            group: bouquet.friend.group,
          );
          _friendBouquets[friendIndex] = FriendBouquet(
            friend: updatedFriend,
            bloomLevel: bouquet.bloomLevel,
            trustScore: bouquet.trustScore,
            bouquetName: bouquet.bouquetName,
            unreadCount: updatedFriend.unreadLetterCount,
            themeColor: bouquet.themeColor,
          );
        }
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
            scheduledAt: letterToShow.scheduledAt, // 예약전송 시간 유지
          );
        }
      } catch (e) {
        print('현재 사용자 정보 로드 실패: $e');
        // 에러가 발생해도 편지 상세 화면은 열림
      }
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute<dynamic>(
        builder: (_) => LetterDetailScreen(
          letter: letterToShow,
          friendName: flower.sentByMe ? null : _selectedBouquet.friend.user.nickname,
        ),
      ),
    );
    
    if (!mounted) return;
    
    // 차단된 경우 처리
    if (result is Map && result['blocked'] == true) {
      final blockedUserId = result['blockedUserId'] as String?;
      if (blockedUserId != null) {
        // 차단된 친구를 목록에서 즉시 제거
        setState(() {
          _friendBouquets.removeWhere((b) => b.friend.user.id == blockedUserId);
          // 캐시 데이터도 제거
          _loadedFlowers.remove(blockedUserId);
          _loadingFlowers.remove(blockedUserId);
          _hasMorePages.remove(blockedUserId);
          _currentPages.remove(blockedUserId);
          
          // 선택된 인덱스 조정
          if (_friendBouquets.isEmpty) {
            _selectedIndex = 0;
          } else if (_selectedIndex >= _friendBouquets.length) {
            _selectedIndex = _friendBouquets.length - 1;
          }
          
          // 남은 친구가 있으면 선택된 친구의 편지 목록 로드
          if (_friendBouquets.isNotEmpty) {
            _loadFriendLetters(_friendBouquets[_selectedIndex].friend.user.id, reset: true);
          }
        });
        
        // 친구가 없으면 이전 화면으로 돌아가기
        if (_friendBouquets.isEmpty) {
          Navigator.of(context).pop(true);
        }
      }
      return;
    }
    
    // 편지를 읽었거나 답장 성공 시 목록 새로고침
    if (result == true && mounted) {
      _loadFriendLetters(_selectedBouquet.friend.user.id, reset: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        if (_friendBouquets.isEmpty) {
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
                  actions: [
                    PopupMenuButton<String>(
                      icon: const Icon(
                        Icons.more_vert,
                        color: Colors.white,
                      ),
                      color: Colors.white,
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteFriend(_selectedBouquet);
                        } else if (value == 'block') {
                          _blockFriend(_selectedBouquet);
                        }
                      },
                      itemBuilder: (context) {
                        final locale = AppLocaleController.localeNotifier.value;
                        return [
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.person_remove, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.deleteFriend(locale),
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'block',
                            child: Row(
                              children: [
                                const Icon(Icons.block, color: Colors.red),
                                const SizedBox(width: 8),
                                Text(
                                  AppStrings.blockUser(locale),
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: FriendStoryStrip(
                      bouquets: _friendBouquets,
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
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Transform.translate(
                              offset: const Offset(0, -60),
                            child: EmptyState(
                              icon: Icons.mail_outline,
                              title: AppStrings.noLettersYet(locale),
                              subtitle: AppStrings.writeLetterToStart(locale),
                              ),
                            ),
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
          onSuccess: () {
            // 편지 작성 성공 시 해당 친구의 편지 목록 새로고침
            _loadFriendLetters(selectedFriendId, reset: true);
          },
        ),
      ),
    );
  }

  Future<void> _deleteFriend(FriendBouquet bouquet) async {
    final locale = AppLocaleController.localeNotifier.value;
    final friendName = bouquet.friend.user.nickname;
    final friendId = bouquet.friend.user.id;
    
    // 확인 다이얼로그 표시
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.deleteFriend(locale),
      message: AppStrings.deleteFriendConfirm(locale, friendName),
      confirmText: AppStrings.deleteFriend(locale),
      cancelText: AppStrings.cancel(locale),
      confirmColor: Colors.red,
    );
    
    if (confirmed != true) return;
    
    try {
      final success = await _repository.deleteFriend(friendId);
      
      if (!mounted) return;
      
      if (success) {
        // 친구 삭제 성공 시 목록에서 제거
        setState(() {
          _friendBouquets.removeWhere((b) => b.friend.user.id == friendId);
          // 삭제된 친구의 캐시 데이터도 제거
          _loadedFlowers.remove(friendId);
          _loadingFlowers.remove(friendId);
          _hasMorePages.remove(friendId);
          _currentPages.remove(friendId);
          
          // 선택된 인덱스 조정
          if (_friendBouquets.isEmpty) {
            _selectedIndex = 0;
          } else if (_selectedIndex >= _friendBouquets.length) {
            _selectedIndex = _friendBouquets.length - 1;
          }
          
          // 남은 친구가 있으면 선택된 친구의 편지 목록 로드
          if (_friendBouquets.isNotEmpty) {
            _loadFriendLetters(_friendBouquets[_selectedIndex].friend.user.id, reset: true);
          }
        });
        
        showTabaSuccess(
          context,
          title: AppStrings.friendDeleted(locale),
          message: AppStrings.friendDeletedMessage(locale),
        );
      } else {
        showTabaError(
          context,
          message: AppStrings.friendDeleteFailed(locale),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showTabaError(
        context,
        message: AppStrings.errorOccurred(locale, e.toString()),
      );
    }
  }

  Future<void> _blockFriend(FriendBouquet bouquet) async {
    final locale = AppLocaleController.localeNotifier.value;
    final friendName = bouquet.friend.user.nickname;
    final friendId = bouquet.friend.user.id;
    
    // 확인 다이얼로그 표시
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.blockUser(locale),
      message: AppStrings.blockUserConfirm(locale, friendName),
      confirmText: AppStrings.block(locale),
      cancelText: AppStrings.cancel(locale),
      confirmColor: Colors.red,
      icon: Icons.block,
    );
    
    if (confirmed != true) return;
    
    try {
      final result = await _repository.blockUser(friendId);
      
      if (!mounted) return;
      
      // API 명세서 기준: 성공이거나 이미 차단한 사용자인 경우 UI에서 차단 처리
      final errorMsg = result.message ?? '';
      final shouldTreatAsBlocked = result.success || 
                                   errorMsg.contains('이미 차단') ||
                                   errorMsg.contains('already blocked') ||
                                   errorMsg.contains('서버 오류');
      
      if (shouldTreatAsBlocked) {
        // 차단 성공 또는 이미 차단된 사용자 - 목록에서 제거
        final shouldPop = _friendBouquets.length == 1; // 마지막 친구인지 미리 확인
        
        setState(() {
          _friendBouquets.removeWhere((b) => b.friend.user.id == friendId);
          // 차단된 친구의 캐시 데이터도 제거
          _loadedFlowers.remove(friendId);
          _loadingFlowers.remove(friendId);
          _hasMorePages.remove(friendId);
          _currentPages.remove(friendId);
          
          // 선택된 인덱스 조정
          if (_friendBouquets.isEmpty) {
            _selectedIndex = 0;
          } else if (_selectedIndex >= _friendBouquets.length) {
            _selectedIndex = _friendBouquets.length - 1;
          }
          
          // 남은 친구가 있으면 선택된 친구의 편지 목록 로드
          if (_friendBouquets.isNotEmpty) {
            _loadFriendLetters(_friendBouquets[_selectedIndex].friend.user.id, reset: true);
          }
        });
        
        showTabaSuccess(
          context,
          title: AppStrings.userBlocked(locale),
          message: AppStrings.userBlockedMessage(locale),
        );
        
        // 친구가 없으면 이전 화면으로 돌아가기
        if (shouldPop && mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (mounted) {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        showTabaError(
          context,
          message: result.message ?? AppStrings.blockFailed(locale),
        );
      }
    } catch (e) {
      if (!mounted) return;
      showTabaError(
        context,
        message: AppStrings.errorOccurred(locale, e.toString()),
      );
    }
  }
}

