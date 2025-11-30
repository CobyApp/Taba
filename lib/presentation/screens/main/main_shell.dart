import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:taba_app/core/services/app_badge_service.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/data/services/fcm_service.dart';
import 'package:taba_app/presentation/screens/bouquet/bouquet_screen.dart';
import 'package:taba_app/presentation/screens/common/letter_detail_screen.dart';
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
    _setupPushNotificationHandlers();
  }

  void _setupPushNotificationHandlers() {
    final fcmService = FcmService.instance;
    
    // 포그라운드 메시지 핸들러
    fcmService.setOnMessageHandler((message) {
      if (!mounted) return;
      
      // 데이터 새로고침
      _loadData();
      
      // 스낵바로 알림 표시
      final locale = AppLocaleController.localeNotifier.value;
      final category = message.data['category'] as String? ?? message.data['type'] as String?;
      
      // 친구 추가 알림인 경우 로컬라이즈된 메시지 사용
      String title;
      String body;
      
      if (category?.toUpperCase() == 'FRIEND') {
        // 친구 추가 알림 패턴 감지
        final originalTitle = message.notification?.title ?? '';
        final originalBody = message.notification?.body ?? '';
        
        // 한국어 패턴 감지: "님이 친구로 추가되었어요" 또는 "님이 친구 요청을 수락했어요"
        if (originalTitle.contains('친구로 추가되었어요') || 
            originalTitle.contains('친구 요청을 수락했어요') ||
            originalTitle.contains('친구로 추가')) {
          // 친구 닉네임 추출 시도 (제목에서 "님" 앞의 텍스트)
          final match = RegExp(r'^(.+?)님').firstMatch(originalTitle);
          if (match != null) {
            final friendName = match.group(1) ?? '';
            if (originalTitle.contains('친구 요청을 수락했어요')) {
              title = '${friendName}${AppStrings.friendRequestAcceptedTitle(locale)}';
            } else {
              title = '${friendName}${AppStrings.friendAddedTitle(locale)}';
            }
          } else {
            // 패턴 매칭 실패 시 기본 메시지 사용
            title = AppStrings.friendAdded(locale);
          }
          
          // 본문도 로컬라이즈
          if (originalBody.contains('이제 서로 편지를 주고받을 수 있어요') ||
              originalBody.contains('이제 서로의 편지를 주고받을 수 있어요')) {
            body = AppStrings.friendAddedMessage(locale);
          } else {
            body = originalBody;
          }
        } else {
          // 다른 친구 관련 알림은 원본 사용
          title = originalTitle.isNotEmpty ? originalTitle : AppStrings.newNotification(locale);
          body = originalBody;
        }
      } else {
        // 친구 알림이 아닌 경우 원본 사용
        title = message.notification?.title ?? AppStrings.newNotification(locale);
        body = message.notification?.body ?? '';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              if (body.isNotEmpty) Text(body),
            ],
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    });
    
    // 백그라운드에서 알림 탭 시 핸들러
    fcmService.setOnMessageOpenedAppHandler((message) {
      if (!mounted) return;
      _handlePushNotificationTap(message);
    });
  }

  Future<void> _handlePushNotificationTap(RemoteMessage message) async {
    if (!mounted) return;
    
    final data = message.data;
    final deepLink = data['deepLink'] as String?;
    final category = data['category'] as String? ?? data['type'] as String?;
    final relatedId = data['relatedId'] as String?;
    
    try {
      // 1. deepLink가 있으면 우선 사용
      if (deepLink != null && deepLink.isNotEmpty) {
        await _navigateToDeepLink(deepLink);
        if (mounted) {
          _loadData();
        }
        return;
      }
      
      // 2. category와 relatedId로 자동 처리
      if (category == null) return;
      
      switch (category.toUpperCase()) {
        case 'LETTER':
        case 'REACTION':
          // 편지 알림: 편지 상세 화면으로 이동
          if (relatedId != null) {
            final letter = await _repository.getLetter(relatedId);
            if (mounted && letter != null) {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LetterDetailScreen(
                    letter: letter,
                    friendName: letter.sender.nickname,
                  ),
                ),
              );
              // 편지를 읽었으면 데이터 새로고침하여 뱃지 카운트 업데이트
              if (result == true && mounted) {
              _loadData();
              }
            }
          }
          break;
          
        case 'FRIEND':
          // 친구 알림: 꽃다발 화면으로 이동
          if (mounted) {
            await _openBouquet(context);
            // 데이터 새로고침
            _loadData();
          }
          break;
          
        case 'SYSTEM':
        default:
          // 시스템 알림: 데이터만 새로고침 (알림 센터는 이미 메인 화면에 표시됨)
          if (mounted) {
            _loadData();
          }
          break;
      }
    } catch (e) {
      print('푸시 알림 처리 실패: $e');
      // 에러가 발생해도 데이터는 새로고침
      if (mounted) {
        _loadData();
      }
    }
  }

  /// 딥링크를 파싱하여 해당 화면으로 이동
  Future<void> _navigateToDeepLink(String deepLink) async {
    if (!mounted) return;
    
    // taba:// 제거
    String path = deepLink.replaceFirst(RegExp(r'^taba://'), '');
    path = path.replaceFirst(RegExp(r'^/'), '');
    
    final uri = Uri.parse('/$path');
    final segments = uri.pathSegments;
    
    if (segments.isEmpty) return;
    
    try {
      switch (segments[0]) {
        case 'letter':
          if (segments.length > 1) {
            final letterId = segments[1];
            final letter = await _repository.getLetter(letterId);
            if (mounted && letter != null) {
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => LetterDetailScreen(
                    letter: letter,
                    friendName: letter.sender.nickname,
                  ),
                ),
              );
              // 편지를 읽었거나 삭제되었으면 데이터 새로고침
              if (result == true && mounted) {
                _loadData();
              }
            }
          }
          break;
          
        case 'bouquet':
          if (segments.length > 1) {
            final friendId = segments[1];
            // 특정 친구의 꽃다발로 이동 (구현 필요 시 추가)
            await _openBouquet(context);
          } else {
            await _openBouquet(context);
          }
          break;
          
        case 'notifications':
          // 알림 센터는 이미 메인 화면에 표시됨
          // 필요 시 스크롤하여 알림 센터로 이동하는 로직 추가 가능
          break;
          
        case 'write':
          final replyTo = uri.queryParameters['replyTo'];
          if (replyTo != null) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WriteLetterPage(
                  replyToLetterId: replyTo,
                  onSuccess: () => _loadData(),
                ),
              ),
            );
          } else {
            _openWritePage(context);
          }
          break;
          
        case 'settings':
          await _openSettings(context);
          break;
      }
    } catch (e) {
      print('딥링크 처리 실패: $e');
    }
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

      // 서버에서 읽지 않은 알림 개수 조회하여 앱 아이콘 뱃지 업데이트
      try {
        final unreadNotificationCount = await _repository.getUnreadNotificationCount();
        await _updateAppBadge(unreadNotificationCount);
      } catch (e) {
        // 뱃지 업데이트 실패해도 앱은 계속 진행
        print('앱 뱃지 업데이트 실패: $e');
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
        
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: '${AppStrings.loadDataFailed(locale)}: $e');
      }
    }
  }

  /// 앱 아이콘 뱃지 업데이트
  /// 서버에서 받은 읽지 않은 알림 개수로 뱃지 설정
  Future<void> _updateAppBadge(int unreadCount) async {
    try {
      if (unreadCount > 0) {
        await AppBadgeService.instance.updateBadge(unreadCount);
      } else {
        await AppBadgeService.instance.removeBadge();
      }
    } catch (e) {
      print('앱 뱃지 업데이트 중 오류 발생: $e');
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
      
      // BouquetScreen이 닫힐 때마다 데이터 새로고침하여 뱃지 카운트 업데이트
      // (편지를 읽었을 때 서버의 unreadLetterCount가 변경되었을 수 있음)
      if (mounted) {
        _loadData();
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

