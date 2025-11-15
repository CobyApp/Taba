import 'dart:math' as math;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.currentUser});

  final TabaUser currentUser;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _darkTheme = true;
  String? _inviteCode;
  DateTime? _codeGeneratedAt;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.currentUser;
    final remaining = _remainingValidity();
    return Scaffold(
      appBar: AppBar(title: const Text('설정'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          _ProfileCard(user: user),
          const SizedBox(height: 24),
          const _SectionHeader(title: '알림'),
          SwitchListTile(
            title: const Text('푸시 알림'),
            subtitle: const Text('새 편지와 반응을 알려드릴게요'),
            value: _pushEnabled,
            onChanged: (value) => setState(() => _pushEnabled = value),
          ),
          SwitchListTile(
            title: const Text('이메일 알림'),
            subtitle: const Text('주간 리포트와 소식을 이메일로 받아요'),
            value: _emailEnabled,
            onChanged: (value) => setState(() => _emailEnabled = value),
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: '화면'),
          SwitchListTile(
            title: const Text('네온 다크 테마'),
            subtitle: const Text('눈부심을 줄이는 밤 모드'),
            value: _darkTheme,
            onChanged: (value) => setState(() => _darkTheme = value),
          ),
          ListTile(
            leading: const Icon(Icons.palette_outlined),
            title: const Text('테마 컬러'),
            subtitle: const Text('핑크 · 블루 · 민트 등'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const SizedBox(height: 24),
          const _SectionHeader(title: '친구 초대'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
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
                          onPressed: _regenerateCode,
                          child: const Text('재발급'),
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
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('개인정보 설정'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('로그아웃'),
            onTap: () {},
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

  void _regenerateCode() {
    setState(() {
      _inviteCode = _generateCode(widget.currentUser.username);
      _codeGeneratedAt = DateTime.now();
    });
    showTabaNotice(
      context,
      title: '새 초대 코드 발급',
      message: '3분 동안 사용할 수 있는 코드를 만들었어요.',
      icon: Icons.timelapse,
    );
  }

  String _generateCode(String username) {
    final rand = math.Random();
    final digits = (rand.nextInt(900000) + 100000).toString();
    final prefix =
        username.substring(0, math.min(4, username.length)).toUpperCase();
    return '$prefix-$digits';
  }

  Duration? _remainingValidity() {
    if (_inviteCode == null || _codeGeneratedAt == null) return null;
    const validity = Duration(minutes: 3);
    final diff = DateTime.now().difference(_codeGeneratedAt!);
    if (diff >= validity) return null;
    return validity - diff;
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final TabaUser user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(32),
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
