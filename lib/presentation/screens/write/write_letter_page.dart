import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taba_app/core/constants/app_colors.dart';

class WriteLetterPage extends StatefulWidget {
  const WriteLetterPage({super.key});

  @override
  State<WriteLetterPage> createState() => _WriteLetterPageState();
}

class _NotesController extends TextEditingController {
  _NotesController({required this.titleStyle, required this.bodyStyle, this.firstGapHeight = 2.2});
  TextStyle titleStyle;
  TextStyle bodyStyle;
  double firstGapHeight;

  @override
  TextSpan buildTextSpan({required BuildContext context, TextStyle? style, required bool withComposing}) {
    final full = value.text;
    final nl = full.indexOf('\n');
    final hasBody = nl >= 0;
    final title = hasBody ? full.substring(0, nl) : full;
    final body = hasBody ? full.substring(nl + 1) : '';
    final children = <InlineSpan>[
      TextSpan(text: title, style: titleStyle),
      if (hasBody) ...[
        TextSpan(text: '\n', style: bodyStyle.copyWith(height: firstGapHeight)),
        TextSpan(text: body, style: bodyStyle),
      ],
    ];
    return TextSpan(style: bodyStyle, children: children);
  }
}

class _WriteLetterPageState extends State<WriteLetterPage> {
  final _controller = TextEditingController();
  final _titleController = TextEditingController();
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
      previewGradient: [Color(0xFF0A0024), Color(0xFF0A0024)],
    ),
    _TemplateOption(
      id: 'retro_paper',
      name: '레트로 페이퍼',
      background: Color(0xFF1E1A14), // dark warm paper
      textColor: Colors.white,
      previewGradient: [Color(0xFF1E1A14), Color(0xFF1E1A14)],
    ),
    _TemplateOption(
      id: 'mint_terminal',
      name: '민트 터미널',
      background: Color(0xFF061A17),
      textColor: Colors.white,
      previewGradient: [Color(0xFF061A17), Color(0xFF061A17)],
    ),
    _TemplateOption(
      id: 'holo_purple',
      name: '홀로 퍼플',
      background: Color(0xFF1D1433),
      textColor: Colors.white,
      previewGradient: [Color(0xFF1D1433), Color(0xFF1D1433)],
    ),
    _TemplateOption(
      id: 'pixel_blue',
      name: '픽셀 블루',
      background: Color(0xFF001133),
      textColor: Colors.white,
      previewGradient: [Color(0xFF001133), Color(0xFF001133)],
    ),
    _TemplateOption(
      id: 'sunset_grid',
      name: '선셋 그리드',
      background: Color(0xFF210014),
      textColor: Colors.white,
      previewGradient: [Color(0xFF210014), Color(0xFF210014)],
    ),
  ];
  late _TemplateOption _selectedTemplate = _templateOptions.first;
  late _NotesController _notesController;

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

  void _applyFont(String family) {
    setState(() => _fontFamily = family);
    _updateNotesStyles();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  TextStyle _titleStyle() => (_fontFamily != null
      ? GoogleFonts.getFont(_fontFamily!, color: _selectedTemplate.textColor)
      : TextStyle(color: _selectedTemplate.textColor)).copyWith(fontSize: 26, fontWeight: FontWeight.w800);

  TextStyle _bodyStyle() => (_fontFamily != null
      ? GoogleFonts.getFont(_fontFamily!, color: _selectedTemplate.textColor)
      : TextStyle(color: _selectedTemplate.textColor)).copyWith(fontSize: _editorFontSize, height: 1.8);

  void _updateNotesStyles() {
    _notesController
      ..titleStyle = _titleStyle()
      ..bodyStyle = _bodyStyle()
      ..firstGapHeight = 2.2; // slightly larger gap between title and first body line
  }

  @override
  void initState() {
    super.initState();
    _fontFamily = _recommendedFontForTemplate(_selectedTemplate.id);
    _notesController = _NotesController(titleStyle: _titleStyle(), bodyStyle: _bodyStyle(), firstGapHeight: 2.2);
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _notesController.dispose();
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

  void _openTemplatePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _TemplateSelector(
              templates: _templateOptions,
              selected: _selectedTemplate,
              onSelect: (template) {
                setState(() {
                  _selectedTemplate = template;
                });
                _applyFont(_recommendedFontForTemplate(template.id));
                Navigator.of(context).pop();
              },
            ),
          ),
        );
      },
    );
  }

  void _openFontPicker() {
    final enFonts = <String>['Press Start 2P', 'VT323', 'IBM Plex Mono', 'Bungee'];
    final krFonts = <String>['Jua', 'Sunflower'];
    final jpFonts = <String>['DotGothic16', 'Kosugi Maru'];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        Widget buildGroup(String label, List<String> fonts, {required String langBadge}) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                child: Row(
                  children: [
                    Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(28),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(langBadge, style: const TextStyle(fontSize: 10)),
                    ),
                  ],
                ),
              ),
              ...fonts.map((f) => ListTile(
                    title: Text(f, style: GoogleFonts.getFont(f, color: Colors.white)),
                    subtitle: Text('$langBadge font', style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    onTap: () {
                      _applyFont(f);
                      Navigator.of(context).pop();
                    },
                  )),
              const Divider(color: Colors.white24, height: 12),
            ],
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildGroup('영어', enFonts, langBadge: 'EN'),
                buildGroup('한국어', krFonts, langBadge: 'KO'),
                buildGroup('日本語', jpFonts, langBadge: 'JP'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSendSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Local state for the sheet
        bool localSendToFriend = _sendToFriend;
        _FriendOption? localFriend = _selectedFriend;
        bool localReserve = _reserveSend;
        DateTime? localDate = _scheduledDate;
        TimeOfDay? localTime = _scheduledTime;
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 16, right: 16, top: 16,
              ),
              child: SingleChildScrollView(
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                      children: [
                        const Text('보내기 설정', style: TextStyle(fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('전체 공개'),
                          selected: !localSendToFriend,
                          onSelected: (_) => setLocal(() => localSendToFriend = false),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: const Text('친구에게'),
                          selected: localSendToFriend,
                          onSelected: (_) => setLocal(() => localSendToFriend = true),
                        ),
                      ],
                    ),
                    if (localSendToFriend) ...[
                      const SizedBox(height: 12),
                      const Text('친구 선택'),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _friends.length,
                        separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 8),
                        itemBuilder: (context, index) {
                          final option = _friends[index];
                          final selected = localFriend == option;
                          return ListTile(
                            onTap: () => setLocal(() => localFriend = option),
                            leading: CircleAvatar(backgroundImage: NetworkImage(option.avatarUrl)),
                            title: Text(option.name),
                            trailing: Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                                color: selected ? AppColors.neonPink : Colors.white54),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: localReserve,
                      onChanged: (v) => setLocal(() => localReserve = v),
                      title: const Text('예약 발송'),
                      subtitle: const Text('씨앗이 피어날 시간을 지정합니다'),
                    ),
                    if (localReserve) ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month),
                        title: Text(
                          localDate != null
                              ? '${localDate!.year}.${localDate!.month}.${localDate!.day}'
                              : '날짜 선택',
                        ),
                        onTap: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: localDate ?? now,
                            firstDate: now,
                            lastDate: now.add(const Duration(days: 365)),
                          );
                          if (picked != null) setLocal(() => localDate = picked);
                        },
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.schedule),
                        title: Text(localTime != null ? localTime!.format(context) : '시간 선택'),
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: localTime ?? TimeOfDay.now(),
                          );
                          if (picked != null) setLocal(() => localTime = picked);
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          // Commit local state to parent, then send
                            setState(() {
                            _sendToFriend = localSendToFriend;
                            _selectedFriend = localFriend;
                            _reserveSend = localReserve;
                            _scheduledDate = localDate;
                            _scheduledTime = localTime;
                          });
                          await _showSeedSentDialog();
                          if (mounted) Navigator.of(context).pop(); // close sheet
                          if (mounted) Navigator.of(context).pop(); // close editor
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('씨앗 뿌리기'),
                      ),
                    ),
                    ],
                  ),
                ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedTemplate.background,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: const SizedBox.shrink(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            tooltip: '템플릿',
            icon: const Icon(Icons.layers_outlined),
            onPressed: _openTemplatePicker,
          ),
          IconButton(
            tooltip: '폰트',
            icon: const Icon(Icons.font_download_outlined),
            onPressed: _openFontPicker,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
          child: SingleChildScrollView(
            child: _buildEditor(context),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openSendSheet,
              icon: const Icon(Icons.send_rounded),
              label: const Text('보내기'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final localInputTheme = const InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      disabledBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      isCollapsed: true,
      contentPadding: EdgeInsets.zero,
    );

    return Theme(
      data: Theme.of(context).copyWith(inputDecorationTheme: localInputTheme),
      child: TextField(
        controller: _notesController,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        cursorColor: _selectedTemplate.textColor,
        decoration: InputDecoration(
          hintText: '제목\n내용을 입력하세요... ',
          hintStyle: (_fontFamily != null
                  ? GoogleFonts.getFont(_fontFamily!, color: _selectedTemplate.textColor)
                  : TextStyle(color: _selectedTemplate.textColor))
              .copyWith(color: _selectedTemplate.textColor.withOpacity(.5), height: 1.8),
        ),
        style: _bodyStyle(),
      ),
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
                    color: template.background,
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
                          color: template.background.withOpacity(.35),
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

