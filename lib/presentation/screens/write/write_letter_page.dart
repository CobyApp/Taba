import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/friend.dart';
import 'package:taba_app/data/models/user.dart';
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


class _WriteLetterPageState extends State<WriteLetterPage> {
  final _repository = DataRepository.instance;
  bool _sendToFriend = false;
  final ValueNotifier<String?> _fontFamilyNotifier = ValueNotifier<String?>(null);
  String? _previousLocaleCode; // 이전 locale 추적
  static const double _editorFontSize = 24; // 편지 읽기 화면과 동일하게
  List<FriendProfile> _friends = [];
  FriendProfile? _selectedFriend;
  bool _isLoadingFriends = false;
  TabaUser? _replyToSender; // 답장할 편지의 발신자 정보
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
    _TemplateOption(
      id: 'ocean_deep',
      name: '오션 딥',
      background: Color(0xFF001A2E),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'lavender_night',
      name: '라벤더 나이트',
      background: Color(0xFF1A0F2E),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'cherry_blossom',
      name: '벚꽃',
      background: Color(0xFF2D0F1A),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'midnight_forest',
      name: '미드나잇 포레스트',
      background: Color(0xFF0A1A0F),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'royal_purple',
      name: '로얄 퍼플',
      background: Color(0xFF1A0A2E),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'deep_rose',
      name: '딥 로즈',
      background: Color(0xFF2E0A14),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'starry_night',
      name: '별이 빛나는 밤',
      background: Color(0xFF0A0A1A),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'emerald_dark',
      name: '에메랄드 다크',
      background: Color(0xFF0A1A0A),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'sapphire_blue',
      name: '사파이어 블루',
      background: Color(0xFF0A0F2E),
      textColor: Colors.white,
    ),
    _TemplateOption(
      id: 'crimson_night',
      name: '크림슨 나이트',
      background: Color(0xFF1A0A0A),
      textColor: Colors.white,
    ),
  ];
  late _TemplateOption _selectedTemplate = _templateOptions.first;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _bodyFocusNode = FocusNode();
  final List<String> _attachedImages = []; // 첨부된 사진 경로 리스트
  final List<File> _attachedImageFiles = []; // 첨부된 사진 파일 리스트
  final ImagePicker _imagePicker = ImagePicker();
  bool _isSending = false;
  final ValueNotifier<bool> _isSendingNotifier = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    // 시스템 언어에 맞게 기본 폰트 설정
    final locale = AppLocaleController.localeNotifier.value;
    _previousLocaleCode = locale.languageCode;
    _fontFamilyNotifier.value = _getDefaultFontForLocale(locale.languageCode);
    _loadFriends();
    
    // 언어 변경 시 기본 폰트 업데이트
    AppLocaleController.localeNotifier.addListener(_onLocaleChanged);
    
    // 제목과 내용 변경 시 버튼 활성화 상태 업데이트
    _titleController.addListener(() {
      setState(() {}); // 버튼 활성화 상태 업데이트
    });
    _bodyController.addListener(() {
      setState(() {}); // 버튼 활성화 상태 업데이트
    });
    
    // 제목에서 엔터를 치면 본문으로 포커스 이동
    _titleFocusNode.addListener(() {
      if (!_titleFocusNode.hasFocus) {
        // 제목에서 포커스가 나갔을 때 처리
      }
    });
    
    // initialRecipient가 있으면 친구에게 보내기로 설정
    if (widget.initialRecipient != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendToFriend = true;
      });
    }
    
    // replyToLetterId가 있으면 편지 정보를 로드해서 발신자 정보 저장
    if (widget.replyToLetterId != null) {
      _loadReplyLetterInfo();
    }
  }

  void _onLocaleChanged() {
    if (!mounted) return;
    final locale = AppLocaleController.localeNotifier.value;
    final newLocaleCode = locale.languageCode;
    
    // locale이 실제로 변경되었는지 확인
    if (_previousLocaleCode == newLocaleCode) return;
    
    // 이전 locale의 기본 폰트
    final previousDefaultFont = _previousLocaleCode != null 
        ? _getDefaultFontForLocale(_previousLocaleCode!)
        : null;
    
    // 현재 폰트가 이전 locale의 기본 폰트와 같으면 (사용자가 수동으로 변경하지 않았으면)
    // 새 locale의 기본 폰트로 업데이트
    if (previousDefaultFont != null && _fontFamilyNotifier.value == previousDefaultFont) {
      final newDefaultFont = _getDefaultFontForLocale(newLocaleCode);
      _fontFamilyNotifier.value = newDefaultFont;
      _previousLocaleCode = newLocaleCode;
    } else {
      // 사용자가 수동으로 폰트를 변경한 경우 locale만 업데이트
      _previousLocaleCode = newLocaleCode;
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

  Future<void> _loadReplyLetterInfo() async {
    if (widget.replyToLetterId == null) return;
    
    try {
      final letter = await _repository.getLetter(widget.replyToLetterId!);
      if (mounted && letter != null) {
        setState(() {
          _replyToSender = letter.sender;
          // 답장인 경우 항상 친구에게 보내기로 설정
          _sendToFriend = true;
        });
      }
    } catch (e) {
      print('답장 편지 정보 로드 실패: $e');
      // 에러가 발생해도 계속 진행
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
    _fontFamilyNotifier.value = family;
  }

  /// 폰트에서 언어 정보 추출 (ko, en, ja)
  String _getLanguageFromFont(String? fontFamily) {
    if (fontFamily == null) {
      // 기본값은 시스템 언어
      final locale = AppLocaleController.localeNotifier.value;
      return locale.languageCode == 'ko' ? 'ko' 
           : locale.languageCode == 'ja' ? 'ja' 
           : 'en';
    }
    
    // 한국어 폰트
    final krFonts = [
      'Jua', 'Sunflower', 'Yeon Sung', 'Poor Story', 
      'Dongle', 'Gamja Flower', 'Hi Melody', 'Nanum Gothic',
      'Nanum Myeongjo', 'Noto Sans KR', 'Noto Serif KR',
      'Gowun Batang', 'Gowun Dodum', 'Do Hyeon', 'Black Han Sans',
      'Song Myung', 'Stylish', 'Single Day', 'Gowun Batang', 'Noto Sans KR'
    ];
    if (krFonts.contains(fontFamily)) {
      return 'ko';
    }
    
    // 일본어 폰트
    final jpFonts = [
      'Yomogi', 'M PLUS Rounded 1c', 'Kosugi Maru', 
      'Shippori Mincho', 'Noto Sans JP', 'Noto Serif JP',
      'M PLUS 1p', 'Sawarabi Mincho', 'Sawarabi Gothic',
      'Zen Kurenaido', 'Zen Maru Gothic', 'Kiwi Maru',
      'Mochiy Pop One', 'Mochiy Pop P One', 'Hachi Maru Pop',
      'Yusei Magic', 'Zen Antique', 'Zen Antique Soft',
      'Zen Kaku Gothic New', 'Zen Old Mincho'
    ];
    if (jpFonts.contains(fontFamily)) {
      return 'ja';
    }
    
    // 기본값은 영어 폰트
    return 'en';
  }

  TextStyle _titleStyle(String? fontFamily) => (fontFamily != null
      ? GoogleFonts.getFont(fontFamily, color: Colors.white)
      : const TextStyle(color: Colors.white)).copyWith(
    fontSize: _editorFontSize * 1.15, // 제목은 본문보다 15% 크게 (편지 읽기 화면과 동일)
    fontWeight: FontWeight.w700,
    height: 1.8, // 줄간격 더 넓게 (편지 읽기 화면과 동일)
  );

  TextStyle _bodyStyle(String? fontFamily) => (fontFamily != null
      ? GoogleFonts.getFont(fontFamily, color: Colors.white)
      : const TextStyle(color: Colors.white)).copyWith(
    fontSize: _editorFontSize,
    height: 1.5, // 본문 줄간격 (편지 읽기 화면과 동일)
  );

  String _getTitlePlaceholder(Locale locale) {
    return AppStrings.titleHint(locale);
  }

  String _getBodyPlaceholder(Locale locale) {
    return AppStrings.contentHint(locale);
  }



  Future<File?> _compressImage(File imageFile) async {
    try {
      // 파일 존재 확인
      if (!imageFile.existsSync()) {
        print('이미지 파일이 존재하지 않습니다: ${imageFile.path}');
        return null;
      }

      // 파일 크기 확인 (이미 작은 파일은 압축하지 않음)
      final fileSize = await imageFile.length();
      if (fileSize < 500 * 1024) { // 500KB 미만이면 압축하지 않고 원본 사용
        print('이미지 파일이 작아서 압축하지 않습니다: ${fileSize / 1024}KB');
        return imageFile;
      }

      // 임시 디렉토리 가져오기
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_${path.basenameWithoutExtension(imageFile.path)}.jpg',
      );

      // 이미지 압축
      // 최대 너비/높이: 1920px, 품질: 80% (더 안정적인 압축)
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        minWidth: 1920,
        minHeight: 1920,
        quality: 80,
        format: CompressFormat.jpeg,
        keepExif: false, // EXIF 데이터 제거로 파일 크기 감소
      );

      if (compressedFile != null) {
        final resultFile = File(compressedFile.path);
        // 압축된 파일이 존재하고 크기가 0이 아닌지 확인
        if (resultFile.existsSync()) {
          final compressedSize = await resultFile.length();
          if (compressedSize > 0) {
            print('이미지 압축 성공: ${fileSize / 1024}KB -> ${compressedSize / 1024}KB');
            return resultFile;
          } else {
            print('압축된 파일이 비어있습니다: ${compressedFile.path}');
            // 빈 파일 삭제
            try {
              await resultFile.delete();
            } catch (_) {}
            return null;
          }
        } else {
          print('압축된 파일이 생성되지 않았습니다: ${compressedFile.path}');
          return null;
        }
      }
      
      return null;
    } catch (e, stackTrace) {
      print('이미지 압축 실패: $e');
      print('스택 트레이스: $stackTrace');
      // 압축 실패 시 null 반환 (호출자가 원본 사용)
      return null;
    }
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage();
      if (pickedFiles.isNotEmpty) {
        if (mounted) {
          final locale = AppLocaleController.localeNotifier.value;
          // 이미지 압축 중 표시 (선택사항)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.compressingImage(locale)),
              duration: const Duration(seconds: 1),
            ),
          );
        }

        final List<String> compressedPaths = [];
        final List<File> compressedFiles = [];

        // 각 이미지를 압축
        for (final file in pickedFiles) {
          final originalFile = File(file.path);
          
          // 원본 파일 존재 확인
          if (!originalFile.existsSync()) {
            print('원본 이미지 파일이 존재하지 않습니다: ${originalFile.path}');
            continue;
          }
          
          // 파일 크기 확인
          try {
            final fileSize = await originalFile.length();
            if (fileSize == 0) {
              print('이미지 파일이 비어있습니다: ${originalFile.path}');
              continue;
            }
          } catch (e) {
            print('파일 크기 확인 실패: $e');
            continue;
          }
          
          final compressedFile = await _compressImage(originalFile);
          
          // 압축 성공 시 압축된 파일 사용, 실패 시 원본 사용
          if (compressedFile != null && compressedFile.existsSync()) {
            try {
              final compressedSize = await compressedFile.length();
              if (compressedSize > 0) {
                compressedPaths.add(compressedFile.path);
                compressedFiles.add(compressedFile);
                print('압축된 이미지 추가: ${compressedFile.path}');
              } else {
                // 압축된 파일이 비어있으면 원본 사용
                print('압축된 파일이 비어있어 원본 사용: ${originalFile.path}');
                compressedPaths.add(file.path);
                compressedFiles.add(originalFile);
              }
            } catch (e) {
              print('압축 파일 확인 실패, 원본 사용: $e');
              compressedPaths.add(file.path);
              compressedFiles.add(originalFile);
            }
          } else {
            // 압축 실패 시 원본 사용 (원본이 존재하는 경우만)
            print('압축 실패, 원본 사용: ${originalFile.path}');
            compressedPaths.add(file.path);
            compressedFiles.add(originalFile);
          }
        }

        if (mounted) {
          setState(() {
            _attachedImages.addAll(compressedPaths);
            _attachedImageFiles.addAll(compressedFiles);
          });
        }
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
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _attachedImages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final imagePath = _attachedImages[index];
          final imageFile = File(imagePath);
          final fileExists = imageFile.existsSync();
          
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: fileExists
                    ? Image.file(
                        imageFile,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        cacheWidth: 120, // 메모리 최적화: 작은 크기로 캐시
                        cacheHeight: 120,
                        errorBuilder: (context, error, stackTrace) {
                          // 이미지 로딩 실패 시 대체 위젯
                          print('이미지 로딩 실패: $imagePath, 에러: $error');
                          return Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                              size: 24,
                            ),
                          );
                        },
                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                          if (wasSynchronouslyLoaded) {
                            return child;
                          }
                          return AnimatedOpacity(
                            opacity: frame == null ? 0 : 1,
                            duration: const Duration(milliseconds: 200),
                            child: frame == null
                                ? Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey[900],
                                    child: const Center(
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : child,
                          );
                        },
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                          size: 24,
                        ),
                      ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, size: 12, color: Colors.white),
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
    // 영어 폰트 20개 (10대 20대 여성 선호 귀여운 폰트, 크기 균일)
    final enFonts = <String>[
      'Indie Flower',
      'Kalam',
      'Patrick Hand',
      'Comic Neue',
      'Permanent Marker',
      'Pacifico',
      'Lobster',
      'Chewy',
      'Nunito',
      'Quicksand',
      'Comfortaa',
      'Poppins',
      'Raleway',
      'Open Sans',
      'Roboto',
      'Montserrat',
      'Lato',
      'Source Sans 3',
      'Inter',
      'Work Sans',
    ];
    // 한국어 폰트 20개 (10대 20대 여성 선호 귀여운 폰트, 크기 균일)
    final krFonts = <String>[
      'Jua',
      'Sunflower',
      'Yeon Sung',
      'Poor Story',
      'Dongle',
      'Gamja Flower',
      'Hi Melody',
      'Nanum Gothic',
      'Nanum Myeongjo',
      'Noto Sans KR',
      'Noto Serif KR',
      'Gowun Batang',
      'Gowun Dodum',
      'Do Hyeon',
      'Black Han Sans',
      'Song Myung',
      'Stylish',
      'Single Day',
      'Gowun Batang',
      'Noto Sans KR',
    ];
    // 일본어 폰트 20개 (10대 20대 여성 선호 귀여운 폰트)
    final jpFonts = <String>[
      'Yomogi',
      'M PLUS Rounded 1c',
      'Kosugi Maru',
      'Shippori Mincho',
      'Noto Sans JP',
      'Noto Serif JP',
      'M PLUS 1p',
      'Sawarabi Mincho',
      'Sawarabi Gothic',
      'Zen Kurenaido',
      'Zen Maru Gothic',
      'Kiwi Maru',
      'Mochiy Pop One',
      'Mochiy Pop P One',
      'Hachi Maru Pop',
      'Yusei Magic',
      'Zen Antique',
      'Zen Antique Soft',
      'Zen Kaku Gothic New',
      'Zen Old Mincho',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.midnightSoft,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final sheetHeight = screenHeight * 0.7; // 화면의 70% 고정 높이
        
        return SizedBox(
          height: sheetHeight,
          child: _FontPickerSheet(
            enFonts: enFonts,
            krFonts: krFonts,
            jpFonts: jpFonts,
            onFontSelected: (font) {
              _applyFont(font);
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  void _openSendSheet() {
    // Local state for the sheet
    // 답장인 경우 항상 친구에게 보내기로 고정
    bool initialSendToFriend = (widget.initialRecipient != null || widget.replyToLetterId != null) ? true : _sendToFriend;
    
    TabaModalSheet.show<void>(
      context: context,
      fixedSize: true, // 내용에 맞게 높이 자동 조정
      builder: (context) {
        // StatefulBuilder를 위한 상태 변수 (클로저 밖에서 선언하여 상태 유지)
        bool localSendToFriend = (widget.initialRecipient != null || widget.replyToLetterId != null) ? true : _sendToFriend;
        FriendProfile? localFriend = widget.initialRecipient != null 
            ? _selectedFriend 
            : _selectedFriend;
        
        return ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return StatefulBuilder(
              builder: (context, setLocal) {
                // StatefulBuilder는 클로저 밖의 변수를 상태로 유지하지 않으므로,
                // setLocal 내에서 변수를 업데이트하고 위젯을 재빌드합니다.
                // 부모 위젯의 _isSending 상태를 감지하기 위해 ValueListenableBuilder 사용
                return ValueListenableBuilder<bool>(
                  valueListenable: _isSendingNotifier,
                  builder: (context, isSending, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                        Row(
                          children: [
                            Text(
                              AppStrings.sendSettings(locale),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                        // 답장인 경우 visibility 선택 옵션 숨기기
                        if (widget.initialRecipient == null && widget.replyToLetterId == null) ...[
                          const SizedBox(height: AppSpacing.xl),
                          Row(
                            children: [
                              ChoiceChip(
                                label: Text(AppStrings.visibilityScope(locale, 'public')),
                                selected: !localSendToFriend,
                                onSelected: (selected) {
                                  if (selected) {
                                    localSendToFriend = false;
                                    localFriend = null; // 공개 선택 시 친구 선택 초기화
                                    setLocal(() {}); // 위젯 재빌드
                                  }
                                },
                              ),
                              const SizedBox(width: AppSpacing.md),
                              ChoiceChip(
                                label: Text(AppStrings.toFriend(locale)),
                                selected: localSendToFriend,
                                onSelected: (selected) {
                                  if (selected) {
                                    localSendToFriend = true;
                                    setLocal(() {}); // 위젯 재빌드
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                        if (localSendToFriend) ...[
                          const SizedBox(height: AppSpacing.xl),
                          // 답장인 경우 친구 선택 UI 숨기기 (이미 선택됨)
                          if (widget.initialRecipient == null) ...[
                            Padding(
                              padding: const EdgeInsets.only(bottom: AppSpacing.md),
                              child: Text(
                                AppStrings.selectFriend(locale),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            if (_isLoadingFriends)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                child: Center(child: CircularProgressIndicator()),
                              )
                            else if (_friends.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                                child: Text(
                                  AppStrings.noFriends(locale),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              )
                            else
                              SizedBox(
                                height: 90,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                itemCount: _friends.length,
                                itemBuilder: (context, index) {
                                  final friend = _friends[index];
                                  final selected = localFriend?.user.id == friend.user.id;
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right: index < _friends.length - 1 ? AppSpacing.md : 0,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          localFriend = friend;
                                          setLocal(() {}); // 위젯 재빌드
                                        },
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          width: 70,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: selected 
                                                ? AppColors.neonPink.withOpacity(0.2)
                                                : AppColors.midnightGlass,
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: selected 
                                                  ? AppColors.neonPink
                                                  : Colors.white24,
                                              width: selected ? 2 : 1,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              UserAvatar(
                                      user: friend.user,
                                                radius: 22,
                                    ),
                                              const SizedBox(height: 4),
                                              Flexible(
                                                child: Text(
                                                  friend.user.nickname,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: selected 
                                                        ? FontWeight.w600 
                                                        : FontWeight.normal,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ),
                                  );
                                },
                                ),
                              ),
                          ],
                          // 답장인 경우 선택된 친구 정보 표시 (공개편지 답장과 친구 편지 답장 모두)
                          if ((widget.initialRecipient != null || widget.replyToLetterId != null)) ...[
                            // initialRecipient가 있으면 친구 목록에서 찾은 친구 정보 표시
                            if (widget.initialRecipient != null && localFriend != null) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
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
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            localFriend!.user.nickname,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            AppStrings.replyRecipient(locale),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(Icons.check_circle, color: AppColors.neonPink),
                                  ],
                                ),
                              ),
                            ]
                            // replyToLetterId만 있고 initialRecipient가 없으면 편지 발신자 정보 표시
                            else if (widget.replyToLetterId != null && _replyToSender != null) ...[
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: AppColors.midnightGlass,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    UserAvatar(
                                      user: _replyToSender!,
                                      radius: 20,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _replyToSender!.nickname,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Text(
                                            AppStrings.replyRecipient(locale),
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
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
                        ],
                        const SizedBox(height: AppSpacing.xl * 1.5),
                        TabaButton(
                          onPressed: isSending ? null : () async {
                            // Commit local state to parent, then send
                            setState(() {
                              _sendToFriend = localSendToFriend;
                              _selectedFriend = localFriend;
                            });
                            
                            // 로딩 시작
                            _isSending = true;
                            _isSendingNotifier.value = true;
                            
                            // _sendLetter의 finally 블록에서 로딩 상태 해제
                            await _sendLetter();
                          },
                          label: isSending ? AppStrings.sending(locale) : AppStrings.plantSeed(locale),
                          icon: Icons.auto_awesome,
                          isLoading: isSending,
                        ),
                  ],
                );
                  },
                );
              },
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: _buildEditor(context),
                ),
              ),
            // 하단에 첨부 사진 미리보기 표시
            if (_attachedImages.isNotEmpty) _buildAttachedImagesPreview(),
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
              // 제목과 내용이 모두 작성되어야 버튼 활성화
              final canSend = _titleController.text.trim().isNotEmpty && 
                             _bodyController.text.trim().isNotEmpty;
              return TabaButton(
                onPressed: canSend ? _openSendSheet : null,
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

    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: _fontFamilyNotifier,
          builder: (context, fontFamily, _) {
            final titleStyle = _titleStyle(fontFamily);
            final bodyStyle = _bodyStyle(fontFamily);
            
            // 폰트에 따라 언어 결정 (폰트가 없으면 현재 locale 사용)
            final languageCode = fontFamily != null 
                ? _getLanguageFromFont(fontFamily)
                : locale.languageCode;
            final fontLocale = Locale(languageCode);

            return Theme(
              data: Theme.of(context).copyWith(inputDecorationTheme: localInputTheme),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 TextField
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    maxLines: null,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    cursorColor: Colors.white,
                    cursorWidth: 2.0,
                    cursorHeight: titleStyle.fontSize! * titleStyle.height!,
                    decoration: InputDecoration(
                      hintText: _getTitlePlaceholder(fontLocale),
                      hintStyle: (fontFamily != null
                              ? GoogleFonts.getFont(fontFamily, color: Colors.white)
                              : const TextStyle(color: Colors.white))
                          .copyWith(
                            color: Colors.white.withOpacity(.5),
                            fontSize: titleStyle.fontSize,
                            fontWeight: titleStyle.fontWeight,
                            height: titleStyle.height,
                          ),
                    ),
                    style: titleStyle,
                    onSubmitted: (_) {
                      // 제목에서 엔터를 치면 본문으로 포커스 이동
                      _bodyFocusNode.requestFocus();
                    },
                  ),
                  // 제목-본문 간격 (편지 읽기 화면과 동일)
                  const SizedBox(height: 24),
                  // 본문 TextField
                  Expanded(
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _bodyController,
                        focusNode: _bodyFocusNode,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        cursorColor: Colors.white,
                        cursorWidth: 2.0,
                        cursorHeight: bodyStyle.fontSize! * bodyStyle.height!,
                        decoration: InputDecoration(
                          hintText: _getBodyPlaceholder(fontLocale),
                          hintStyle: (fontFamily != null
                                  ? GoogleFonts.getFont(fontFamily, color: Colors.white)
                                  : const TextStyle(color: Colors.white))
                              .copyWith(
                                color: Colors.white.withOpacity(.5),
                                fontSize: bodyStyle.fontSize,
                                height: bodyStyle.height,
                              ),
                        ),
                        style: bodyStyle,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }


  Future<void> _sendLetter() async {
    final locale = AppLocaleController.localeNotifier.value;
    final title = _titleController.text.trim();
    final content = _bodyController.text.trim();
    
    if (title.isEmpty) {
      if (mounted) {
        setState(() => _isSending = false); // 로딩 상태 해제
        showTabaError(context, message: AppStrings.titleRequired(locale));
      }
      return;
    }

    if (content.isEmpty) {
      if (mounted) {
        setState(() => _isSending = false); // 로딩 상태 해제
        showTabaError(context, message: AppStrings.contentRequired(locale));
      }
      return;
    }

    // _isSending은 버튼 클릭 핸들러에서 이미 설정됨

    try {
      // 이미지 업로드
      List<String> uploadedImageUrls = [];
      if (_attachedImageFiles.isNotEmpty) {
        try {
        uploadedImageUrls = await _repository.uploadImages(_attachedImageFiles);
          // 업로드된 URL 개수가 첨부된 파일 개수와 일치하는지 확인
          if (uploadedImageUrls.length != _attachedImageFiles.length) {
            if (mounted) {
              final locale = AppLocaleController.localeNotifier.value;
              showTabaError(
                context,
                message: AppStrings.someImagesUploadFailed(locale, uploadedImageUrls.length, _attachedImageFiles.length),
        );
            }
            return;
          }
        } catch (e) {
          if (mounted) {
            final locale = AppLocaleController.localeNotifier.value;
            showTabaError(
              context,
              message: '${AppStrings.imageUploadFailed(locale)}: ${e.toString()}',
            );
          }
          return;
        }
      }

      // Color를 16진수 문자열로 변환 (#RRGGBB)
      String colorToHex(Color color) {
        return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
      }
      
      final template = {
        'background': colorToHex(_selectedTemplate.background),
        'textColor': colorToHex(Colors.white),
        'fontFamily': _fontFamilyNotifier.value ?? 'Jua',
        'fontSize': _editorFontSize,
      };
      
      final preview = content.length > 50 
          ? content.substring(0, 50) 
          : content;
      
      // 폰트에서 언어 정보 추출
      final language = _getLanguageFromFont(_fontFamilyNotifier.value);
      
      bool success;
      
      // 답장인 경우 답장 API 사용, 일반 편지인 경우 일반 편지 작성 API 사용
      if (widget.replyToLetterId != null) {
        // 답장 API 사용 (자동 친구 추가)
        success = await _repository.replyLetter(
          letterId: widget.replyToLetterId!,
          title: title,
          content: content,
          preview: preview,
          template: template,
          attachedImages: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
          language: language,
        );
      } else {
        // 일반 편지 작성 API 사용
        success = await _repository.createLetter(
          title: title,
          content: content,
          preview: preview,
          visibility: _sendToFriend ? 'DIRECT' : 'PUBLIC', // API 명세서에 따라 대문자
          template: template,
          attachedImages: uploadedImageUrls.isNotEmpty ? uploadedImageUrls : null,
          recipientId: _sendToFriend ? _selectedFriend?.user.id : null,
          language: language,
        );
      }

      if (!mounted) return;

      if (success) {
        final locale = AppLocaleController.localeNotifier.value;
        // 성공 메시지 표시
        final target = _sendToFriend
            ? (_selectedFriend?.user.nickname ?? AppStrings.friend(locale))
            : AppStrings.visibilityScope(locale, 'public');
        final scheduleSummary = AppStrings.seedFliesMessage(locale, target);
        
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
        _isSending = false;
        _isSendingNotifier.value = false;
      }
    }
  }

  @override
  void dispose() {
    AppLocaleController.localeNotifier.removeListener(_onLocaleChanged);
    _titleController.dispose();
    _bodyController.dispose();
    _titleFocusNode.dispose();
    _bodyFocusNode.dispose();
    _isSendingNotifier.dispose();
    _fontFamilyNotifier.dispose();
    super.dispose();
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
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
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
                          Text(AppStrings.templateName(locale, template.id)),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) => const SizedBox(width: 16),
                itemCount: templates.length,
              ),
            ),
          ],
        );
      },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 언어 선택 태그 버튼 (고정)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
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
            ),
            // 선택된 언어의 폰트 목록 (스크롤 가능)
            Expanded(
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: _currentFonts.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white24,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final font = _currentFonts[index];
                  // 폰트 로딩 시도, 실패하면 기본 스타일 사용
                  TextStyle fontStyle;
                  try {
                    fontStyle = GoogleFonts.getFont(font, color: Colors.white);
                  } catch (e) {
                    // 폰트를 찾을 수 없으면 기본 스타일 사용
                    fontStyle = const TextStyle(color: Colors.white);
                  }
                  
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    title: Text(
                      font,
                      style: fontStyle,
                    ),
                    onTap: () {
                      widget.onFontSelected(font);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


