import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/models/user.dart';
import 'package:taba_app/data/repository/data_repository.dart';
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
  TabaUser? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
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
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          // 내가 보낸 편지가 아닐 때만 신고 버튼 표시
                          if (!_isMyLetter)
                            TextButton(
                              onPressed: () => _openReportSheet(context),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                AppStrings.reportButton(locale),
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                  fontFamily: Theme.of(context).textTheme.labelMedium?.fontFamily,
                                ),
                              ),
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
                          ],
                        ),
                    ],
                  ),
                ),
                if (widget.letter.attachedImages.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.xl,
                      0,
                      AppSpacing.xl,
                      AppSpacing.md,
                    ),
                    child: Column(
                      children: [
                        TabaButton(
                          onPressed: () => _openImageViewer(context, widget.letter.attachedImages),
                          label: AppStrings.viewAttachedPhotos(locale),
                          icon: Icons.photo_library,
                          variant: TabaButtonVariant.outline,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildImageGallery(context, widget.letter.attachedImages),
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
                        _buildTitleText(style, textColor),
                        // 제목-본문 간격을 본문 줄간격(height: 2.0, 폰트 24px 기준 약 48px)보다 좁게 설정
                        // 24px = 24px * 1.0
                        const SizedBox(height: 24),
                        _buildContentText(style, textColor),
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

  Widget _buildTitleText(LetterStyle? style, Color textColor) {
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
    
    return SizedBox(
      width: double.infinity,
      child: Text(
        widget.letter.title,
        style: titleTextStyle,
      ),
    );
  }

  Widget _buildContentText(LetterStyle? style, Color textColor) {
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
    
    return SizedBox(
      width: double.infinity,
      child: Text(
        widget.letter.content,
        style: contentTextStyle,
      ),
    );
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
      
      if (success) {
        Navigator.of(context).pop();
        showTabaSuccess(context, message: '신고가 접수되었습니다. 검토 후 조치하겠습니다.');
      } else {
        showTabaError(context, message: '신고 접수에 실패했습니다. 다시 시도해주세요.');
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (!mounted) return;
      showTabaError(context, message: '오류가 발생했습니다: $e');
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
          return Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
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
          );
        },
      ),
    );
  }
}


