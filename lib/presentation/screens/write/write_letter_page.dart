import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class WriteLetterPage extends StatefulWidget {
  const WriteLetterPage({
    super.key, 
    this.onSuccess, 
    this.initialRecipient,
    this.replyToLetterId, // 답장할 편지 ID
  });

  final VoidCallback? onSuccess;
  final String? initialRecipient; // 친구 ID (일반 편지 작성 시)
  final String? replyToLetterId; // 답장할 편지 ID (답장 시)

  @override
  State<WriteLetterPage> createState() => _WriteLetterPageState();
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
    
    // 본문을 줄 단위로 분리하여 각 줄바꿈에 명시적으로 height 적용
    List<InlineSpan> buildBodySpans(String bodyText) {
      if (bodyText.isEmpty) return [];
      
      final lines = bodyText.split('\n');
      final spans = <InlineSpan>[];
      
      for (var i = 0; i < lines.length; i++) {
        if (i > 0) {
          // 줄바꿈 문자에 명시적으로 bodyStyle의 height 적용
          spans.add(TextSpan(text: '\n', style: bodyStyle));
        }
        spans.add(TextSpan(text: lines[i], style: bodyStyle));
      }
      
      return spans;
    }
    
    final children = <InlineSpan>[
      TextSpan(text: title, style: titleStyle),
      if (hasBody) ...[
        // 제목과 본문 사이 간격 (편지 보기 화면과 동일하게)
        TextSpan(text: '\n', style: bodyStyle.copyWith(height: firstGapHeight)),
        // 본문을 줄 단위로 처리하여 줄간격 제대로 적용
        ...buildBodySpans(body),
      ],
    ];
    // bodyStyle을 기본 스타일로 사용
    return TextSpan(style: bodyStyle, children: children);
  }
}

