import 'package:flutter/material.dart';
import 'package:taba_app/data/models/user.dart';

class UserAvatar extends StatefulWidget {
  const UserAvatar({
    super.key,
    this.user,
    this.avatarUrl,
    this.initials,
    this.fallbackColor,
    this.radius = 20,
    this.backgroundColor,
    this.onBackgroundImageError,
  }) : assert(
          user != null || avatarUrl != null || initials != null,
          'Either user or avatarUrl/initials must be provided',
        );

  final TabaUser? user;
  final String? avatarUrl;
  final String? initials;
  final Color? fallbackColor;
  final double radius;
  final Color? backgroundColor;
  final ImageErrorListener? onBackgroundImageError;

  @override
  State<UserAvatar> createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  bool _hasImageError = false;

  String get _effectiveAvatarUrl {
    if (widget.user != null) return widget.user!.avatarUrl;
    return widget.avatarUrl ?? '';
  }

  String get _effectiveInitials {
    if (widget.user != null) return widget.user!.initials;
    return widget.initials ?? '?';
  }

  Color get _effectiveFallbackColor {
    if (widget.user != null) return widget.user!.avatarFallbackColor();
    return widget.fallbackColor ?? const Color(0xFFFF9AC9);
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = _effectiveAvatarUrl.isNotEmpty;
    final shouldShowFallback = !hasAvatar || _hasImageError;
    final hasValidImage = hasAvatar && !_hasImageError;
    
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: widget.backgroundColor ?? 
          (shouldShowFallback ? const Color(0xFF0A0024) : Colors.transparent), // 어두운 배경
      backgroundImage: hasValidImage
          ? NetworkImage(_effectiveAvatarUrl)
          : null,
      onBackgroundImageError: hasValidImage
          ? (exception, stackTrace) {
              // 이미지 로드 실패 시 에러 상태로 변경하여 fallback 표시
              if (mounted) {
                setState(() {
                  _hasImageError = true;
                });
              }
              if (widget.onBackgroundImageError != null) {
                widget.onBackgroundImageError!(exception, stackTrace);
              }
            }
          : null, // backgroundImage가 null이면 onBackgroundImageError도 null이어야 함
      child: shouldShowFallback
          ? ClipOval(
              child: Image.asset(
                'assets/images/flower.png',
                width: widget.radius * 2,
                height: widget.radius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // flower.png가 없을 경우를 대비한 fallback (기존 initials 표시)
                  return Container(
                    color: _effectiveFallbackColor,
                    child: Center(
                      child: Text(
                        _effectiveInitials,
                        style: TextStyle(
                          fontSize: widget.radius * 0.6,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          : null,
    );
  }
}

