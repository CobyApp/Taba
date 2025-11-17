import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/core/locale/app_locale.dart';

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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('설정을 불러오는데 실패했습니다: $e')),
        );
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
      appBar: AppBar(title: const Text('설정'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          GestureDetector(
            onTap: () => _openEditProfile(context, user),
            child: _ProfileCard(user: user),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: '알림'),
          SwitchListTile(
            title: const Text('푸시 알림'),
            subtitle: const Text('새 편지와 반응을 알려드릴게요'),
            value: _pushEnabled,
            onChanged: _isLoadingSettings ? null : (value) => _updatePushNotification(value),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: '친구 초대'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.airplane_ticket),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _inviteCode ?? '코드를 발급해주세요',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    remaining != null
                        ? '유효 시간 ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'
                        : '만료됨 · 재발급이 필요해요',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _inviteCode == null
                              ? null
                              : () => _copyInvite(_inviteCode!),
                          icon: const Icon(Icons.copy),
                          label: const Text('복사'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _inviteCode == null
                              ? null
                              : () => _shareInvite(_inviteCode!),
                          icon: const Icon(Icons.share),
                          label: const Text('공유'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoadingCode ? null : _regenerateCode,
                          child: _isLoadingCode
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('재발급'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person_add),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '친구 코드로 추가',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _showAddFriendDialog(context),
                      icon: const Icon(Icons.person_add),
                      label: const Text('친구 코드로 추가'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: '계정'),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('비밀번호 변경'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 8),
          const _SectionHeader(title: '언어'),
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
                AppLocaleController.localeNotifier.value = value;
              }
            },
            decoration: const InputDecoration(
              labelText: '앱 언어',
            ),
          ),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('개인정보 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }

  void _copyInvite(String code) {
    Clipboard.setData(ClipboardData(text: code));
    showTabaNotice(
      context,
      title: '초대 코드가 복사되었어요',
      message: '친구에게 코드를 공유해 함께 하늘을 채워보세요.',
      icon: Icons.copy_all,
    );
  }

  void _shareInvite(String code) {
    Share.share('친구 코드: $code\nTaba 앱에서 이 코드로 친구를 추가해보세요!');
  }

  void _showAddFriendDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('친구 추가'),
        content: TextField(
          controller: codeController,
          decoration: const InputDecoration(
            labelText: '친구 코드',
            hintText: '예: user123-456789',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              final code = codeController.text.trim();
              if (code.isNotEmpty) {
                Navigator.of(context).pop();
                _addFriendByCode(code);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  Future<void> _addFriendByCode(String inviteCode) async {
    if (inviteCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('친구 코드를 입력해주세요')),
      );
      return;
    }

    try {
      final success = await _repository.addFriendByInviteCode(inviteCode);
      if (!mounted) return;

      if (success) {
        showTabaNotice(
          context,
          title: '친구가 추가되었어요',
          message: '이제 서로의 편지를 주고받을 수 있어요.',
          icon: Icons.check_circle,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('친구 추가에 실패했습니다. 코드를 확인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _updatePushNotification(bool enabled) async {
    setState(() => _pushEnabled = enabled);
    try {
      final success = await _repository.updatePushNotificationSetting(enabled);
      if (!mounted) return;
      
      if (!success) {
        setState(() => _pushEnabled = !enabled);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알림 설정 변경에 실패했습니다')),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
    showTabaNotice(
      context,
      title: '새 초대 코드 발급',
      message: '3분 동안 사용할 수 있는 코드를 만들었어요.',
      icon: Icons.timelapse,
    );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('초대 코드 생성에 실패했습니다')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('로그아웃'),
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그아웃 중 오류가 발생했습니다: $e')),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 선택 중 오류가 발생했습니다: $e')),
        );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 촬영 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('갤러리에서 선택'),
              onTap: () {
                Navigator.pop(context);
                _pickProfileImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('카메라로 촬영'),
              onTap: () {
                Navigator.pop(context);
                _takeProfileImage();
              },
            ),
            if ((_profileImage != null) || 
                (_currentAvatarUrl != null && _currentAvatarUrl!.isNotEmpty && !_isRemovingImage))
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('사진 제거'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImage = null;
                    _isRemovingImage = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_nicknameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요')),
      );
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
          showTabaNotice(
            context,
            title: '프로필이 수정되었어요',
            message: '변경사항이 저장되었습니다.',
            icon: Icons.check_circle,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프로필 수정에 실패했습니다')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('프로필 수정'),
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
                : const Text('저장'),
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
          TextField(
            controller: _nicknameCtrl,
            decoration: const InputDecoration(
              labelText: '닉네임',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          // 상태 메시지
          TextField(
            controller: _statusMessageCtrl,
            decoration: const InputDecoration(
              labelText: '상태 메시지',
              hintText: '자신을 소개해주세요',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }
}