class _WriteLetterPageState extends State<WriteLetterPage> {
  final _repository = DataRepository.instance;
  bool _sendToFriend = false;
  String? _fontFamily;
  static const double _editorFontSize = 20;
  List<FriendProfile> _friends = [];
  FriendProfile? _selectedFriend;
  bool _isLoadingFriends = false;
  bool _reserveSend = false;
  DateTime? _scheduledDate;
  TimeOfDay? _scheduledTime;
  final List<_TemplateOption> _templateOptions = const [
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
    _TemplateOption(
      id: 'cyber_green',
      name: '사이버 그린',
      background: Color(0xFF001100),
      textColor: Color(0xFF00FF00),
    ),
    _TemplateOption(
      id: 'matrix_dark',
      name: '매트릭스 다크',
      background: Color(0xFF000000),
      textColor: Color(0xFF00CC00),
    ),
    _TemplateOption(
      id: 'neon_pink',
      name: '네온 핑크',
      background: Color(0xFF1A0016),
      textColor: Color(0xFFFF00FF),
    ),
    _TemplateOption(
      id: 'retro_yellow',
      name: '레트로 옐로우',
      background: Color(0xFF2A1F00),
      textColor: Color(0xFFFFFF00),
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
    // 시스템 언어에 맞게 기본 폰트 설정
    final locale = AppLocaleController.localeNotifier.value;
    _fontFamily = _getDefaultFontForLocale(locale.languageCode);
    // 제목-본문 간격을 편지 보기 화면과 동일하게 설정
    // 편지 보기: SizedBox(height: 48)
    // 제목 줄 높이: 24px * 1.4 = 33.6px, 본문 줄 높이: 20px * 1.6 = 32px
    // 제목 하단부터 본문 상단까지 약 48px 간격을 만들기 위해 height 배수 조정
    _notesController = _NotesController(titleStyle: _titleStyle(), bodyStyle: _bodyStyle(), firstGapHeight: 2.8);
    _loadFriends();
    
    // initialRecipient가 있으면 친구에게 보내기로 설정
    if (widget.initialRecipient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendToFriend = true;
      });
    }
  }

  String _getDefaultFontForLocale(String languageCode) {
    switch (languageCode) {
      case 'ko':
        return 'Jua';
      case 'ja':
        return 'Yomogi';
      case 'en':
      default:
        return 'Indie Flower';
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
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.loadFriendsFailed(locale) + e.toString());
      }
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
      ? GoogleFonts.getFont(_fontFamily!, color: Colors.white)
      : const TextStyle(color: Colors.white)).copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.4,
  );

  TextStyle _bodyStyle() => (_fontFamily != null
      ? GoogleFonts.getFont(_fontFamily!, color: Colors.white)
      : const TextStyle(color: Colors.white)).copyWith(
    fontSize: _editorFontSize,
    height: 1.6,
  );

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
      ..firstGapHeight = 2.8; // 제목-본문 간격을 편지 보기 화면과 동일하게 설정
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
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: '${AppStrings.photoError(locale)}$e');
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
    TabaModalSheet.show<void>(
      context: context,
      fixedSize: true,
      child: _TemplateSelector(
        templates: _templateOptions,
        selected: _selectedTemplate,
        onSelect: (template) {
          setState(() {
            _selectedTemplate = template;
          });
          // 템플릿 변경 시 폰트는 유지
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _openFontPicker() {
    final enFonts = <String>[
      'Indie Flower',
      'Kalam',
      'Patrick Hand',
      'Shadows Into Light',
      'Comic Neue',
      'Caveat',
      'Dancing Script',
      'Permanent Marker',
    ];
    final krFonts = <String>[
      'Jua',
      'Sunflower',
      'Yeon Sung',
      'Poor Story',
      'Dongle',
      'Gamja Flower',
      'Hi Melody',
      'Nanum Pen Script',
    ];
    final jpFonts = <String>[
      'Yomogi',
      'M PLUS Rounded 1c',
      'Kosugi Maru',
      'Comic Neue',
      'Shippori Mincho',
      'Noto Sans JP',
    ];

    TabaModalSheet.show<void>(
      context: context,
      fixedSize: true,
      child: _FontPickerSheet(
        enFonts: enFonts,
        krFonts: krFonts,
        jpFonts: jpFonts,
        onFontSelected: (font) {
          _applyFont(font);
        },
      ),
    );
  }

  void _openSendSheet() {
    TabaModalSheet.show<void>(
      context: context,
      fixedSize: false,
      initialChildSize: 0.5,
      maxChildSize: 0.75,
      builder: (context) {
        // Local state for the sheet
        // 답장인 경우 항상 친구에게 보내기로 고정
        bool localSendToFriend = widget.initialRecipient != null ? true : _sendToFriend;
        FriendProfile? localFriend = widget.initialRecipient != null 
            ? _selectedFriend 
            : _selectedFriend;
        bool localReserve = _reserveSend;
        DateTime? localDate = _scheduledDate;
        TimeOfDay? localTime = _scheduledTime;
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
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
                            Text(
                              AppStrings.sendSettings(locale),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                        // 답장인 경우 visibility 선택 옵션 숨기기
                        if (widget.initialRecipient == null) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              ChoiceChip(
                                label: Text(AppStrings.visibilityScope(locale, 'public')),
                                selected: !localSendToFriend,
                                onSelected: (_) => setLocal(() => localSendToFriend = false),
                              ),
                              const SizedBox(width: 12),
                              ChoiceChip(
                                label: Text(AppStrings.toFriend(locale)),
                                selected: localSendToFriend,
                                onSelected: (_) => setLocal(() => localSendToFriend = true),
                              ),
                            ],
                          ),
                        ] else ...[
                          // 답장인 경우 자동으로 친구에게 보내기로 설정
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.neonPink.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.neonPink.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.reply, color: AppColors.neonPink, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    AppStrings.replyAutoMessage(locale),
                                    style: TextStyle(color: AppColors.neonPink, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (localSendToFriend) ...[
                          const SizedBox(height: 16),
                          // 답장인 경우 친구 선택 UI 숨기기 (이미 선택됨)
                          if (widget.initialRecipient == null) ...[
                            Text(AppStrings.selectFriend(locale)),
                            if (_isLoadingFriends)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_friends.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  AppStrings.noFriends(locale),
                                  style: const TextStyle(color: Colors.white70),
                                ),
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
                                    leading: UserAvatar(
                                      user: friend.user,
                                      radius: 20,
                                    ),
                                    title: Text(friend.user.nickname),
                                    trailing: Icon(
                                      selected ? Icons.check_circle : Icons.circle_outlined,
                                      color: selected ? AppColors.neonPink : Colors.white54,
                                    ),
                                  );
                                },
                              ),
                          ] else if (localFriend != null) ...[
                            // 답장인 경우 선택된 친구 정보만 표시
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.midnightGlass,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Row(
                                children: [
                                  UserAvatar(
                                    user: localFriend!.user,
                                    radius: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localFriend!.user.nickname,
                                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                        ),
                                        Text(
                                          AppStrings.replyRecipient(locale),
                                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.check_circle, color: AppColors.neonPink),
                                ],
                              ),
                            ),
                          ],
                        ],
                        const SizedBox(height: 16),
                        SwitchListTile(
                          value: localReserve,
                          onChanged: (v) => setLocal(() => localReserve = v),
                          title: Text(AppStrings.scheduledSend(locale)),
                          subtitle: Text(AppStrings.scheduledSendSubtitle(locale)),
                        ),
                        if (localReserve) ...[
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_month),
                            title: Text(
                              localDate != null
                                  ? '${localDate!.year}.${localDate!.month}.${localDate!.day}'
                                  : AppStrings.selectDate(locale),
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
                            title: Text(
                              localTime != null ? localTime!.format(context) : AppStrings.selectTime(locale),
                            ),
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
                        TabaButton(
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
                          label: _isSending ? AppStrings.sending(locale) : AppStrings.plantSeed(locale),
                          icon: Icons.auto_awesome,
                          isLoading: _isSending,
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _selectedTemplate.background,
      extendBodyBehindAppBar: false,
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
        child: Column(
          children: [
            // 헤더: 닫기 + 액션 버튼들
            ValueListenableBuilder<Locale>(
              valueListenable: AppLocaleController.localeNotifier,
              builder: (context, locale, _) {
                return NavHeader(
                  showBackButton: true,
                  onBack: () => Navigator.of(context).pop(),
                  actions: [
                    NavIconButton(
                      icon: Icons.photo_library_outlined,
                      tooltip: AppStrings.attachPhoto(locale),
                      onPressed: _pickImages,
                      badge: _attachedImages.isEmpty ? null : _attachedImages.length,
                    ),
                    NavIconButton(
                      icon: Icons.layers_outlined,
                      tooltip: AppStrings.template(locale),
                      onPressed: _openTemplatePicker,
                    ),
                    NavIconButton(
                      icon: Icons.font_download_outlined,
                      tooltip: AppStrings.font(locale),
                      onPressed: _openFontPicker,
                    ),
                  ],
                );
              },
            ),
            if (_attachedImages.isNotEmpty) _buildAttachedImagesPreview(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.sm,
            AppSpacing.xl,
            AppSpacing.md,
          ),
          child: ValueListenableBuilder<Locale>(
            valueListenable: AppLocaleController.localeNotifier,
            builder: (context, locale, _) {
              return TabaButton(
                onPressed: _openSendSheet,
                label: AppStrings.send(locale),
                icon: Icons.send_rounded,
              );
            },
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
        cursorColor: Colors.white,
        cursorWidth: 2.0,
        cursorHeight: _editorFontSize * 1.2,
        decoration: InputDecoration(
          hintText: _getPlaceholderForFont(),
          hintStyle: (_fontFamily != null
                  ? GoogleFonts.getFont(_fontFamily!, color: Colors.white)
                  : const TextStyle(color: Colors.white))
              .copyWith(color: Colors.white.withOpacity(.5), height: 1.6),
        ),
        style: _bodyStyle(),
      ),
    );
  }


  Future<void> _sendLetter() async {
    final locale = AppLocaleController.localeNotifier.value;
    final text = _notesController.text.trim();
    if (text.isEmpty) {
      if (mounted) {
        showTabaError(context, message: AppStrings.contentRequired(locale));
      }
      return;
    }

    // 제목과 본문 분리
    final nl = text.indexOf('\n');
    final title = nl >= 0 ? text.substring(0, nl).trim() : text.trim();
    final content = nl >= 0 ? text.substring(nl + 1).trim() : '';
    
    if (title.isEmpty) {
      if (mounted) {
        showTabaError(context, message: AppStrings.titleRequired(locale));
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

      // Color를 16진수 문자열로 변환 (#RRGGBB)
      String colorToHex(Color color) {
        return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      }
      
      final template = {
        'background': colorToHex(_selectedTemplate.background),
        'textColor': colorToHex(Colors.white),
        'fontFamily': _fontFamily ?? 'Jua',
        'fontSize': _editorFontSize,
      };
      
      final preview = content.isNotEmpty 
          ? content.substring(0, content.length > 50 ? 50 : content.length) 
          : title;
      
      bool success;
      
      // 답장인 경우 답장 API 사용, 일반 편지인 경우 일반 편지 작성 API 사용
      if (widget.replyToLetterId != null) {
        // 답장 API 사용 (자동 친구 추가)
        success = await _repository.replyLetter(
          letterId: widget.replyToLetterId!,
          title: title,
          content: content.isNotEmpty ? content : title,
          preview: preview,
          flowerType: 'ROSE',
          isAnonymous: false,
          template: template,
          attachedImages: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
        );
      } else {
        // 일반 편지 작성 API 사용
        success = await _repository.createLetter(
          title: title,
          content: content.isNotEmpty ? content : title,
          preview: preview,
          flowerType: 'ROSE', // API 명세서에 따라 대문자
          visibility: _sendToFriend ? 'DIRECT' : 'PUBLIC', // API 명세서에 따라 대문자
          isAnonymous: false,
          template: template,
          attachedImages: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
          scheduledAt: scheduledAt,
          recipientId: _sendToFriend ? _selectedFriend?.user.id : null,
        );
      }

      if (!mounted) return;

      if (success) {
        final locale = AppLocaleController.localeNotifier.value;
        // 성공 메시지 표시
        final target = _sendToFriend
            ? (_selectedFriend?.user.nickname ?? AppStrings.friend(locale))
            : AppStrings.visibilityScope(locale, 'public');
        final scheduleSummary = _reserveSend && _scheduledDate != null && _scheduledTime != null
            ? AppStrings.seedBloomsMessage(
                locale,
                target,
                '${_scheduledDate!.year}.${_scheduledDate!.month}.${_scheduledDate!.day}',
                _scheduledTime!.format(context),
              )
            : AppStrings.seedFliesMessage(locale, target);
        
        // 콜백 호출하여 메인 화면 새로고침
        widget.onSuccess?.call();
        
        // 화면 닫기
        if (mounted) Navigator.of(context).pop(); // close sheet
        if (mounted) Navigator.of(context).pop(); // close editor
        
        // 성공 알림 표시 (화면 닫은 후)
        if (mounted) {
          showTabaSuccess(
            context,
            title: AppStrings.seedPlanted(locale),
            message: scheduleSummary,
          );
        }
      } else {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.letterSendFailed(locale));
      }
    } catch (e) {
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
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
      mainAxisSize: MainAxisSize.min,
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
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Text(
              AppStrings.premiumTemplatesComing(locale),
              style: const TextStyle(color: Colors.white70),
            );
          },
        ),
      ],
    );
  }
}

