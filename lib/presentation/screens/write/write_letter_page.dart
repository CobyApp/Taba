import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';

class WriteLetterPage extends StatefulWidget {
  const WriteLetterPage({super.key});

  @override
  State<WriteLetterPage> createState() => _WriteLetterPageState();
}

class _WriteLetterPageState extends State<WriteLetterPage> {
  final _controller = TextEditingController();
  int _step = 0;
  final _maxLength = 2000;
  bool _sendToFriend = false;
  late final List<_FriendOption> _friends = const [
    _FriendOption('민트클라우드', 'https://i.pravatar.cc/150?img=12'),
    _FriendOption('네온', 'https://i.pravatar.cc/150?img=5'),
    _FriendOption('라일락', 'https://i.pravatar.cc/150?img=47'),
    _FriendOption('별자리', 'https://i.pravatar.cc/150?img=32'),
    _FriendOption('하루', 'https://i.pravatar.cc/150?img=9'),
  ];
  _FriendOption? _selectedFriend;
  bool _reserveSend = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  late final List<_TemplateOption> _templateOptions = const [
    _TemplateOption(
      id: 'cotton',
      name: '코튼 캔디',
      background: Color(0xFFFFF1F7),
      textColor: Color(0xFF3C1A4A),
      previewGradient: [Color(0xFFFF9FD9), Color(0xFFFFC0E9)],
    ),
    _TemplateOption(
      id: 'aurora',
      name: '오로라 글로우',
      background: Color(0xFF101633),
      textColor: Colors.white,
      previewGradient: [Color(0xFF3B56FF), Color(0xFF8B67F5)],
    ),
    _TemplateOption(
      id: 'mint',
      name: '미드나잇 민트',
      background: Color(0xFFE4FFF7),
      textColor: Color(0xFF003F2C),
      previewGradient: [Color(0xFF6CEBC5), Color(0xFFADF7E2)],
    ),
    _TemplateOption(
      id: 'sunset',
      name: '네온 선셋',
      background: Color(0xFFFFF4E6),
      textColor: Color(0xFF4A1D0E),
      previewGradient: [Color(0xFFFF9A62), Color(0xFFFFC77F)],
    ),
    _TemplateOption(
      id: 'hologram',
      name: '홀로그램 글라스',
      background: Color(0xFFEAE7FF),
      textColor: Color(0xFF1B0C31),
      previewGradient: [Color(0xFF8D9EFF), Color(0xFFB28DFF)],
    ),
  ];
  late _TemplateOption _selectedTemplate = _templateOptions.first;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      _StepData('씨앗 템플릿 고르기', '씨앗을 감쌀 편지 템플릿을 골라요.'),
      _StepData('씨앗 속 마음 쓰기', '마음을 담아 최대 2000자까지 적어보세요.'),
      _StepData('씨앗 날릴 설정', '씨앗이 피어날 순간과 범위를 결정해요.'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('씨앗 보내기'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF080016), Color(0xFF140035), Color(0xFF220058)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
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
                const SizedBox(height: 18),
                Text(
                  steps[_step].title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[_step].subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: [
                      if (_step == 0)
                        _TemplateSelector(
                          templates: _templateOptions,
                          selected: _selectedTemplate,
                          onSelect: (template) {
                            setState(() {
                              _selectedTemplate = template;
                              _step = 1;
                            });
                          },
                        ),
                      if (_step == 1) _buildEditor(context),
                      if (_step == 2) _buildSendSettings(context),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_step < steps.length - 1) {
                      setState(() => _step++);
                    } else {
                      await _showSeedSentDialog();
                      if (mounted) Navigator.of(context).pop();
                    }
                  },
                  child: Text(_step == steps.length - 1 ? '씨앗 뿌리기' : '다음'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _selectedTemplate.background,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(60)),
            boxShadow: [
              BoxShadow(
                color: _selectedTemplate.background.withOpacity(.35),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '씨앗 속 메시지',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: _selectedTemplate.textColor),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                maxLines: 8,
                maxLength: _maxLength,
                cursorColor: _selectedTemplate.textColor,
                decoration: InputDecoration.collapsed(
                  hintText: '씨앗 속에 담을 이야기를 적어주세요...',
                  hintStyle: TextStyle(
                    color: _selectedTemplate.textColor.withOpacity(.7),
                  ),
                ),
                style: TextStyle(color: _selectedTemplate.textColor),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ChoiceChip(
              label: const Text('전체 공개'),
              selected: !_sendToFriend,
              onSelected: (_) => setState(() {
                _sendToFriend = false;
                _selectedFriend = null;
              }),
              backgroundColor: Colors.white.withOpacity(.08),
              selectedColor: AppColors.neonPink.withOpacity(.35),
              labelStyle: TextStyle(
                color: !_sendToFriend ? Colors.white : Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            ChoiceChip(
              label: const Text('친구에게 보내기'),
              selected: _sendToFriend,
              onSelected: (_) => setState(() {
                _sendToFriend = true;
              }),
              backgroundColor: Colors.white.withOpacity(.08),
              selectedColor: AppColors.neonPink.withOpacity(.35),
              labelStyle: TextStyle(
                color: _sendToFriend ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
        if (_sendToFriend)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                '친구 선택',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final option = _friends[index];
                  final selected = _selectedFriend == option;
                  return ListTile(
                    onTap: () => setState(() => _selectedFriend = option),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(option.avatarUrl),
                    ),
                    title: Text(option.name),
                    trailing: Icon(
                      selected ? Icons.check_circle : Icons.circle_outlined,
                      color: selected ? AppColors.neonPink : Colors.white54,
                    ),
                  );
                },
                separatorBuilder: (_, __) => const Divider(
                  color: Colors.white24,
                  height: 8,
                ),
                itemCount: _friends.length,
              ),
            ],
          ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(24),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                value: _reserveSend,
                onChanged: (value) => setState(() => _reserveSend = value),
                title: const Text('예약 발송 설정'),
                subtitle: const Text('씨앗이 피어날 시간을 지정할 수 있어요'),
              ),
              if (_reserveSend) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_month, color: Colors.white),
                  title: Text(
                    _scheduledDate != null
                        ? '${_scheduledDate!.year}.${_scheduledDate!.month}.${_scheduledDate!.day}'
                        : '날짜 선택',
                  ),
                  onTap: _pickDate,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule, color: Colors.white),
                  title: Text(
                    _scheduledTime != null
                        ? _scheduledTime!.format(context)
                        : '시간 선택',
                  ),
                  onTap: _pickTime,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showSeedSentDialog() async {
    final target = _sendToFriend
        ? (_selectedFriend?.name ?? '친구')
        : '전체 공개';
    final scheduleSummary = _reserveSend && _scheduledDate != null
        ? '씨앗은 ${_scheduledDate!.year}.${_scheduledDate!.month}.${_scheduledDate!.day} '
            '${_scheduledTime?.format(context) ?? '00:00'} 에 피어날 거예요.'
        : '씨앗은 바로 네온 하늘로 날아가요.';
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('씨앗을 뿌렸어요'),
          content: Text('받는 대상: $target\n$scheduleSummary'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
    }
  }
}

