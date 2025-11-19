import 'package:flutter/material.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/screens/bouquet/bouquet_screen.dart';
import 'package:taba_app/presentation/screens/settings/settings_screen.dart';
import 'package:taba_app/presentation/screens/sky/sky_screen.dart';
import 'package:taba_app/presentation/screens/write/write_letter_page.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/loading_indicator.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/core/locale/app_strings.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.onLogout});

  final VoidCallback? onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _repository = DataRepository.instance;
  List<Letter> _letters = [];
  List<NotificationItem> _notifications = [];
  int _unreadBouquetCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 먼저 인증 상태 확인
    final isAuthenticated = await _repository.isAuthenticated();
    if (!isAuthenticated) {
      if (mounted) {
        widget.onLogout?.call();
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final letters = await _repository.getPublicLetters();
      final notifications = await _repository.getNotifications();
      final friends = await _repository.getFriends();
      
      // 친구별로 읽지 않은 편지 수 계산
      int unreadCount = 0;
      for (final friend in friends) {
        try {
          final friendLetters = await _repository.getFriendLetters(
            friendId: friend.user.id,
            page: 0,
            size: 20,
          );
          unreadCount += friendLetters.where((f) => !f.sentByMe && !(f.isRead ?? false)).length;
        } catch (e) {
          // 개별 친구의 편지 조회 실패는 무시
          print('친구 ${friend.user.nickname}의 편지 조회 실패: $e');
        }
      }

      if (mounted) {
        setState(() {
          _letters = letters;
          _notifications = notifications;
          _unreadBouquetCount = unreadCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        
        // 401 에러인 경우 로그아웃 처리
        final errorString = e.toString().toLowerCase();
        if (errorString.contains('401') || 
            errorString.contains('unauthorized') ||
            errorString.contains('인증')) {
          widget.onLogout?.call();
          return;
        }
        
        showTabaError(context, message: '데이터를 불러오는데 실패했습니다: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: TabaLoadingIndicator()),
      );
    }

    return SkyScreen(
      letters: _letters,
      notifications: _notifications,
      unreadBouquetCount: _unreadBouquetCount,
      onOpenBouquet: () => _openBouquet(context),
      onOpenSettings: () => _openSettings(context),
      onRefresh: _loadData,
      onLoadMore: (page) async {
        try {
          final letters = await _repository.getPublicLetters(page: page, size: 10);
          return letters;
        } catch (e) {
          print('다음 페이지 로드 실패: $e');
          return <Letter>[];
        }
      },
      floatingActionButton: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.localeNotifier,
        builder: (context, locale, _) {
          return FloatingActionButton.extended(
            onPressed: () => _openWritePage(context),
            icon: const Icon(Icons.edit_rounded),
            label: Text(AppStrings.writeLetterButton(locale)),
          );
        },
      ),
    );
  }

  Future<void> _openBouquet(BuildContext context) async {
    try {
      final friends = await _repository.getFriends();
      if (!mounted) return;
      
      if (friends.isEmpty) {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaInfo(
          context,
          message: AppStrings.noFriends(locale),
        );
        return;
      }
      
      // 친구 목록을 FriendBouquet 형태로 변환
      final friendBouquets = await Future.wait(
        friends.map((friend) async {
          try {
            final letters = await _repository.getFriendLetters(
              friendId: friend.user.id,
              page: 0,
              size: 1,
            );
            final unreadCount = letters.where((f) => !f.sentByMe && !(f.isRead ?? false)).length;
            
            return FriendBouquet(
              friend: friend,
              bloomLevel: 0.0, // 계산 로직이 없으므로 기본값
              trustScore: 0, // 계산 로직이 없으므로 기본값
              bouquetName: friend.user.nickname, // 친구 이름을 기본 꽃다발 이름으로 사용
              unreadCount: unreadCount,
            );
          } catch (e) {
            // 에러 발생 시 기본값으로 생성
            return FriendBouquet(
              friend: friend,
              bloomLevel: 0.0,
              trustScore: 0,
              bouquetName: friend.user.nickname,
              unreadCount: 0,
            );
          }
        }),
      );
      
      if (!mounted) return;
      
      final navigator = Navigator.of(context);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => BouquetScreen(
            friendBouquets: friendBouquets,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
    }
  }

  Future<void> _openSettings(BuildContext context) async {
    try {
      final user = await _repository.getCurrentUser();
      if (!mounted) return;
      
      if (user == null) {
        if (!mounted) return;
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.cannotLoadUserInfo(locale));
        // 401 에러인 경우 자동 로그아웃
        widget.onLogout?.call();
        return;
      }
      
      if (!mounted) return;
      final navigator = Navigator.of(context);
      final result = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => SettingsScreen(
            currentUser: user,
            onLogout: widget.onLogout,
          ),
        ),
      );
      
      // 프로필이 수정되었으면 데이터 새로고침
      if (result == true && mounted) {
        _loadData();
      }
    } catch (e) {
      if (!mounted) return;
      
      final errorString = e.toString().toLowerCase();
      final isAuthError = errorString.contains('401') || 
                          errorString.contains('unauthorized') ||
                          errorString.contains('인증');
      
      if (isAuthError) {
        // 인증 에러인 경우 자동 로그아웃
        widget.onLogout?.call();
        return;
      }
      
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.settingsLoadFailed2(locale) + e.toString());
    }
  }

  void _openWritePage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WriteLetterPage(
          onSuccess: () => _loadData(), // 편지 작성 후 데이터 새로고침
        ),
      ),
    );
  }
}