class _FontPickerSheet extends StatefulWidget {
  const _FontPickerSheet({
    required this.enFonts,
    required this.krFonts,
    required this.jpFonts,
    required this.onFontSelected,
  });

  final List<String> enFonts;
  final List<String> krFonts;
  final List<String> jpFonts;
  final ValueChanged<String> onFontSelected;

  @override
  State<_FontPickerSheet> createState() => _FontPickerSheetState();
}

class _FontPickerSheetState extends State<_FontPickerSheet> {
  late String _selectedLang;
  late List<String> _currentFonts;

  @override
  void initState() {
    super.initState();
    // 시스템 언어에 맞춰 초기 언어 선택
    final locale = AppLocaleController.localeNotifier.value;
    _selectedLang = locale.languageCode == 'ko' ? 'ko' 
                   : locale.languageCode == 'ja' ? 'ja' 
                   : 'en';
    _currentFonts = _selectedLang == 'ko' ? widget.krFonts 
                   : _selectedLang == 'ja' ? widget.jpFonts 
                   : widget.enFonts;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 언어 선택 태그 버튼
            Row(
              children: [
                ChoiceChip(
                  label: const Text('EN'),
                  selected: _selectedLang == 'en',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLang = 'en';
                        _currentFonts = widget.enFonts;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('한국어'),
                  selected: _selectedLang == 'ko',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLang = 'ko';
                        _currentFonts = widget.krFonts;
                      });
                    }
                  },
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('日本語'),
                  selected: _selectedLang == 'ja',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLang = 'ja';
                        _currentFonts = widget.jpFonts;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 선택된 언어의 폰트 목록
            ..._currentFonts.map((font) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  title: Text(
                    font,
                    style: GoogleFonts.getFont(font, color: Colors.white),
                  ),
                  onTap: () {
                    widget.onFontSelected(font);
                    Navigator.of(context).pop();
                  },
                ),
                if (font != _currentFonts.last)
                  const Divider(color: Colors.white24, height: 1),
              ],
            )),
          ],
        ),
      ),
    );
  }
}