class _TemplateSelector extends StatelessWidget {
  const _TemplateSelector({
    required this.templates,
    required this.selected,
    required this.onSelect,
  });

  final List<_TemplateOption> templates;
  final _TemplateOption selected;
  final ValueChanged<_TemplateOption> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final template = templates[index];
              final isSelected = template.id == selected.id;
              return GestureDetector(
                onTap: () => onSelect(template),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 150,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: template.previewGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(.5),
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: template.previewGradient.first
                              .withOpacity(.4),
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
                      Text(template.name),
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
        const Text(
          '* 시즌 / 프리미엄 템플릿은 곧 추가될 예정이에요.',
          style: TextStyle(color: Colors.white70),
        ),
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
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
      backgroundColor: Colors.white.withAlpha(32),
      side: const BorderSide(color: Colors.white24),
    );
  }
}

class _StepData {
  const _StepData(this.title, this.subtitle);
  final String title;
  final String subtitle;
}

class _TemplateOption {
  const _TemplateOption({
    required this.id,
    required this.name,
    required this.background,
    required this.textColor,
    required this.previewGradient,
  });

  final String id;
  final String name;
  final Color background;
  final Color textColor;
  final List<Color> previewGradient;
}

class _FriendOption {
  const _FriendOption(this.name, this.avatarUrl);
  final String name;
  final String avatarUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _FriendOption &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          avatarUrl == other.avatarUrl;

  @override
  int get hashCode => Object.hash(name, avatarUrl);
}

