import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/repository/data_repository.dart';

class WriteLetterPage extends StatefulWidget {
  const WriteLetterPage({super.key, this.onSuccess, this.initialRecipient});

  final VoidCallback? onSuccess;
  final String? initialRecipient; // 친구 ID

  @override
  State<WriteLetterPage> createState() => _WriteLetterPageState();
}

class _NotesController extends TextEditingController {
  _NotesController({required this.titleStyle, required this.bodyStyle, this.firstGapHeight = 3.0});
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
  final _repository = DataRepository.instance;
  bool _sendToFriend = false;
  String? _fontFamily;
  static const double _editorFontSize = 18;
  List<FriendProfile> _friends = [];
  FriendProfile? _selectedFriend;
  bool _isLoadingFriends = false;
  bool _reserveSend = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  late final List<_TemplateOption> _templateOptions = const [
    _TemplateOption(
      id: 'neon_grid',
      name: '네온 그리드',
      background: Color(0xFF0A0024), // deep midnight
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'retro_paper',
      name: '레트로 페이퍼',
      background: Color(0xFF1E1A14), // dark warm paper
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'mint_terminal',
      name: '민트 터미널',
      background: Color(0xFF061A17),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'holo_purple',
      name: '홀로 퍼플',
      background: Color(0xFF1D1433),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'pixel_blue',
      name: '픽셀 블루',
      background: Color(0xFF001133),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'sunset_grid',
      name: '선셋 그리드',
      background: Color(0xFF210014),
      textColor: Colors.white,
    ),
  ];
  late _TemplateOption _selectedTemplate = _templateOptions.first;
  late _NotesController _notesController;
  final List<String> _attachedImages = []; // 첨부된 사진 경로 리스트
  final List<File> _attachedImageFiles = []; // 첨부된 사진 파일 리스트
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _fontFamily = _recommendedFontForTemplate(_selectedTemplate.id);
    _notesController = _NotesController(titleStyle: _titleStyle(), bodyStyle: _bodyStyle(), firstGapHeight: 3.0);
    _loadFriends();
    
