import 'dart:async';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_settings/app_settings.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/data/dto/invite_code_dto.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/storage/language_filter_storage.dart';
import 'package:taba_app/data/services/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:taba_app/presentation/screens/settings/block_list_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.currentUser,
    this.onLogout,
    this.onProfileUpdated,
    this.onLanguageFilterChanged,
  });

  final TabaUser currentUser;
  final VoidCallback? onLogout;
  final VoidCallback? onProfileUpdated;
  final Function(List<String>)? onLanguageFilterChanged; // 언어 필터 변경 콜백

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repository = DataRepository.instance;
  bool _pushEnabled = true;
  String? _inviteCode;
  DateTime? _codeExpiresAt;
  bool _isLoadingSettings = false;
  bool _isLoadingCode = false;
  Timer? _timer;
  late TabaUser _currentUser; // 프로필 수정 후 업데이트하기 위해 state로 관리
  List<String> _selectedLetterLanguages = ['ko', 'en', 'ja']; // 선택된 편지 언어 필터 (기본값: 모든 언어)

  @override
  void initState() {
    super.initState();
    _currentUser = widget.currentUser; // 초기 사용자 정보 저장
    _loadSettings();
    _loadInviteCode();
    _loadLanguageFilters();
    _startTimer();
  }
  
  Future<void> _loadLanguageFilters() async {
    final savedLanguages = await LanguageFilterStorage.getLanguages();
    if (savedLanguages != null) {
      setState(() {
        _selectedLetterLanguages = savedLanguages;
      });
      // 콜백 호출하여 메인 화면에도 반영
      widget.onLanguageFilterChanged?.call(_selectedLetterLanguages);
    } else {
      // 저장된 값이 없으면 기본값 (모든 언어)로 설정
      setState(() {
        _selectedLetterLanguages = ['ko', 'en', 'ja'];
      });
      // 기본값도 저장
      await LanguageFilterStorage.saveLanguages(_selectedLetterLanguages);
      widget.onLanguageFilterChanged?.call(_selectedLetterLanguages);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // 타이머 업데이트를 위해 setState 호출
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoadingSettings = true);
    try {
      final pushEnabled = await _repository.getPushNotificationSetting();
      if (mounted) {
        setState(() {
          _pushEnabled = pushEnabled;
          _isLoadingSettings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingSettings = false);
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.settingsLoadFailed(locale) + e.toString());
      }
    }
  }

  Future<void> _loadInviteCode() async {
    try {
      final inviteCodeDto = await _repository.getCurrentInviteCode();
      if (mounted && inviteCodeDto != null) {
        setState(() {
          _inviteCode = inviteCodeDto.code;
          _codeExpiresAt = inviteCodeDto.expiresAt;
        });
        _startTimer();
      }
    } catch (e) {
      // 초대 코드 로드 실패는 조용히 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _remainingValidity();
    return Scaffold(
      backgroundColor: AppColors.midnightSoft,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Column(
              children: [
                NavHeader(
                  showBackButton: true,
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: AppSpacing.xl,
                      right: AppSpacing.xl,
                      bottom: AppSpacing.lg,
                    ),
                    children: [
                      // 1. 프로필 카드
                      GestureDetector(
                        onTap: () => _openEditProfile(context, _currentUser),
                        child: _ProfileCard(user: _currentUser),
                      ),
                      const SizedBox(height: 32),
                      // 2. 친구 초대 섹션 (주요 기능)
                      _SectionHeader(title: AppStrings.friendInviteSection(locale)),
                      TabaCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.airplane_ticket),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _inviteCode ?? AppStrings.inviteCodeLabel(locale),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              remaining != null
                                  ? '${AppStrings.validTime(locale)} ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'
                                  : AppStrings.expired(locale),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (_inviteCode != null)
                                Expanded(
                                  child: TabaButton(
                                      onPressed: () => _copyInvite(_inviteCode!),
                                    label: AppStrings.copyButton(locale),
                                    icon: Icons.copy,
                                    variant: TabaButtonVariant.outline,
                                  ),
                                ),
                                if (_inviteCode != null) const SizedBox(width: 8),
                                Expanded(
                                  child: TabaButton(
                                    onPressed: (_isLoadingCode || (remaining != null && remaining.inSeconds > 0))
                                        ? null
                                        : _regenerateCode,
                                    label: _inviteCode == null
                                        ? AppStrings.generateButton(locale)
                                        : AppStrings.regenerateButton(locale),
                                    isLoading: _isLoadingCode,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TabaCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person_add),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    AppStrings.addFriendByCode(locale),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TabaButton(
                              onPressed: () => _showAddFriendDialog(context),
                              label: AppStrings.addFriendByCodeButton(locale),
                              icon: Icons.person_add,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 3. 공개 편지 섹션 (기능 설정)
                      _SectionHeader(title: AppStrings.publicLetterSection(locale)),
                      TabaCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.filter_list, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppStrings.languageFilter(locale),
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppStrings.languageFilterDescription(locale),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildLanguageChip('ko', '한국어', locale),
                                _buildLanguageChip('en', 'English', locale),
                                _buildLanguageChip('ja', '日本語', locale),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // 4. 알림 섹션 (앱 기능 설정)
                      _SectionHeader(title: AppStrings.notificationsSection(locale)),
                      SwitchListTile(
                        title: Text(AppStrings.pushNotifications(locale)),
                        subtitle: Text(AppStrings.pushNotificationsSubtitle(locale)),
                        value: _pushEnabled,
                        onChanged: _isLoadingSettings ? null : (value) => _updatePushNotification(value),
                      ),
                      const SizedBox(height: 32),
                      // 5. 언어 섹션 (앱 기본 설정)
                      _SectionHeader(title: AppStrings.languageSection(locale)),
                      ValueListenableBuilder<Locale>(
                        valueListenable: AppLocaleController.localeNotifier,
                        builder: (context, currentLocale, _) {
                          return TabaCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.language, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        AppStrings.appLanguage(currentLocale),
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildAppLanguageChip('ko', '한국어', currentLocale),
                                    _buildAppLanguageChip('en', 'English', currentLocale),
                                    _buildAppLanguageChip('ja', '日本語', currentLocale),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      // 6. 계정 섹션 (개인 정보 및 보안)
                      _SectionHeader(title: AppStrings.accountSection(locale)),
                      ListTile(
                        leading: const Icon(Icons.block_outlined),
                        title: Text(AppStrings.blockedUsers(locale)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openBlockList(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Text(AppStrings.changePassword(locale)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(AppStrings.logout(locale)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _handleLogout(context),
                      ),
                      ListTile(
                        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        title: Text(
                          AppStrings.deleteAccount(locale),
                          style: const TextStyle(color: Colors.redAccent),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                        onTap: () => _handleDeleteAccount(context),
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

  void _copyInvite(String code) {
    final locale = AppLocaleController.localeNotifier.value;
    Clipboard.setData(ClipboardData(text: code));
    showTabaSuccess(
      context,
      title: AppStrings.inviteCodeCopied(locale),
      message: AppStrings.inviteCodeCopiedMessage(locale),
    );
  }


  void _showAddFriendDialog(BuildContext context) {
    final locale = AppLocaleController.localeNotifier.value;
    final codeController = TextEditingController();
    TabaModalSheet.show<void>(
      context: context,
      fixedSize: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ModalSheetHeader(
            title: AppStrings.addFriend(locale),
            onClose: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 24),
          TabaTextField(
          controller: codeController,
          labelText: AppStrings.friendCode(locale),
          hintText: AppStrings.inviteCodeExample(locale),
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
        ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md),
            child: TabaButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(context).pop();
                _addFriendByCode(code);
              }
            },
              label: AppStrings.add(locale),
              icon: Icons.person_add,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriendByCode(String inviteCode) async {
    final locale = AppLocaleController.localeNotifier.value;
    if (inviteCode.isEmpty) {
        showTabaError(context, message: AppStrings.enterFriendCode(locale));
      return;
    }

    try {
      final response = await _repository.addFriendByInviteCode(inviteCode);
      if (!mounted) return;

      if (response == null) {
        showTabaError(context, message: AppStrings.addFriendFailed(locale));
        return;
      }

      // API 명세서에 따른 응답 처리
      if (response.isOwnCode) {
        // 자신의 초대 코드를 사용한 경우
        showTabaError(
          context,
          title: AppStrings.cannotAddSelf(locale),
          message: AppStrings.cannotAddSelfMessage(locale),
        );
      } else if (response.alreadyFriends) {
        // 이미 친구인 경우
        showTabaSuccess(
          context,
          title: AppStrings.alreadyFriends(locale),
          message: AppStrings.alreadyFriendsMessage(locale),
        );
      } else {
        // 새로운 친구 추가 성공
        showTabaSuccess(
          context,
          title: AppStrings.friendAdded(locale),
          message: AppStrings.friendAddedMessage(locale),
        );
      }
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
    }
  }

  void _showChangePasswordDialog(BuildContext context) {
    final locale = AppLocaleController.localeNotifier.value;
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    TabaModalSheet.show<void>(
      context: context,
      fixedSize: true,
      builder: (dialogContext) {
        bool isSubmitting = false;
        bool obscureCurrentPassword = true;
        bool obscureNewPassword = true;
        bool obscureConfirmPassword = true;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
                  mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                ModalSheetHeader(
                  title: AppStrings.changePassword(locale),
                  onClose: () => Navigator.of(context).pop(),
                ),
                const SizedBox(height: 24),
                    TabaTextField(
                      controller: currentPasswordController,
                      labelText: AppStrings.currentPassword(locale),
                      obscureText: obscureCurrentPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureCurrentPassword = !obscureCurrentPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TabaTextField(
                      controller: newPasswordController,
                      labelText: AppStrings.newPassword(locale),
                      obscureText: obscureNewPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureNewPassword = !obscureNewPassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    TabaTextField(
                      controller: confirmPasswordController,
                      labelText: AppStrings.confirmPassword(locale),
                      obscureText: obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                        ),
                        onPressed: () {
                          setDialogState(() {
                            obscureConfirmPassword = !obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.md),
                  child: TabaButton(
                  onPressed: isSubmitting ? null : () async {
                    final currentPassword = currentPasswordController.text.trim();
                    final newPassword = newPasswordController.text.trim();
                    final confirmPassword = confirmPasswordController.text.trim();

                    if (currentPassword.isEmpty) {
                      showTabaError(context, message: AppStrings.currentPasswordRequired(locale));
                      return;
                    }

                    if (newPassword.isEmpty) {
                      showTabaError(context, message: AppStrings.newPasswordRequired(locale));
                      return;
                    }

                    if (newPassword.length < 8) {
                      showTabaError(context, message: AppStrings.passwordMinLength(locale));
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      showTabaError(context, message: AppStrings.passwordMismatch(locale));
                      return;
                    }

                    setDialogState(() => isSubmitting = true);

                    try {
                      final success = await _repository.changePassword(
                        currentPassword: currentPassword,
                        newPassword: newPassword,
                      );

                      if (!context.mounted) return;

                      if (success) {
                        Navigator.of(context).pop();
                        showTabaSuccess(
                          context,
                          title: AppStrings.passwordChanged(locale),
                          message: AppStrings.passwordChangedMessage(locale),
                        );
                      } else {
                        setDialogState(() => isSubmitting = false);
                        showTabaError(context, message: AppStrings.passwordChangeFailed(locale));
                      }
                    } catch (e) {
                      if (!context.mounted) return;
                      setDialogState(() => isSubmitting = false);
                      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
                    }
                  },
                  label: AppStrings.change(locale),
                  icon: Icons.lock_outline,
                  isLoading: isSubmitting,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updatePushNotification(bool enabled) async {
    final locale = AppLocaleController.localeNotifier.value;
    
    // 푸시 알림을 켜려고 할 때 권한 확인
    if (enabled) {
      final fcmService = FcmService.instance;
      final isGranted = await fcmService.isNotificationPermissionGranted();
      
      if (!isGranted) {
        // 권한이 거부된 경우 시스템 설정으로 이동
        final shouldOpenSettings = await TabaModalSheet.showConfirm(
          context: context,
          title: AppStrings.notificationPermissionDenied(locale),
          message: AppStrings.notificationPermissionDeniedMessage(locale),
          confirmText: AppStrings.openSystemSettings(locale),
          cancelText: AppStrings.cancel(locale),
          icon: Icons.settings,
        );
        
        if (shouldOpenSettings == true && !kIsWeb) {
          await AppSettings.openAppSettings();
        }
        
        // 토글을 원래 상태로 되돌림
        setState(() => _pushEnabled = false);
        return;
      }
    }
    
    // 권한이 허용된 경우 또는 알림을 끄는 경우 서버에 설정 업데이트
    setState(() => _pushEnabled = enabled);
    try {
      final success = await _repository.updatePushNotificationSetting(enabled);
      if (!mounted) return;
      
      if (!success) {
        setState(() => _pushEnabled = !enabled);
        showTabaError(context, message: AppStrings.notificationUpdateFailed(locale));
      }
    } catch (e) {
      if (!mounted) return;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
      setState(() => _pushEnabled = !enabled);
    }
  }

  Future<void> _regenerateCode() async {
    if (_isLoadingCode) return;
    
    setState(() => _isLoadingCode = true);
    try {
      final inviteCodeDto = await _repository.generateInviteCode();
      if (!mounted) return;
      
      if (inviteCodeDto != null) {
        setState(() {
          _inviteCode = inviteCodeDto.code;
          _codeExpiresAt = inviteCodeDto.expiresAt;
        });
        _startTimer();
        final locale = AppLocaleController.localeNotifier.value;
        showTabaSuccess(
          context,
          title: AppStrings.newInviteCodeGenerated(locale),
          message: AppStrings.inviteCodeValidFor(locale),
        );
      } else {
        final locale = AppLocaleController.localeNotifier.value;
        // 에러 메시지를 더 자세히 표시
        showTabaError(
          context,
          title: AppStrings.inviteCodeGenerationFailed(locale),
          message: AppStrings.inviteCodeGenerationFailed(locale),
        );
      }
    } catch (e, stackTrace) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      print('초대 코드 생성 에러: $e');
      print('Stack trace: $stackTrace');
      showTabaError(
        context,
        title: AppStrings.inviteCodeGenerationFailed(locale),
        message: '${AppStrings.inviteCodeGenerationError(locale)}: ${e.toString()}',
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingCode = false);
      }
    }
  }

  Widget _buildLanguageChip(String code, String label, Locale locale) {
    final isSelected = _selectedLetterLanguages.contains(code);
    return GestureDetector(
      onTap: () async {
        setState(() {
          if (isSelected) {
            _selectedLetterLanguages.remove(code);
          } else {
            _selectedLetterLanguages.add(code);
          }
        });
        // 로컬 저장소에 저장
        await LanguageFilterStorage.saveLanguages(_selectedLetterLanguages);
        // 언어 필터 변경 시 콜백 호출
        widget.onLanguageFilterChanged?.call(_selectedLetterLanguages);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.neonPink.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.neonPink 
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.neonPink,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppLanguageChip(String code, String label, Locale currentLocale) {
    final isSelected = currentLocale.languageCode == code;
    return GestureDetector(
      onTap: () {
        // 해당 언어의 Locale 찾기
        final targetLocale = AppLocaleController.supportedLocales.firstWhere(
          (l) => l.languageCode == code,
          orElse: () => AppLocaleController.supportedLocales.first,
        );
        AppLocaleController.setLocale(targetLocale);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.neonPink.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? AppColors.neonPink 
                : Colors.white.withOpacity(0.2),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              Icon(
                Icons.check_circle,
                size: 18,
                color: AppColors.neonPink,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Duration? _remainingValidity() {
    if (_inviteCode == null || _codeExpiresAt == null) return null;
    final now = DateTime.now();
    final diff = _codeExpiresAt!.difference(now);
    if (diff.isNegative) return null;
    return diff;
  }

  Future<void> _openEditProfile(BuildContext context, TabaUser user) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => EditProfileScreen(
          currentUser: user,
        ),
      ),
    );
    
    // 프로필이 업데이트되었으면 설정 화면에 머물고 사용자 정보를 다시 불러옴
    if (result == true && mounted) {
      // 사용자 정보를 다시 불러와서 프로필 카드 업데이트
      final updatedUser = await _repository.getCurrentUser();
      if (updatedUser != null && mounted) {
        setState(() {
          _currentUser = updatedUser;
        });
      }
      // 프로필이 업데이트되었으면 부모(main_shell)에게 알림 전달
      widget.onProfileUpdated?.call();
      // 설정 화면은 닫지 않고 유지 (Navigator.pop 호출 안함)
    }
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final locale = AppLocaleController.localeNotifier.value;
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.deleteAccount(locale),
      message: AppStrings.deleteAccountConfirm(locale),
      confirmText: AppStrings.deleteAccount(locale),
      cancelText: AppStrings.cancel(locale),
      confirmColor: Colors.redAccent,
      icon: Icons.warning_amber_rounded,
    );

    if (confirmed != true) return;

    try {
      final success = await DataRepository.instance.deleteUser(widget.currentUser.id);
      if (!mounted) return;

      if (success) {
        // 모든 화면을 닫고
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // 로그아웃 콜백 호출하여 앱 상태를 인증 화면으로 변경
        widget.onLogout?.call();
        
        // 성공 메시지 표시
        showTabaSuccess(
          context,
          title: AppStrings.accountDeleted(locale),
          message: AppStrings.accountDeletedMessage(locale),
        );
      } else {
        showTabaError(context, message: AppStrings.deleteAccountFailed(locale));
      }
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.deleteAccountFailed(locale) + ': ${e.toString()}');
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final locale = AppLocaleController.localeNotifier.value;
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.logout(locale),
      message: AppStrings.reallyLogout(locale),
      confirmText: AppStrings.logout(locale),
      cancelText: AppStrings.cancel(locale),
      icon: Icons.logout,
    );

    if (confirmed != true) return;

    try {
      await DataRepository.instance.logout();
      if (!mounted) return;
      
      // 모든 화면을 닫고
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      // 로그아웃 콜백 호출하여 앱 상태를 인증 화면으로 변경
      widget.onLogout?.call();
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.logoutError(locale) + e.toString());
    }
  }

  void _openBlockList(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BlockListScreen(),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final TabaUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        children: [
          UserAvatar(
            user: user,
            radius: 32,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
                  user.nickname,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
                ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white70,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    super.key,
    required this.currentUser,
  });

  final TabaUser currentUser;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _repository = DataRepository.instance;
  final _nicknameCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  String? _currentAvatarUrl;
  bool _isRemovingImage = false;
  bool _isLoading = false;
  bool _hasImageError = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl.text = widget.currentUser.nickname;
    _currentAvatarUrl = widget.currentUser.avatarUrl;
    _hasImageError = false;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _isRemovingImage = false;
          _hasImageError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: '${AppStrings.photoSelectionError(locale)}: $e');
      }
    }
  }

  Future<void> _takeProfileImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _isRemovingImage = false;
          _hasImageError = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        // iPad에서 카메라가 없을 때 발생하는 에러 처리
        final errorMessage = e.toString().toLowerCase();
        if (errorMessage.contains('camera') || 
            errorMessage.contains('not available') ||
            errorMessage.contains('no camera') ||
            errorMessage.contains('source type 1') ||
            errorMessage.contains('source type unavailable')) {
          showTabaError(
            context, 
            message: AppStrings.cameraNotAvailable(locale),
          );
        } else {
          showTabaError(
            context, 
            message: '${AppStrings.photoError(locale)}: ${e.toString()}',
          );
        }
      }
    }
  }

  void _showImagePickerOptions() {
    TabaModalSheet.show(
      context: context,
      fixedSize: true,
      child: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.localeNotifier,
        builder: (context, locale, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(AppStrings.selectFromGallery(locale)),
                onTap: () {
                  Navigator.pop(context);
                  _pickProfileImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(AppStrings.takePhoto(locale)),
                onTap: () {
                  Navigator.pop(context);
                  _takeProfileImage();
                },
              ),
              if ((_profileImage != null) || 
                  (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty && !_isRemovingImage))
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(AppStrings.removePhoto(locale)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _profileImage = null;
                      _isRemovingImage = true;
                      _hasImageError = false;
                    });
                  },
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveProfile() async {
    final locale = AppLocaleController.localeNotifier.value;
    if (_nicknameCtrl.text.trim().isEmpty) {
      showTabaError(context, message: AppStrings.nicknameRequired(locale));
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? avatarUrl;
      
      // 이미지 제거인 경우 null 전달
      if (_isRemovingImage) {
        avatarUrl = null;
      } else if (_profileImage == null) {
        // 기존 이미지 유지 (변경 없음)
        avatarUrl = _currentAvatarUrl;
      }
      // _profileImage가 있으면 multipart로 직접 업로드

      final success = await _repository.updateUserProfile(
        userId: widget.currentUser.id,
        nickname: _nicknameCtrl.text.trim(),
        profileImage: _profileImage,
        avatarUrl: avatarUrl,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        
        if (success) {
          Navigator.of(context).pop(true);
          final locale = AppLocaleController.localeNotifier.value;
          showTabaSuccess(
            context,
            title: AppStrings.profileUpdated(locale),
            message: AppStrings.changesSaved(locale),
          );
        } else {
          final locale = AppLocaleController.localeNotifier.value;
          showTabaError(context, message: AppStrings.profileUpdateFailed(locale));
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnightSoft,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            NavHeader(
              showBackButton: true,
              actions: [
                _isLoading
                    ? const Padding(
                        padding: EdgeInsets.only(right: AppSpacing.sm),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : TextButton(
                        onPressed: _saveProfile,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.neonPink,
                        ),
                        child: ValueListenableBuilder<Locale>(
                          valueListenable: AppLocaleController.localeNotifier,
                          builder: (context, locale, _) {
                            return Text(
                              AppStrings.save(locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
            Expanded(
              child: ValueListenableBuilder<Locale>(
                valueListenable: AppLocaleController.localeNotifier,
                builder: (context, locale, _) {
                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      // 프로필 이미지
                      Center(
                        child: GestureDetector(
                          onTap: _showImagePickerOptions,
                          child: Stack(
                            children: [
                              _ProfileImageAvatar(
                                radius: 60,
                                profileImage: _isRemovingImage ? null : _profileImage,
                                avatarUrl: _currentAvatarUrl,
                                user: widget.currentUser,
                                hasError: _hasImageError,
                                onImageError: () {
                                  setState(() {
                                    _hasImageError = true;
                                  });
                                },
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.neonPink,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 닉네임
                      TabaTextField(
                        controller: _nicknameCtrl,
                        labelText: AppStrings.nickname(locale),
                      ),
                      // 상태 메시지 제거됨
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageAvatar extends StatelessWidget {
  const _ProfileImageAvatar({
    required this.radius,
    this.profileImage,
    this.avatarUrl,
    required this.user,
    required this.hasError,
    required this.onImageError,
  });

  final double radius;
  final File? profileImage;
  final String? avatarUrl;
  final TabaUser user;
  final bool hasError;
  final VoidCallback onImageError;

  @override
  Widget build(BuildContext context) {
    final shouldShowFallback = profileImage == null && 
                               (avatarUrl == null || avatarUrl!.isEmpty || hasError);
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: shouldShowFallback 
          ? const Color(0xFF0A0024) // 어두운 배경
          : Colors.transparent,
      backgroundImage: shouldShowFallback
          ? null
          : (profileImage != null
              ? FileImage(profileImage!)
              : (avatarUrl != null && avatarUrl!.isNotEmpty
                  ? NetworkImage(avatarUrl!)
                  : null) as ImageProvider?),
      onBackgroundImageError: (profileImage == null && 
                                avatarUrl != null && 
                                avatarUrl!.isNotEmpty && 
                                !hasError)
          ? (exception, stackTrace) {
              onImageError();
            }
          : null,
      child: shouldShowFallback
          ? ClipOval(
              child: Image.asset(
                'assets/images/flower.png',
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // flower.png가 없을 경우를 대비한 fallback (기존 initials 표시)
                  return Container(
                    color: user.avatarFallbackColor(),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          fontSize: radius * 0.5,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}
