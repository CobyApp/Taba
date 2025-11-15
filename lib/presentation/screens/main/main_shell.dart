import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/mock/mock_data.dart';
import 'package:taba_app/presentation/screens/bouquet/bouquet_screen.dart';
import 'package:taba_app/presentation/screens/profile/profile_screen.dart';
import 'package:taba_app/presentation/screens/sky/sky_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  Widget build(BuildContext context) {
    final repo = MockDataRepository.instance;
    return Scaffold(
      body: SkyScreen(
        letters: repo.letters,
        notifications: repo.notifications,
        onOpenBouquet: () => _openBouquet(context, repo),
        onOpenProfile: () => _openProfile(context, repo),
        onCompose: () => _openWriteSheet(context),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWriteSheet(context),
        icon: const Icon(Icons.edit_rounded),
        label: const Text('편지 쓰기'),
      ),
    );
  }

  void _openBouquet(BuildContext context, MockDataRepository repo) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BouquetScreen(folders: repo.folders),
        ),
      ),
    );
  }

  void _openProfile(BuildContext context, MockDataRepository repo) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.9,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: ProfileScreen(currentUser: repo.users.first),
        ),
      ),
    );
  }

  void _openWriteSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _WriteLetterSheet(),
    );
  }
}

class _WriteLetterSheet extends StatefulWidget {
  const _WriteLetterSheet();

  @override
  State<_WriteLetterSheet> createState() => _WriteLetterSheetState();
}

class _WriteLetterSheetState extends State<_WriteLetterSheet> {
  final _controller = TextEditingController();
  int _step = 0;
  final _maxLength = 2000;
  String _selectedVisibility = '전체 공개';
  String _selectedFlower = '장미 🌹';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData('템플릿 선택', 'Y2K 감성 템플릿을 골라보세요.'),
      _StepData('편지 작성', '마음을 담아 최대 2000자까지 작성해요.'),
      _StepData('발송 설정', '공개 범위와 꽃 종류를 선택해요.'),
    ];

    return DraggableScrollableSheet(
      initialChildSize: .9,
      maxChildSize: .95,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            gradient: LinearGradient(
              colors: [Color(0xFF0E0332), Color(0xFF1C0051), Color(0xFF340058)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(60),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  steps.length,
                  (index) => Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: index <= _step
                            ? AppColors.neonPink
                            : Colors.white.withAlpha(40),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                steps[_step].title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                steps[_step].subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: controller,
                  children: [
                    if (_step == 0)
                      _TemplateSelector(
                        onSelect: () => setState(() => _step = 1),
                      ),
                    if (_step == 1) _buildEditor(context),
                    if (_step == 2) _buildSendSettings(context),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_step < steps.length - 1) {
                    setState(() => _step++);
                  } else {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('편지가 네온 하늘로 날아갔어요!'),
                        backgroundColor: AppColors.neonPink,
                      ),
                    );
                  }
                },
                child: Text(_step == steps.length - 1 ? '날려보내기' : '다음'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFACE4), Color(0xFF9B8CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(80)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                maxLines: 8,
                maxLength: _maxLength,
                decoration: const InputDecoration.collapsed(
                  hintText: '마음을 담아 편지를 작성해보세요...',
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                children: const [
                  _ChipIcon(icon: Icons.font_download_rounded, label: '폰트'),
                  _ChipIcon(icon: Icons.format_size, label: '크기'),
                  _ChipIcon(icon: Icons.palette_outlined, label: '색상'),
                  _ChipIcon(icon: Icons.emoji_emotions_outlined, label: '스티커'),
                  _ChipIcon(icon: Icons.undo, label: '실행취소'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSendSettings(BuildContext context) {
    final flowerOptions = ['장미 🌹', '튤립 🌷', '벚꽃 🌸', '해바라기 🌻'];
    final visibilityOptions = ['전체 공개', '친구만', '특정인', '나만 보기'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('공개 범위', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: visibilityOptions
              .map(
                (label) => ChoiceChip(
                  label: Text(label),
                  selected: _selectedVisibility == label,
                  onSelected: (_) =>
                      setState(() => _selectedVisibility = label),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        const Text('꽃 종류', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: flowerOptions
              .map(
                (label) => ChoiceChip(
                  label: Text(label),
                  selected: _selectedFlower == label,
                  onSelected: (_) => setState(() => _selectedFlower = label),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Row(
            children: const [
              Icon(Icons.alarm, color: AppColors.neonPink),
              SizedBox(width: 12),
              Expanded(child: Text('예약 발송, 반복 발송 기능이 곧 열려요.')),
            ],
          ),
        ),
      ],
    );
  }
}

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({required this.onSelect});

  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final templates = [
      (gradient: AppColors.gradientHeroPink, label: 'Neon Pink'),
      (gradient: AppColors.gradientHeroBlue, label: 'Cyber Blue'),
      (gradient: AppColors.gradientSky, label: 'Aurora Sky'),
      (gradient: AppColors.gradientDusk, label: 'Pixel Sunset'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 180,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final template = templates[index];
              return GestureDetector(
                onTap: onSelect,
                child: Container(
                  width: 140,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: template.gradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(90),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(template.label),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemCount: templates.length,
          ),
        ),
        const SizedBox(height: 16),
        const Text('* 시즌 / 프리미엄 템플릿은 차후 업데이트 예정이에요.'),
      ],
    );
  }
}

class _ChipIcon extends StatelessWidget {
  const _ChipIcon({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 18), const SizedBox(width: 6), Text(label)],
      ),
      backgroundColor: Colors.white.withAlpha(20),
      side: const BorderSide(color: Colors.white24),
    );
  }
}

class _StepData {
  const _StepData(this.title, this.subtitle);
  final String title;
  final String subtitle;
}