    // initialRecipient가 있으면 친구에게 보내기로 설정
    if (widget.initialRecipient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendToFriend = true;
      });
    }
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoadingFriends = true);
    try {
      final friends = await _repository.getFriends();
      if (mounted) {
        setState(() {
          _friends = friends;
          _isLoadingFriends = false;
          
          // initialRecipient가 있으면 해당 친구 선택
          if (widget.initialRecipient != null && friends.isNotEmpty) {
            try {
              _selectedFriend = friends.firstWhere(
                (f) => f.user.id == widget.initialRecipient,
              );
              if (_selectedFriend != null) {
                _sendToFriend = true;
              }
            } catch (e) {
              // 친구를 찾지 못한 경우 무시
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingFriends = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('친구 목록을 불러오는데 실패했습니다: $e')),
        );
      }
    }
  }

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

  String _getPlaceholderForFont() {
    if (_fontFamily == null) return '제목\n내용을 입력하세요... ';
    
    // 영어 폰트
    final enFonts = ['Press Start 2P', 'VT323', 'IBM Plex Mono', 'Bungee'];
    if (enFonts.contains(_fontFamily)) {
      return 'Title\nEnter your content...';
    }
    
    // 일본어 폰트
    final jpFonts = ['DotGothic16', 'Kosugi Maru'];
    if (jpFonts.contains(_fontFamily)) {
      return 'タイトル\n内容を入力してください...';
    }
    
    // 한국어 폰트 (기본)
    return '제목\n내용을 입력하세요... ';
  }

  void _updateNotesStyles() {
    _notesController
      ..titleStyle = _titleStyle()
      ..bodyStyle = _bodyStyle()
      ..firstGapHeight = 3.0; // larger gap between title and first body line
  }


  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        setState(() {
          for (final file in pickedFiles) {
            _attachedImages.add(file.path);
            _attachedImageFiles.add(File(file.path));
          }
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

  void _removeImage(int index) {
    setState(() {
      _attachedImages.removeAt(index);
      _attachedImageFiles.removeAt(index);
    });
  }

  Widget _buildAttachedImagesPreview() {
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachedImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final imagePath = _attachedImages[index];
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  File(imagePath),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  void _openTemplatePicker() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Widget buildGroup(String label, List<String> fonts, {required String langBadge}) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
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
              const Divider(color: Colors.white24, height: 16),
            ],
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
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
        FriendProfile? localFriend = _selectedFriend;
        bool localReserve = _reserveSend;
        DateTime? localDate = _scheduledDate;
        TimeOfDay? localTime = _scheduledTime;
        return StatefulBuilder(
          builder: (context, setLocal) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                left: 20, right: 20, top: 20,
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
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ChoiceChip(
                          label: const Text('전체 공개'),
                          selected: !localSendToFriend,
                          onSelected: (_) => setLocal(() => localSendToFriend = false),
                        ),
                        const SizedBox(width: 12),
                        ChoiceChip(
                          label: const Text('친구에게'),
                          selected: localSendToFriend,
                          onSelected: (_) => setLocal(() => localSendToFriend = true),
                        ),
                      ],
                    ),
                    if (localSendToFriend) ...[
                      const SizedBox(height: 16),
                      const Text('친구 선택'),
                      if (_isLoadingFriends)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else if (_friends.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text('친구가 없습니다', style: TextStyle(color: Colors.white70)),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _friends.length,
                          separatorBuilder: (_, __) => const Divider(color: Colors.white24, height: 12),
                          itemBuilder: (context, index) {
                            final friend = _friends[index];
                            final selected = localFriend?.user.id == friend.user.id;
                            return ListTile(
                              onTap: () => setLocal(() => localFriend = friend),
                              leading: CircleAvatar(backgroundImage: NetworkImage(friend.user.avatarUrl)),
                              title: Text(friend.user.nickname),
                              trailing: Icon(selected ? Icons.check_circle : Icons.circle_outlined,
                                  color: selected ? AppColors.neonPink : Colors.white54),
                            );
                          },
                        ),
                    ],
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSending ? null : () async {
                          // Commit local state to parent, then send
                          setState(() {
                            _sendToFriend = localSendToFriend;
                            _selectedFriend = localFriend;
                            _reserveSend = localReserve;
                            _scheduledDate = localDate;
                            _scheduledTime = localTime;
                          });
                          
                          await _sendLetter();
                        },
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.auto_awesome),
                        label: Text(_isSending ? '전송 중...' : '씨앗 뿌리기'),
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
            tooltip: '사진 첨부',
            icon: Stack(
              children: [
                const Icon(Icons.photo_library_outlined),
                if (_attachedImages.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.neonPink,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${_attachedImages.length}',
                        style: const TextStyle(fontSize: 10, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _pickImages,
          ),
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
        child: Column(
          children: [
            if (_attachedImages.isNotEmpty) _buildAttachedImagesPreview(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: _buildEditor(context),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
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
          hintText: _getPlaceholderForFont(),
          hintStyle: (_fontFamily != null
                  ? GoogleFonts.getFont(_fontFamily!, color: _selectedTemplate.textColor)
                  : TextStyle(color: _selectedTemplate.textColor))
              .copyWith(color: _selectedTemplate.textColor.withOpacity(.5), height: 1.8),
        ),
        style: _bodyStyle(),
      ),
    );
  }


  Future<void> _sendLetter() async {
    final text = _notesController.text.trim();
    if (text.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('편지 내용을 입력해주세요')),
        );
      }
      return;
    }

    // 제목과 본문 분리
    final nl = text.indexOf('\n');
    final title = nl >= 0 ? text.substring(0, nl).trim() : text.trim();
    final content = nl >= 0 ? text.substring(nl + 1).trim() : '';
    
    if (title.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('제목을 입력해주세요')),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      // 이미지 업로드
      List<String> uploadedImageUrls = [];
      if (_attachedImageFiles.isNotEmpty) {
        uploadedImageUrls = await _repository.uploadImages(_attachedImageFiles);
      }

      // 예약 발송 시간 계산
      DateTime? scheduledAt;
      if (_reserveSend && _scheduledDate != null) {
        final time = _scheduledTime ?? const TimeOfDay(hour: 0, minute: 0);
        scheduledAt = DateTime(
          _scheduledDate!.year,
          _scheduledDate!.month,
          _scheduledDate!.day,
          time.hour,
          time.minute,
        );
      }

      // 편지 생성
      // Color를 16진수 문자열로 변환 (#RRGGBB)
      String colorToHex(Color color) {
        return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      }
      
      final success = await _repository.createLetter(
        title: title,
        content: content.isNotEmpty ? content : title,
        preview: content.isNotEmpty ? content.substring(0, content.length > 50 ? 50 : content.length) : title,
        flowerType: 'ROSE', // API 명세서에 따라 대문자
        visibility: _sendToFriend ? 'DIRECT' : 'PUBLIC', // API 명세서에 따라 대문자
        isAnonymous: false,
        template: {
          'background': colorToHex(_selectedTemplate.background),
          'textColor': colorToHex(_selectedTemplate.textColor),
          'fontFamily': _fontFamily ?? 'Jua',
          'fontSize': _editorFontSize,
        },
        attachedImages: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
        scheduledAt: scheduledAt,
        recipientId: _sendToFriend ? _selectedFriend?.user.id : null,
      );

      if (!mounted) return;

      if (success) {
        // 성공 다이얼로그 표시
        final target = _sendToFriend
            ? (_selectedFriend?.user.nickname ?? '친구')
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

        // 콜백 호출하여 메인 화면 새로고침
        widget.onSuccess?.call();
        
        // 화면 닫기
        if (mounted) Navigator.of(context).pop(); // close sheet
        if (mounted) Navigator.of(context).pop(); // close editor
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('편지 전송에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
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
                    color: template.background,
                    borderRadius: BorderRadius.circular(20),
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


class _TemplateOption {
  const _TemplateOption({
    required this.id,
    required this.name,
    required this.background,
    required this.textColor,
  });

  final String id;
  final String name;
  final Color background;
  final Color textColor;
}


