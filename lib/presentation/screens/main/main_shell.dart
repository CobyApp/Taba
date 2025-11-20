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
import 'package:taba_app/core/storage/language_filter_storage.dart';

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
  List<String> _selectedLanguages = []; // 선택된 언어 필터 (ko, en, ja)

  @override
  void initState() {
    super.initState();
    _loadLanguageFilters();
    _loadData();
  }
  
  Future<void> _loadLanguageFilters() async {
    final savedLanguages = await LanguageFilterStorage.getLanguages();
    if (savedLanguages != null) {
      setState(() {
        _selectedLanguages = savedLanguages;
      });
    } else {
      // 저장된 값이 없으면 기본값 (모든 언어)로 설정
      setState(() {
        _selectedLanguages = ['ko', 'en', 'ja'];
      });
      // 기본값도 저장
      await LanguageFilterStorage.saveLanguages(_selectedLanguages);
    }
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
      final letters = await _repository.getPublicLetters(
        languages: _selectedLanguages.length == 3 ? null : _selectedLanguages,
      );
      final notifications = await _repository.getNotifications();
      final friends = await _repository.getFriends();
      
      // API에서 받은 unreadLetterCount 합산 (API 명세서: 안 읽은 개인편지(DIRECT) 개수)
      // 각 친구의 unreadLetterCount를 합산하여 전체 안 읽은 편지 수 계산
      final unreadCount = friends.fold<int>(
        0,
        (sum, friend) => sum + friend.unreadLetterCount,
      );

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
          final letters = await _repository.getPublicLetters(
            page: page, 
            size: 10,
            languages: _selectedLanguages.length == 3 ? null : _selectedLanguages,
          );
          return letters;
        } catch (e) {
          print('다음 페이지 로드 실패: $e');
          return <Letter>[];
        }
      },
      onLoadMoreWithPagination: (page) async {
        try {
          return await _repository.getPublicLettersWithPagination(
            page: page, 
            size: 10,
            languages: _selectedLanguages.length == 3 ? null : _selectedLanguages,
          );
        } catch (e) {
          print('다음 페이지 로드 실패: $e');
          return (letters: <Letter>[], hasMore: false);
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
      // API에서 받은 unreadLetterCount 사용 (API 명세서: 안 읽은 개인편지(DIRECT) 개수)
      final friendBouquets = friends.map((friend) {
            return FriendBouquet(
              friend: friend,
              bloomLevel: 0.0, // 계산 로직이 없으므로 기본값
              trustScore: 0, // 계산 로직이 없으므로 기본값
              bouquetName: friend.user.nickname, // 친구 이름을 기본 꽃다발 이름으로 사용
          unreadCount: friend.unreadLetterCount, // API에서 받은 안 읽은 개인편지 개수 사용
            );
      }).toList();
      
      if (!mounted) return;
      
      final navigator = Navigator.of(context);
      final result = await navigator.push<bool>(
        MaterialPageRoute<bool>(
          builder: (_) => BouquetScreen(
            friendBouquets: friendBouquets,
          ),
        ),
      );
      
      // 친구 삭제 등으로 인해 목록이 변경된 경우 새로고침
      if (result == true && mounted) {
        // 친구 목록이 변경되었으므로 다시 로드할 필요는 없음
        // (BouquetScreen에서 이미 삭제되었고, 다음에 열 때 자동으로 새 목록이 로드됨)
      }
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
      
      // SettingsScreen을 push하되, 프로필 수정 시 알림을 받기 위해 콜백 사용
      await navigator.push(
        MaterialPageRoute(
          builder: (_) => SettingsScreen(
            currentUser: user,
            onLogout: widget.onLogout,
            onProfileUpdated: () {
              // 프로필이 업데이트되면 데이터 새로고침
              if (mounted) {
                _loadData();
              }
            },
            onLanguageFilterChanged: (languages) {
              // 언어 필터 변경 시 상태 업데이트
              if (mounted) {
                setState(() {
                  _selectedLanguages = languages;
                });
                _loadData(); // 필터 변경 시 데이터 새로고침
              }
            },
          ),
        ),
      );
      
      // SettingsScreen이 닫힐 때마다 데이터 새로고침 (프로필 수정 여부와 관계없이)
      if (mounted) {
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

