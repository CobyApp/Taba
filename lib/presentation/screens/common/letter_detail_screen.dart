import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/data/services/translation_service.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/screens/write/write_letter_page.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class LetterDetailScreen extends StatefulWidget {
  const LetterDetailScreen({
    super.key,
    required this.letter,
    this.friendName,
  });

  final Letter letter;
  final String? friendName;

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  final _repository = DataRepository.instance;
  final _translationService = TranslationService.instance;
  TabaUser? _currentUser;
  bool _isLoadingUser = true;
  bool _isTranslating = false;
  bool _showTranslated = false;
  String? _translatedTitle;
  String? _translatedContent;
  bool _letterWasRead = false;
  bool _letterDeleted = false; // 편지가 삭제되었는지 여부

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    // API 명세서: GET /letters/{letterId} 호출 시 서버에서 자동으로 읽음 처리됨
    // 작성자가 아닌 경우에만 읽음 처리가 수행됨
    // 편지 상세 정보를 서버에서 다시 조회하여 읽음 처리 및 최신 정보 가져오기
    _loadLetterFromServer();
  }

  /// 서버에서 편지 상세 정보를 조회하여 읽음 처리 및 최신 정보 가져오기
  /// API 명세서: GET /letters/{letterId} 호출 시 자동으로 읽음 처리됨
  Future<void> _loadLetterFromServer() async {
    try {
      // 예약전송 편지 접근 제한 확인
      // API 명세서: 예약전송 편지는 받는 사람이 예약 시간 전까지 열람할 수 없음
      // 보낸 사람은 언제든지 열람 가능
      if (!_isMyLetter && widget.letter.scheduledAt != null) {
        final now = DateTime.now();
        if (now.isBefore(widget.letter.scheduledAt!)) {
          // 예약 시간 전이면 접근 불가
          final locale = AppLocaleController.localeNotifier.value;
          if (mounted) {
            setState(() {
              _letterDeleted = true;
            });
            showTabaError(
              context,
              message: AppStrings.scheduledLetterNotAvailable(locale, widget.letter.scheduledAt!),
            );
            // 잠시 후 이전 화면으로 돌아가기
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            });
          }
          return;
        }
      }

      // 서버에서 편지 상세 정보를 조회 (읽음 처리 자동 수행)
      // 에러 정보도 함께 확인하여 삭제된 편지인지 판단
      final result = await _repository.getLetterWithError(widget.letter.id);
      
      if (mounted) {
        if (result.isNotFound || result.letter == null) {
          // 편지를 찾을 수 없는 경우 (삭제된 편지)
          setState(() {
            _letterDeleted = true;
            _letterWasRead = true;
          });
          
          // 삭제된 편지 메시지 표시 후 이전 화면으로 돌아가기
          final locale = AppLocaleController.localeNotifier.value;
          if (mounted) {
            showTabaError(
              context,
              message: AppStrings.letterNotFound(locale),
            );
            // 잠시 후 이전 화면으로 돌아가기
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            });
          }
          return;
        }
        
        // 서버에서 받은 최신 편지 정보 확인
        final updatedLetter = result.letter!;
        
        // 예약전송 편지 접근 제한 재확인 (서버에서 받은 최신 정보 기준)
        if (!_isMyLetter && updatedLetter.scheduledAt != null) {
          final now = DateTime.now();
          if (now.isBefore(updatedLetter.scheduledAt!)) {
            // 예약 시간 전이면 접근 불가
            final locale = AppLocaleController.localeNotifier.value;
            if (mounted) {
              setState(() {
                _letterDeleted = true;
              });
              showTabaError(
                context,
                message: AppStrings.scheduledLetterNotAvailable(locale, updatedLetter.scheduledAt!),
              );
              // 잠시 후 이전 화면으로 돌아가기
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  Navigator.of(context).pop(true);
                }
              });
            }
            return;
          }
        }
        
        // API에서 자동으로 읽음 처리가 되었으므로, 서버에서 받아온 isRead 상태를 확인
        // 이전에 읽지 않았던 편지를 읽은 경우에만 UI 업데이트 필요
        final wasUnread = widget.letter.isRead != true;
        final isNowRead = updatedLetter.isRead == true;
        
        // 편지를 읽었음을 표시
        // 읽지 않았던 편지를 읽은 경우에만 true 반환하여 UI 업데이트
        _letterWasRead = wasUnread && isNowRead;
      }
    } catch (e) {
      // 예상치 못한 에러인 경우 기존 편지 정보 사용
      print('편지 상세 조회 실패 (읽음 처리): $e');
      if (mounted) {
        // 에러 발생 시에도 편지를 읽은 것으로 간주하여 새로고침
        _letterWasRead = true;
      }
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      final user = await _repository.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  bool get _isMyLetter {
    if (_currentUser == null) return false;
    // API 명세서: 작성자가 아닌 경우에만 읽음 처리가 수행됨
    return widget.letter.sender.id == _currentUser!.id;
  }

  String _displaySender(Locale locale) {
    if (widget.friendName != null && widget.friendName!.trim().isNotEmpty) {
      return widget.friendName!;
    }
    return widget.letter.localizedSenderDisplay(locale);
  }


  @override
  Widget build(BuildContext context) {
    // 삭제된 편지인 경우 빈 화면 표시 (이미 에러 메시지 표시 및 pop 처리됨)
    if (_letterDeleted) {
      return Scaffold(
        backgroundColor: AppColors.midnight,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final style = widget.letter.template;
    // 템플릿이 있으면 템플릿 색상 사용, 없으면 기본값
    final Color panelBackground = style?.background ?? AppColors.midnight;
    final Color textColor = style?.textColor ?? Colors.white;
    // 전체 배경을 템플릿 색상으로 변경
    final Color scaffoldBackground = panelBackground;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: PreferredSize(
        preferredSize: Size.zero,
        child: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 0,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      bottomNavigationBar: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.localeNotifier,
        builder: (context, locale, _) {
          // 사용자 정보 로딩이 완료되고, 내가 쓴 편지가 아니고, 친구에게 보낸 편지인 경우에만 답장 버튼 표시
          if (!_isLoadingUser && !_isMyLetter && widget.friendName != null && widget.friendName!.trim().isNotEmpty) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: TabaButton(
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WriteLetterPage(
                          replyToLetterId: widget.letter.id,
                          initialRecipient: widget.letter.sender.id,
                          onSuccess: () {
                            // 답장 성공 시 이전 화면으로 돌아가면서 새로고침 필요 표시
                            Navigator.of(context).pop(true);
                          },
                        ),
                      ),
                    );
                  },
                  label: AppStrings.replyButton(locale),
                  icon: Icons.reply_outlined,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Column(
              children: [
                // Header: back button + profile + report button
                Container(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: MediaQuery.of(context).padding.top + AppSpacing.md,
                    bottom: AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _LetterDetailBackButton(
                            onPressed: () => Navigator.of(context).pop(_letterWasRead),
                          ),
                          const Spacer(),
                          // 내가 보낸 편지인 경우 삭제 버튼 표시
                          if (_isMyLetter)
                          TextButton(
                            onPressed: () => _deleteLetter(context),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              AppStrings.deleteButton(locale),
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 14,
                                fontFamily: Theme.of(context).textTheme.labelMedium?.fontFamily,
                              ),
                            ),
                          )
                          // 내가 보낸 편지가 아닐 때 더보기 메뉴 표시 (신고/차단)
                          else
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white70,
                              size: 22,
                            ),
                            color: AppColors.midnightSoft,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onSelected: (value) {
                              if (value == 'report') {
                                _openReportSheet(context);
                              } else if (value == 'block') {
                                _blockUser(context, widget.letter.sender);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'report',
                                child: Row(
                                  children: [
                                    const Icon(Icons.flag_outlined, color: Colors.white70, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppStrings.reportButton(locale),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'block',
                                child: Row(
                                  children: [
                                    const Icon(Icons.block, color: Colors.redAccent, size: 20),
                                    const SizedBox(width: 12),
                                    Text(
                                      AppStrings.blockUser(locale),
                                      style: const TextStyle(color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // 내가 보낸 편지인 경우 내 프로필 표시, 아니면 발신자 프로필 표시
                      if (_isMyLetter && _currentUser != null)
                        Row(
                          children: [
                            UserAvatar(
                              user: _currentUser!,
                              radius: 20,
                              backgroundColor: Colors.white.withAlpha(20),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentUser!.nickname,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      fontFamily: Theme.of(context).textTheme.titleMedium?.fontFamily,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule, size: 12, color: Colors.white54),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.letter.localizedTimeAgo(locale),
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                          fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // 번역 버튼
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IconButton(
                                  onPressed: _isTranslating ? null : () => _toggleTranslation(locale),
                                  icon: Icon(
                                    _showTranslated ? Icons.translate : Icons.translate_outlined,
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                  tooltip: _showTranslated 
                                      ? AppStrings.showOriginal(locale)
                                      : AppStrings.translate(locale),
                                  style: IconButton.styleFrom(
                                    backgroundColor: Colors.white.withOpacity(0.1),
                                    padding: const EdgeInsets.all(8),
                                    minimumSize: const Size(36, 36),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                ),
                                if (_isTranslating)
                                  Positioned(
                                    top: -4,
                                    right: -4,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppColors.neonPink,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: SizedBox(
                                          width: 8,
                                          height: 8,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        )
                      else if (!_isMyLetter)
                      Row(
                        children: [
                          UserAvatar(
                            user: widget.letter.sender,
                            radius: 20,
                            backgroundColor: Colors.white.withAlpha(20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displaySender(locale),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                    fontFamily: Theme.of(context).textTheme.titleMedium?.fontFamily,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule, size: 12, color: Colors.white54),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.letter.localizedTimeAgo(locale),
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 12,
                                        fontFamily: Theme.of(context).textTheme.bodySmall?.fontFamily,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // 번역 버튼
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                onPressed: _isTranslating ? null : () => _toggleTranslation(locale),
                                icon: Icon(
                                  _showTranslated ? Icons.translate : Icons.translate_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                tooltip: _showTranslated 
                                    ? AppStrings.showOriginal(locale)
                                    : AppStrings.translate(locale),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.1),
                                  padding: const EdgeInsets.all(8),
                                  minimumSize: const Size(36, 36),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                              if (_isTranslating)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppColors.neonPink,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        width: 8,
                                        height: 8,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  ),
                // Letter content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitleText(style, textColor, locale),
                        // 제목-본문 간격을 본문 줄간격(height: 2.0, 폰트 24px 기준 약 48px)보다 좁게 설정
                        // 24px = 24px * 1.0
                        const SizedBox(height: 24),
                        _buildContentText(style, textColor, locale),
                        // 첨부한 사진 보기 버튼을 편지 내용 하단에 배치
                        if (widget.letter.attachedImages.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.xl),
                          TabaButton(
                            onPressed: () => _openImageViewer(context, widget.letter.attachedImages),
                            label: AppStrings.viewAttachedPhotos(locale),
                            icon: Icons.photo_library,
                            variant: TabaButtonVariant.outline,
                          ),
                          const SizedBox(height: AppSpacing.xl), // 버튼 아래 패딩 추가
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    
    // 첫 번째 이미지만 미리보기로 표시
    final firstImage = images.first;
    return Container(
      height: 150,
        decoration: BoxDecoration(
          color: AppColors.midnight,
        borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: firstImage.startsWith('http')
                      ? Image.network(
                firstImage,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        )
                      : Image.file(
                File(firstImage),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54),
          ),
        ),
      ),
    );
  }

  void _openImageViewer(BuildContext context, List<String> images) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _ImageViewerScreen(images: images),
      ),
    );
  }

  void _openReportSheet(BuildContext context) {
    TabaModalSheet.show<void>(
      context: context,
      fixedSize: true,
      child: _ReportSheet(letterId: widget.letter.id),
    );
  }

  Future<void> _blockUser(BuildContext context, TabaUser user) async {
    final locale = AppLocaleController.localeNotifier.value;
    
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.blockUser(locale),
      message: AppStrings.blockUserConfirm(locale, user.nickname),
      confirmText: AppStrings.block(locale),
      cancelText: AppStrings.cancel(locale),
      confirmColor: Colors.redAccent,
      icon: Icons.block,
    );

    if (confirmed != true) return;

    final result = await _repository.blockUser(user.id);
    
    if (!mounted) return;
    
    // API 명세서 기준:
    // - 201 Created: 차단 성공
    // - 400 Bad Request: 자기 자신 차단 또는 이미 차단한 사용자
    // - 404 Not Found: 사용자를 찾을 수 없음
    // - 500 Internal Server Error: 서버 오류 (이미 차단된 사용자일 가능성 포함)
    
    final errorMsg = result.message ?? '';
    
    // 성공이거나, 이미 차단한 사용자인 경우 UI에서 차단 처리
    // 서버에서 500 에러를 반환해도 이미 차단된 상태일 수 있으므로 처리
    final shouldTreatAsBlocked = result.success || 
                                 errorMsg.contains('이미 차단') ||
                                 errorMsg.contains('already blocked') ||
                                 errorMsg.contains('서버 오류');
    
    print('🚫 차단 결과: success=${result.success}, shouldTreatAsBlocked=$shouldTreatAsBlocked');
    
    if (shouldTreatAsBlocked) {
      // 성공 메시지 표시
      showTabaSuccess(
        context,
        title: AppStrings.userBlocked(locale),
        message: AppStrings.userBlockedMessage(locale),
      );
      
      // 이전 화면으로 돌아가면서 차단된 사용자 ID 전달
      if (mounted) {
        Navigator.of(context).pop({'blocked': true, 'blockedUserId': user.id});
      }
    } else {
      showTabaError(
        context,
        message: result.message ?? AppStrings.blockFailed(locale),
      );
    }
  }

  Future<void> _deleteLetter(BuildContext context) async {
    final locale = AppLocaleController.localeNotifier.value;
    
    // 삭제 확인 다이얼로그 표시
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.deleteLetter(locale),
      message: AppStrings.deleteLetterConfirm(locale),
      confirmText: AppStrings.deleteButton(locale),
      cancelText: AppStrings.cancel(locale),
      confirmColor: Colors.red,
      icon: Icons.delete_outline,
    );
    
    if (confirmed != true) return;
    
    try {
      final result = await _repository.deleteLetter(widget.letter.id);
      
      if (!mounted) return;
      
      if (result.success) {
        // 삭제 성공 시 편지 상세 화면 닫기 (삭제되었음을 알리기 위해 true 반환)
        Navigator.of(context).pop(true);
        // API 응답의 message가 있으면 사용, 없으면 기본 메시지 사용
        final successMessage = result.message ?? AppStrings.letterDeletedMessage(locale);
        showTabaSuccess(
          context,
          title: AppStrings.letterDeleted(locale),
          message: successMessage,
        );
      } else {
        // API 응답의 에러 메시지가 있으면 사용, 없으면 기본 메시지 사용
        final errorMessage = result.message ?? AppStrings.letterDeleteFailed(locale);
        showTabaError(
          context,
          message: errorMessage,
        );
      }
    } catch (e) {
      if (!mounted) return;
      showTabaError(
        context,
        message: AppStrings.errorOccurred(locale, e.toString()),
      );
    }
  }

  Widget _buildTitleText(LetterStyle? style, Color textColor, Locale locale) {
    // 기본 폰트 크기를 더 크게 설정 (24 -> 28)
    final baseFontSize = style?.fontSize ?? 24;
    final fontSize = baseFontSize * 1.15; // 제목은 본문보다 15% 크게
    final fontFamily = style?.fontFamily;
    
    TextStyle titleTextStyle;
    if (fontFamily != null && fontFamily.isNotEmpty) {
      titleTextStyle = GoogleFonts.getFont(
        fontFamily,
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.8, // 줄간격 더 넓게
      );
    } else {
      // 템플릿 폰트가 없으면 테마 폰트 사용
      final themeFont = Theme.of(context).textTheme.titleLarge?.fontFamily;
      titleTextStyle = TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        height: 1.8, // 줄간격 더 넓게
        fontFamily: themeFont,
      );
    }
    
    final displayText = _showTranslated && _translatedTitle != null
        ? _translatedTitle!
        : widget.letter.title;
    
    return SizedBox(
      width: double.infinity,
      child: Text(
        displayText,
        style: titleTextStyle,
      ),
    );
  }

  Widget _buildContentText(LetterStyle? style, Color textColor, Locale locale) {
    // 기본 폰트 크기를 더 크게 설정 (20 -> 24)
    final fontSize = style?.fontSize ?? 24;
    final fontFamily = style?.fontFamily;
    
    TextStyle contentTextStyle;
    if (fontFamily != null && fontFamily.isNotEmpty) {
      contentTextStyle = GoogleFonts.getFont(
        fontFamily,
        color: Colors.white,
        fontSize: fontSize,
        height: 1.5, // 본문 줄간격
      );
    } else {
      // 템플릿 폰트가 없으면 테마 폰트 사용
      final themeFont = Theme.of(context).textTheme.bodyLarge?.fontFamily;
      contentTextStyle = TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        height: 1.5, // 본문 줄간격
        fontFamily: themeFont,
      );
    }
    
    final displayText = _showTranslated && _translatedContent != null
        ? _translatedContent!
        : widget.letter.content;
    
    return SizedBox(
      width: double.infinity,
      child: Text(
        displayText,
        style: contentTextStyle,
      ),
    );
  }

  Future<void> _toggleTranslation(Locale locale) async {
    if (_showTranslated) {
      // 원문 보기
      setState(() {
        _showTranslated = false;
      });
    } else {
      // 번역하기
      if (_translatedTitle != null && _translatedContent != null) {
        // 이미 번역된 결과가 있으면 바로 표시
        setState(() {
          _showTranslated = true;
        });
      } else {
        // 번역 수행
        setState(() {
          _isTranslating = true;
        });

        try {
          final targetLocale = AppLocaleController.localeNotifier.value;
          
          final results = await _translationService.translateMultiple(
            texts: {
              'title': widget.letter.title,
              'content': widget.letter.content,
            },
            targetLocale: targetLocale,
          );

          if (mounted) {
            setState(() {
              _translatedTitle = results['title'];
              _translatedContent = results['content'];
              _showTranslated = true;
              _isTranslating = false;
            });
          }
        } catch (e) {
          if (mounted) {
            setState(() {
              _isTranslating = false;
            });
            showTabaError(
              context,
              message: AppStrings.translationFailed(locale),
            );
          }
        }
      }
    }
  }
}

class _LetterDetailBackButton extends StatelessWidget {
  const _LetterDetailBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withAlpha(40),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ReportSheet extends StatefulWidget {
  const _ReportSheet({required this.letterId});
  
  final String letterId;

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _repository = DataRepository.instance;
  final _detailsCtrl = TextEditingController();
  String _reason = '스팸/광고';
  bool _submitting = false;

  @override
  void dispose() {
    _detailsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModalSheetHeader(
              title: AppStrings.reportButton(locale),
              onClose: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _reason,
              items: [
                DropdownMenuItem(
                  value: '스팸/광고',
                  child: Text(AppStrings.reportReasonSpam(locale)),
                ),
                DropdownMenuItem(
                  value: '혐오/차별',
                  child: Text(AppStrings.reportReasonHate(locale)),
                ),
                DropdownMenuItem(
                  value: '욕설/괴롭힘',
                  child: Text(AppStrings.reportReasonHarassment(locale)),
                ),
                DropdownMenuItem(
                  value: '개인정보 노출',
                  child: Text(AppStrings.reportReasonPrivacy(locale)),
                ),
                DropdownMenuItem(
                  value: '기타',
                  child: Text(AppStrings.reportReasonOther(locale)),
                ),
              ],
              onChanged: (v) => setState(() => _reason = v ?? _reason),
              decoration: InputDecoration(
                labelText: AppStrings.reportReason(locale),
              ),
            ),
            const SizedBox(height: 12),
            TabaTextField(
              controller: _detailsCtrl,
              minLines: 3,
              maxLines: 6,
              labelText: AppStrings.reportDetails(locale),
              hintText: AppStrings.reportDetailsHint(locale),
            ),
            const SizedBox(height: 16),
            TabaButton(
              onPressed: _submitting ? null : _submit,
              label: _submitting ? AppStrings.sending(locale) : AppStrings.submitReport(locale),
              icon: Icons.send_rounded,
              isLoading: _submitting,
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    
    setState(() => _submitting = true);
    
    try {
      final reasonText = _detailsCtrl.text.trim().isNotEmpty
          ? '$_reason: ${_detailsCtrl.text.trim()}'
          : _reason;
      
      final success = await _repository.reportLetter(widget.letterId, reasonText);
      
      if (!mounted) return;
      
      final locale = AppLocaleController.localeNotifier.value;
      if (success) {
        Navigator.of(context).pop();
        showTabaSuccess(context, message: AppStrings.reportSubmitted(locale));
      } else {
        showTabaError(context, message: AppStrings.reportFailed(locale));
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (!mounted) return;
      final locale = AppLocaleController.localeNotifier.value;
      showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
      setState(() => _submitting = false);
    }
  }
}

class _ImageViewerScreen extends StatefulWidget {
  const _ImageViewerScreen({required this.images});
  final List<String> images;

  @override
  State<_ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<_ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final GlobalKey _shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = 0;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _shareImage(BuildContext context, String imagePath) async {
    try {
      XFile? file;
      
      if (imagePath.startsWith('http') || imagePath.startsWith('https')) {
        // 네트워크 이미지는 다운로드 후 공유
        if (!mounted) return;
        
        // 로딩 표시
        if (mounted) {
          final locale = AppLocaleController.localeNotifier.value;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppStrings.downloadingImage(locale)),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        
        try {
          // 이미지 다운로드
          final uri = Uri.parse(imagePath);
          final response = await http.get(uri).timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              final locale = AppLocaleController.localeNotifier.value;
              throw Exception(AppStrings.downloadTimeout(locale));
            },
          );
          
          if (response.statusCode != 200) {
            final locale = AppLocaleController.localeNotifier.value;
            throw Exception(AppStrings.imageDownloadFailed(locale, response.statusCode));
          }
          
          // Content-Type에서 MIME 타입 확인
          final contentType = response.headers['content-type'] ?? 'image/jpeg';
          String fileExtension = 'jpg';
          if (contentType.contains('png')) {
            fileExtension = 'png';
          } else if (contentType.contains('gif')) {
            fileExtension = 'gif';
          } else if (contentType.contains('webp')) {
            fileExtension = 'webp';
          }
          
          // 파일명에서 확장자 추출 시도
          final urlPath = uri.path;
          if (urlPath.isNotEmpty) {
            final urlExtension = urlPath.split('.').last.toLowerCase();
            if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(urlExtension)) {
              fileExtension = urlExtension;
            }
          }
          
          // 임시 디렉토리에 파일 저장
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final tempFile = File('${tempDir.path}/share_$timestamp.$fileExtension');
          await tempFile.writeAsBytes(response.bodyBytes);
          
          // 파일이 제대로 생성되었는지 확인
          if (!await tempFile.exists()) {
            final locale = AppLocaleController.localeNotifier.value;
            throw Exception(AppStrings.tempFileCreationFailed(locale));
          }
          
          file = XFile(
            tempFile.path,
            mimeType: contentType,
          );
        } catch (e) {
          print('이미지 다운로드 에러: $e');
          rethrow;
        }
      } else {
        // 로컬 파일은 직접 사용
        final localFile = File(imagePath);
        if (!await localFile.exists()) {
          throw Exception('파일을 찾을 수 없습니다: $imagePath');
        }
        
        // MIME 타입 추정
        String mimeType = 'image/jpeg';
        final extension = imagePath.split('.').last.toLowerCase();
        switch (extension) {
          case 'png':
            mimeType = 'image/png';
            break;
          case 'gif':
            mimeType = 'image/gif';
            break;
          case 'webp':
            mimeType = 'image/webp';
            break;
          default:
            mimeType = 'image/jpeg';
        }
        
        file = XFile(
          imagePath,
          mimeType: mimeType,
        );
      }
      
      if (file == null) {
        throw Exception('파일을 준비할 수 없습니다');
      }
      
      // 이미지 공유
      if (mounted) {
        // iOS에서 sharePositionOrigin이 필요함 (공유 버튼의 위치)
        Rect? sharePositionOrigin;
        try {
          final RenderBox? box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
          if (box != null && box.hasSize) {
            final size = box.size;
            final offset = box.localToGlobal(Offset.zero);
            // 공유 버튼의 위치를 계산
            sharePositionOrigin = Rect.fromLTWH(
              offset.dx,
              offset.dy,
              size.width > 0 ? size.width : 44, // 최소 크기 보장
              size.height > 0 ? size.height : 44,
            );
            print('sharePositionOrigin: $sharePositionOrigin');
          } else {
            print('RenderBox를 찾을 수 없거나 크기가 없음');
          }
        } catch (e) {
          print('sharePositionOrigin 계산 실패: $e');
          // 계산 실패 시 null로 두고 공유 시도 (Android에서는 문제 없음)
        }
        
        final locale = AppLocaleController.localeNotifier.value;
        await Share.shareXFiles(
          [file],
          text: AppStrings.share(locale),
          subject: AppStrings.share(locale),
          sharePositionOrigin: sharePositionOrigin,
        );
      }
    } catch (e, stackTrace) {
      print('공유 에러: $e');
      print('스택 트레이스: $stackTrace');
      if (mounted) {
        final locale = AppLocaleController.localeNotifier.value;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppStrings.shareFailed(locale)}: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: AppStrings.confirm(locale),
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          Builder(
            key: _shareButtonKey,
            builder: (buttonContext) => IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _shareImage(buttonContext, widget.images[_currentIndex]),
              tooltip: '공유하기',
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final imagePath = widget.images[index];
          // 아이폰과 갤럭시의 앱바와 특성을 고려하여 이미지를 화면 중앙에 배치
          final mediaQuery = MediaQuery.of(context);
          final screenHeight = mediaQuery.size.height;
          final statusBarHeight = mediaQuery.padding.top;
          final appBarHeight = AppBar().preferredSize.height;
          final bottomPadding = mediaQuery.padding.bottom;
          
          // body 영역의 실제 높이 (AppBar 아래 영역)
          final bodyHeight = screenHeight - statusBarHeight - appBarHeight;
          
          // 화면 전체의 시각적 중앙에 이미지가 보이도록 조정
          // body 영역의 중앙 위치 = statusBarHeight + appBarHeight + bodyHeight / 2
          // 화면 전체의 중앙 = screenHeight / 2
          // offset = body 중앙 - 화면 중앙 = (statusBarHeight + appBarHeight) / 2
          // 하지만 시각적으로는 AppBar를 고려하여 약간 위로 조정
          final bodyCenterY = statusBarHeight + appBarHeight + bodyHeight / 2;
          final screenCenterY = screenHeight / 2;
          // 기본 offset 계산
          var offsetY = bodyCenterY - screenCenterY;
          
          // 디바이스별 미세 조정 (갤럭시와 아이폰 모두 더 위로)
          // Platform.isAndroid를 사용하지 않고 bottomPadding으로 판단
          // 갤럭시는 보통 bottomPadding이 작고, 아이폰은 크거나 0
          if (bottomPadding < 20) {
            // 갤럭시 계열: 더 위로 조정
            offsetY -= screenHeight * 0.12; // 화면 높이의 12%만큼 더 위로
          } else {
            // 아이폰 계열: 더 위로 조정
            offsetY -= screenHeight * 0.10; // 화면 높이의 10%만큼 위로
          }
          
          return SizedBox.expand(
            // 화면 전체를 사용하고 이미지를 body 영역의 중앙에 배치
            child: Transform.translate(
              offset: Offset(0, offsetY),
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                // boundaryMargin을 무한대로 설정하여 클리핑 방지
                boundaryMargin: const EdgeInsets.all(double.infinity),
                // 클리핑 비활성화하여 줌 시 이미지가 잘리지 않도록
                clipBehavior: Clip.none,
                // 화면 가운데에 이미지 배치
                child: Center(
                  child: imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                          ),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54, size: 64),
                          ),
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}



