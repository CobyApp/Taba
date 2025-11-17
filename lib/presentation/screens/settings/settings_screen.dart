import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
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
          _ProfileCard(user: user),
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
                        child: OutlinedButton(
                          onPressed: _inviteCode == null
                              ? null
                              : () => _copyInvite(_inviteCode!),
                          child: const Text('복사'),
                        ),
                      ),
                      const SizedBox(width: 12),
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
          CircleAvatar(
            radius: 42,
            backgroundImage: NetworkImage(user.avatarUrl),
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
