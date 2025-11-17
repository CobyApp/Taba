import 'dart:io';
import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/data/models/letter.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';
import 'package:taba_app/presentation/screens/write/write_letter_page.dart';

class LetterDetailScreen extends StatefulWidget {
  const LetterDetailScreen({
    super.key,
    required this.letter,
    this.friendName,
  });

  final Letter letter;
  final String? friendName; // if null and anonymous => '익명의 사용자'

  @override
  State<LetterDetailScreen> createState() => _LetterDetailScreenState();
}

class _LetterDetailScreenState extends State<LetterDetailScreen> {
  String get _displaySender {
    if (widget.friendName != null && widget.friendName!.trim().isNotEmpty) {
      return widget.friendName!;
    }
    if (widget.letter.isAnonymous) return '익명의 사용자';
    return widget.letter.senderDisplay;
  }


  @override
  Widget build(BuildContext context) {
    final style = widget.letter.template;
    // 템플릿이 있으면 템플릿 색상 사용, 없으면 기본값
    final Color panelBackground = style?.background ?? AppColors.midnight;
    final Color textColor = style?.textColor ?? Colors.white;
    // 전체 배경도 템플릿 색상으로 변경 (약간 어둡게)
    final Color scaffoldBackground = style != null 
        ? Color.alphaBlend(Colors.black.withOpacity(0.3), panelBackground)
        : AppColors.midnightSoft;

    return Scaffold(
      backgroundColor: scaffoldBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const SizedBox.shrink(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WriteLetterPage(
                      replyToLetterId: widget.letter.id, // 답장 API 사용
                      initialRecipient: widget.friendName != null ? widget.letter.sender.id : null,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.reply_outlined),
              label: const Text('답장하기'),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                // Header under navigation bar: profile + flower/time (left), report button (right)
                Row(
                  children: [
                    UserAvatar(
                      user: widget.letter.sender,
                      radius: 18,
                      backgroundColor: Colors.white.withAlpha(20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _displaySender,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.local_florist_outlined, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.letter.flower.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.schedule, size: 14, color: Colors.white54),
                              const SizedBox(width: 8),
                              Text(widget.letter.timeAgo(), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => _openReportSheet(context),
                      child: const Text('신고', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.letter.attachedImages.isNotEmpty) ...[
                  _buildImageGallery(context, widget.letter.attachedImages),
                  const SizedBox(height: 16),
                ],
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: panelBackground,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(120),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.letter.title,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: style?.fontFamily,
                              fontSize: (style?.fontSize ?? 18) * 1.2, // 제목은 본문보다 20% 크게
                              fontWeight: FontWeight.bold,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.letter.content,
                            style: TextStyle(
                              color: textColor,
                              fontFamily: style?.fontFamily,
                              fontSize: style?.fontSize ?? 16,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageGallery(BuildContext context, List<String> images) {
    if (images.isEmpty) return const SizedBox.shrink();
    
    return GestureDetector(
      onTap: () => _openImageViewer(context, images),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.midnight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: PageView.builder(
            itemCount: images.length,
            itemBuilder: (context, index) {
              final imagePath = images[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  // 이미지가 파일 경로인지 URL인지 확인
                  imagePath.startsWith('http')
                      ? Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        )
                      : Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${index + 1} / ${images.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                ],
              );
            },
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.midnightSoft,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return _ReportSheet(letterId: widget.letter.id);
      },
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
    final inset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: inset),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('신고하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _reason,
              items: const [
                DropdownMenuItem(value: '스팸/광고', child: Text('스팸/광고')),
                DropdownMenuItem(value: '혐오/차별', child: Text('혐오/차별')),
                DropdownMenuItem(value: '욕설/괴롭힘', child: Text('욕설/괴롭힘')),
                DropdownMenuItem(value: '개인정보 노출', child: Text('개인정보 노출')),
                DropdownMenuItem(value: '기타', child: Text('기타')),
              ],
              onChanged: (v) => setState(() => _reason = v ?? _reason),
              decoration: const InputDecoration(labelText: '사유'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _detailsCtrl,
              minLines: 3,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: '상세 내용 (선택)',
                hintText: '상세한 내용을 적어주세요',
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: const Icon(Icons.send_rounded),
                label: Text(_submitting ? '전송 중...' : '신고 접수'),
              ),
            ),
          ],
        ),
      ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고가 접수되었습니다. 검토 후 조치하겠습니다.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('신고 접수에 실패했습니다. 다시 시도해주세요.')),
        );
        setState(() => _submitting = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('오류가 발생했습니다: $e')),
      );
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


