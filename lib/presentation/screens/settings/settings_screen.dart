import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.currentUser,
    this.onLogout,
  });

  final TabaUser currentUser;
  final VoidCallback? onLogout;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repository = DataRepository.instance;
  bool _pushEnabled = true;
  String? _inviteCode;
  DateTime? _codeGeneratedAt;
  bool _isLoadingSettings = false;
  bool _isLoadingCode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadInviteCode();
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
      final code = await _repository.getCurrentInviteCode();
      if (mounted && code != null) {
        setState(() {
          _inviteCode = code;
          _codeGeneratedAt = DateTime.now(); // API에서 만료 시간을 받아올 수 있으면 그걸 사용
        });
      }
    } catch (e) {
      // 초대 코드 로드 실패는 조용히 처리
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    final remaining = _remainingValidity();
    return Scaffold(
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
                      GestureDetector(
                        onTap: () => _openEditProfile(context, user),
                        child: _ProfileCard(user: user),
                      ),
                      const SizedBox(height: 24),
                      _SectionHeader(title: AppStrings.notificationsSection(locale)),
                      SwitchListTile(
                        title: Text(AppStrings.pushNotifications(locale)),
                        subtitle: Text(AppStrings.pushNotificationsSubtitle(locale)),
                        value: _pushEnabled,
                        onChanged: _isLoadingSettings ? null : (value) => _updatePushNotification(value),
                      ),
                      const SizedBox(height: 24),
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
                                Expanded(
                                  child: TabaButton(
                                    onPressed: _inviteCode == null
                                        ? null
                                        : () => _copyInvite(_inviteCode!),
                                    label: AppStrings.copyButton(locale),
                                    icon: Icons.copy,
                                    variant: TabaButtonVariant.outline,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TabaButton(
                                    onPressed: _inviteCode == null
                                        ? null
                                        : () => _shareInvite(_inviteCode!),
                                    label: AppStrings.shareButton(locale),
                                    icon: Icons.share,
                                    variant: TabaButtonVariant.outline,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TabaButton(
                                    onPressed: _isLoadingCode ? null : _regenerateCode,
                                    label: AppStrings.regenerateButton(locale),
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
                      const SizedBox(height: 24),
                      _SectionHeader(title: AppStrings.accountSection(locale)),
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: Text(AppStrings.changePassword(locale)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      const SizedBox(height: 8),
                      _SectionHeader(title: AppStrings.languageSection(locale)),
                      DropdownButtonFormField<Locale>(
                        value: AppLocaleController.localeNotifier.value,
                        items: AppLocaleController.supportedLocales
                            .map(
                              (l) => DropdownMenuItem(
                                value: l,
                                child: Text(
                                  {'en': 'English', 'ko': '한국어', 'ja': '日本語'}[l.languageCode] ?? l.languageCode,
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            AppLocaleController.setLocale(value);
                          }
                        },
                        decoration: InputDecoration(
                          labelText: AppStrings.appLanguage(locale),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.shield_outlined),
                        title: Text(AppStrings.privacySettings(locale)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(AppStrings.logout(locale)),
                        onTap: () => _handleLogout(context),
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

  void _shareInvite(String code) {
    final locale = AppLocaleController.localeNotifier.value;
    Share.share(AppStrings.shareInviteMessage(locale, code));
  }

  void _showAddFriendDialog(BuildContext context) {
    final locale = AppLocaleController.localeNotifier.value;
    final codeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.addFriend(locale)),
        content: TabaTextField(
          controller: codeController,
          labelText: AppStrings.friendCode(locale),
          hintText: '예: user123-456789',
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppStrings.cancel(locale)),
          ),
          TextButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(context).pop();
                _addFriendByCode(code);
              }
            },
            child: Text(AppStrings.add(locale)),
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
      final success = await _repository.addFriendByInviteCode(inviteCode);
      if (!mounted) return;

      final locale = AppLocaleController.localeNotifier.value;
      if (success) {
        showTabaSuccess(
          context,
          title: AppStrings.friendAdded(locale),
          message: AppStrings.friendAddedMessage(locale),
        );
      } else {
        showTabaError(context, message: AppStrings.addFriendFailed(locale));
      }
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
    }
  }

  Future<void> _updatePushNotification(bool enabled) async {
    setState(() => _pushEnabled = enabled);
    try {
      final success = await _repository.updatePushNotificationSetting(enabled);
      if (!mounted) return;
      
      if (!success) {
        setState(() => _pushEnabled = !enabled);
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.notificationUpdateFailed(locale));
      }
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
      setState(() => _pushEnabled = !enabled);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _regenerateCode() async {
    if (_isLoadingCode) return;
    
    setState(() => _isLoadingCode = true);
    try {
      final code = await _repository.generateInviteCode();
      if (!mounted) return;
      
      if (code != null) {
    setState(() {
          _inviteCode = code;
      _codeGeneratedAt = DateTime.now();
    });
    final locale = AppLocaleController.localeNotifier.value;
    showTabaSuccess(
      context,
      title: AppStrings.newInviteCodeGenerated(locale),
      message: AppStrings.inviteCodeValidFor(locale),
    );
      } else {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.inviteCodeGenerationFailed(locale));
      }
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
    } finally {
      if (mounted) {
        setState(() => _isLoadingCode = false);
      }
    }
  }

  Duration? _remainingValidity() {
    if (_inviteCode == null || _codeGeneratedAt == null) return null;
    const validity = Duration(minutes: 3);
    final diff = DateTime.now().difference(_codeGeneratedAt!);
    if (diff >= validity) return null;
    return validity - diff;
  }

  Future<void> _openEditProfile(BuildContext context, TabaUser user) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => EditProfileScreen(
          currentUser: user,
        ),
      ),
    );
    
    if (result == true && mounted) {
      // 프로필이 업데이트되었으면 부모에게 알림
      // main_shell에서 사용자 정보를 다시 불러올 수 있도록
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    final locale = AppLocaleController.localeNotifier.value;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.logout(locale)),
        content: Text(AppStrings.reallyLogout(locale)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppStrings.cancel(locale)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppStrings.logout(locale)),
          ),
        ],
      ),
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
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final TabaUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(60)),
      ),
      child: Row(
        children: [
          UserAvatar(
            user: user,
            radius: 42,
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickname,
                  style: Theme.of(
                    context,
                  ).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                Text(
                  '@${user.username}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  user.statusMessage,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
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
  final _statusMessageCtrl = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _profileImage;
  String? _currentAvatarUrl;
  bool _isRemovingImage = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameCtrl.text = widget.currentUser.nickname;
    _statusMessageCtrl.text = widget.currentUser.statusMessage;
    _currentAvatarUrl = widget.currentUser.avatarUrl;
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _statusMessageCtrl.dispose();
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
        });
      }
    } catch (e) {
      if (mounted) {
        showTabaError(context, message: '사진 선택 중 오류가 발생했습니다: $e');
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
      );
      if (pickedFile != null) {
        setState(() {
          _profileImage = File(pickedFile.path);
          _isRemovingImage = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.photoError(locale) + e.toString());
      }
    }
  }

  void _showImagePickerOptions() {
    TabaModalSheet.show(
      context: context,
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
        statusMessage: _statusMessageCtrl.text.trim(),
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
      appBar: AppBar(
        title: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Text(AppStrings.editProfileTitle(locale));
          },
        ),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : ValueListenableBuilder<Locale>(
                    valueListenable: AppLocaleController.localeNotifier,
                    builder: (context, locale, _) {
                      return Text(AppStrings.save(locale));
                    },
                  ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 프로필 이미지
          Center(
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.white.withAlpha(30),
                    backgroundImage: _isRemovingImage
                        ? null
                        : (_profileImage != null
                            ? FileImage(_profileImage!)
                            : (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty
                                ? NetworkImage(_currentAvatarUrl!)
                                : null) as ImageProvider?),
                    child: _isRemovingImage || 
                           (_profileImage == null && 
                            (_currentAvatarUrl == null || _currentAvatarUrl!.isEmpty))
                        ? Text(
                            widget.currentUser.initials,
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
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
            labelText: '닉네임',
          ),
          const SizedBox(height: 16),
          // 상태 메시지
          TabaTextField(
            controller: _statusMessageCtrl,
            labelText: '상태 메시지',
            hintText: '자신을 소개해주세요',
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
