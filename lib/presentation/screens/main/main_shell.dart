import 'package:flutter/material.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/notification.dart';
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
      final bouquets = await _repository.getBouquets();
      
      final unreadCount = bouquets.fold<int>(
        0,
        (value, bouquet) => value + bouquet.unreadCount,
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
      final bouquets = await _repository.getBouquets();
      if (!mounted) return;
      
      if (bouquets.isEmpty) {
        showTabaInfo(
          context,
          message: '아직 꽃다발이 없습니다. 친구와 편지를 주고받으면 꽃다발이 생겨요.',
        );
        return;
      }
      
      final navigator = Navigator.of(context);
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => BouquetScreen(
            friendBouquets: bouquets,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showTabaError(context, message: '꽃다발을 불러오는데 실패했습니다: $e');
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

