import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taba_app/core/constants/app_colors.dart';

class WriteLetterPage extends StatefulWidget {
  const WriteLetterPage({super.key});

  @override
  State<WriteLetterPage> createState() => _WriteLetterPageState();
}

class _WriteLetterPageState extends State<WriteLetterPage> {
  final _controller = TextEditingController();
  final _titleController = TextEditingController();
  int _step = 0;
  final _maxLength = 2000;
  bool _sendToFriend = false;
  String? _fontFamily;
  static const double _editorFontSize = 18;
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
      id: 'neon_grid',
      name: '네온 그리드',
      background: Color(0xFF0A0024), // deep midnight
      textColor: Colors.white,
      previewGradient: [Color(0xFF6A00FF), Color(0xFFFF2EB6)],
    ),
    _TemplateOption(
      id: 'retro_paper',
      name: '레트로 페이퍼',
      background: Color(0xFFFFF3D6), // warm paper
      textColor: Color(0xFF3D2A1E),
      previewGradient: [Color(0xFFFFD9A0), Color(0xFFFFF1D8)],
    ),
    _TemplateOption(
      id: 'mint_terminal',
      name: '민트 터미널',
      background: Color(0xFF061A17),
      textColor: Color(0xFF9FFFE0),
      previewGradient: [Color(0xFF003F33), Color(0xFF00A389)],
    ),
    _TemplateOption(
      id: 'holo_purple',
      name: '홀로 퍼플',
      background: Color(0xFFEDE6FF),
      textColor: Color(0xFF2B1B57),
      previewGradient: [Color(0xFFA58DFF), Color(0xFFC7B7FF)],
    ),
    _TemplateOption(
      id: 'pixel_blue',
      name: '픽셀 블루',
      background: Color(0xFF001133),
      textColor: Color(0xFFB3C7FF),
      previewGradient: [Color(0xFF002B8A), Color(0xFF0044CC)],
    ),
    _TemplateOption(
      id: 'sunset_grid',
      name: '선셋 그리드',
      background: Color(0xFF2B0010),
      textColor: Color(0xFFFFE1E1),
      previewGradient: [Color(0xFFFF5E7E), Color(0xFFFFA06B)],
    ),
  ];
  late _TemplateOption _selectedTemplate = _templateOptions.first;

  String _recommendedFontForTemplate(String templateId) {
    switch (templateId) {
      case 'neon_grid':
        return 'Bungee';
      case 'retro_paper':
        return 'Sunflower';
      case 'mint_terminal':
        return 'VT323';
      case 'holo_purple':
        return 'IBM Plex Mono';
      case 'pixel_blue':
        return 'Press Start 2P';
      case 'sunset_grid':
        return 'Jua';
      default:
        return 'Jua';
    }
  }

  @override
  void initState() {
    super.initState();
    _fontFamily = _recommendedFontForTemplate(_selectedTemplate.id);
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _openEmojiPicker() {
    // 피처폰/카오모지 스타일 이모티콘
    final emojis = [
      '( •_•)ノ✿', '(｡•̀ᴗ-)✧', '(๑˃̵ᴗ˂̵)و', '( ﾟ▽ﾟ)/', '(╯°□°）╯︵ ┻━┻', '┬─┬ ノ( ゜-゜ノ)',
      '(>_<)', '(T_T)', '(＾▽＾)', '(¬‿¬)', '(•̀ᴗ•́)و ̑̑', '(づ｡◕‿‿◕｡)づ', '(≧∇≦)/', '٩(๑❛ᴗ❛๑)۶',
      '(ᵔᴥᵔ)', '(*´∀｀*)', '(๑•̀ㅂ•́)و✧', '(◕‿◕✿)', '(ノ^_^)ノ', '(☞ﾟヮﾟ)☞', 'ʕ•ᴥ•ʔ', 'ʕ•̀ω•́ʔ✧',
      '(｡•́‿•̀｡)', '( ◜‿◝ )♡', '(*´ω｀*)', '(´▽`ʃ♡ƪ)', '( •̀ .̫ •́ )✧', '( ˘ ³˘)♥', '(ง •̀_•́)ง',
      '(*•̀ᴗ•́*)و ̑̑', '(￣ー￣)ゞ', '(o_ _)ﾉ彡☆', '(╥_╥)', '(＾ω＾)', '☆〜（ゝ。∂）', '(ノಠ益ಠ)ノ彡',
      '(^_−)−☆', '(￣3￣)', '(∩^o^)⊃━☆ﾟ.*･｡', '(っ˘ڡ˘ς)', '( ͡° ͜ʖ ͡°)', '( •̀ὤ•́ )', '(๑˘︶˘๑)',
    ];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: emojis.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 8),
              itemBuilder: (context, index) {
                final e = emojis[index];
                return ListTile(
                  title: Text(e, style: const TextStyle(fontFamily: 'monospace')),
                  onTap: () {
                    final text = _controller.text;
                    final sel = _controller.selection;
                    final insertAt = sel.start >= 0 ? sel.start : text.length;
                    final newText = text.replaceRange(insertAt, insertAt, e);
                    _controller.value = TextEditingValue(
                      text: newText,
                      selection: TextSelection.collapsed(offset: insertAt + e.length),
                    );
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
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
                const SizedBox(height: 16),
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
                              _fontFamily = _recommendedFontForTemplate(template.id);
                            });
                          },
                        ),
                      if (_step == 1) _buildEditor(context),
                      if (_step == 2) _buildSendSettings(context),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (_step > 0)
                      OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text('이전'),
                      ),
                    const Spacer(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IntrinsicWidth(
                        child: ElevatedButton(
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
                      ),
                    ),
                  ],
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
          child: DefaultTextStyle(
            style: (_fontFamily != null
                ? GoogleFonts.getFont(_fontFamily!, color: _selectedTemplate.textColor)
                : TextStyle(color: _selectedTemplate.textColor)),
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  '제목',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: _selectedTemplate.textColor),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  maxLines: 1,
                  maxLength: 50,
                  cursorColor: _selectedTemplate.textColor,
                  decoration: InputDecoration(
                    hintText: '제목을 입력하세요',
                    hintStyle: TextStyle(color: _selectedTemplate.textColor.withOpacity(.6)),
                    counterText: '',
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _selectedTemplate.textColor.withOpacity(.4)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: _selectedTemplate.textColor),
                    ),
                  ),
                  style: (_fontFamily != null
                          ? GoogleFonts.getFont(
                              _fontFamily!,
                              color: _selectedTemplate.textColor,
                              fontSize: _editorFontSize,
                            )
                          : const TextStyle(fontSize: _editorFontSize))
                      .copyWith(color: _selectedTemplate.textColor),
                ),
                const SizedBox(height: 16),
                Text(
                  '씨앗 속 메시지',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: _selectedTemplate.textColor),
                ),
                const SizedBox(height: 8),
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
                style: (_fontFamily != null
                        ? GoogleFonts.getFont(
                            _fontFamily!,
                            color: _selectedTemplate.textColor,
                            fontSize: _editorFontSize,
                          )
                        : const TextStyle(fontSize: _editorFontSize)).copyWith(
                            color: _selectedTemplate.textColor),
              ),
              const SizedBox(height: 16),
              _EditorToolbar(
                fontFamily: _fontFamily,
                onFontFamilyChanged: (v) => setState(() => _fontFamily = v),
                textColor: _selectedTemplate.textColor,
                onInsertEmoji: _openEmojiPicker,
              ),
            ],
            ),
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

class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({
    required this.fontFamily,
    required this.onFontFamilyChanged,
    required this.textColor,
    required this.onInsertEmoji,
  });

  final String? fontFamily;
  final ValueChanged<String?> onFontFamilyChanged;
  final Color textColor;
  final VoidCallback onInsertEmoji;

  @override
  Widget build(BuildContext context) {
    // 뉴트로 감성 위주의 폰트만 제공
    final fonts = <String>[
      'Press Start 2P',  // 픽셀/레트로 콘솔
      'VT323',           // 그린 터미널
      'IBM Plex Mono',   // 모노 레트로
      'Bungee',          // 네온 간판
      'DotGothic16',     // 일본 레트로
      'Kosugi Maru',     // 일본 라운드
      'Jua',             // 한국 레트로 라운드
      'Sunflower',       // 한국 레트로 명조
    ];
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: fontFamily,
            items: fonts
                .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(f, style: GoogleFonts.getFont(f, color: textColor)),
                    ))
                .toList(),
            onChanged: onFontFamilyChanged,
            decoration: const InputDecoration(
              labelText: '레트로 폰트',
            ),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: '이모지',
          onPressed: onInsertEmoji,
          icon: const Icon(Icons.emoji_emotions_outlined),
        ),
      ],
    );
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

