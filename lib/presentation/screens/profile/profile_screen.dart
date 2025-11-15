import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.currentUser});

  final TabaUser currentUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradientHeroPink,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('프로필'),
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0x33FFFFFF), Color(0x11FFFFFF)],
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withAlpha(70)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundImage: NetworkImage(currentUser.avatarUrl),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentUser.nickname,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          '@${currentUser.username}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(currentUser.statusMessage),
                        const SizedBox(height: 14),
                        Row(
                          children: const [
                            _StatChip(label: '보낸', value: '42'),
                            SizedBox(width: 8),
                            _StatChip(label: '받은', value: '38'),
                            SizedBox(width: 8),
                            _StatChip(label: '친구', value: '15'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: '내 활동'),
            _MenuTile(
              icon: Icons.mail_outline,
              title: '내가 보낸 편지',
              subtitle: '보낸 편지와 통계를 확인해요',
            ),
            _MenuTile(
              icon: Icons.local_florist_outlined,
              title: '꽃다발 편집',
              subtitle: '꽃다발을 꾸미고 공유해요',
            ),
            _MenuTile(
              icon: Icons.bar_chart_rounded,
              title: '활동 통계',
              subtitle: '이번 주 활동 리포트를 확인해요',
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: '설정'),
            _MenuTile(
              icon: Icons.notifications_active_outlined,
              title: '알림 설정',
              subtitle: '푸시, 이메일 알림을 관리해요',
            ),
            _MenuTile(
              icon: Icons.lock_outline,
              title: '개인정보 설정',
              subtitle: '프로필 공개 범위를 바꿔요',
            ),
            _MenuTile(
              icon: Icons.color_lens_outlined,
              title: '테마 설정',
              subtitle: '라이트/다크 모드를 선택해요',
            ),
            const SizedBox(height: 24),
            const _SectionTitle(title: '도움말'),
            _MenuTile(
              icon: Icons.help_outline,
              title: '도움말 & 문의',
              subtitle: '무엇이든 물어보세요',
            ),
            _MenuTile(
              icon: Icons.logout,
              title: '로그아웃',
              subtitle: '다시 로그인할 수 있어요',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0x33FFFFFF), Color(0x12FFFFFF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withAlpha(60)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.midnightGlass,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.white.withAlpha(30),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
