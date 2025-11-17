import 'package:flutter/material.dart';
import 'package:taba_app/data/models/user.dart';

class UserAvatar extends StatelessWidget {
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

  String get _effectiveAvatarUrl {
    if (user != null) return user!.avatarUrl;
    return avatarUrl ?? '';
  }

  String get _effectiveInitials {
    if (user != null) return user!.initials;
    return initials ?? '?';
  }

  Color get _effectiveFallbackColor {
    if (user != null) return user!.avatarFallbackColor();
    return fallbackColor ?? const Color(0xFFFF9AC9);
  }

  @override
  Widget build(BuildContext context) {
    final hasAvatar = _effectiveAvatarUrl.isNotEmpty;
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? 
          (hasAvatar ? Colors.transparent : _effectiveFallbackColor),
      backgroundImage: hasAvatar 
          ? NetworkImage(_effectiveAvatarUrl)
          : null,
      onBackgroundImageError: onBackgroundImageError ?? 
          (hasAvatar ? (_, __) {} : null),
      child: hasAvatar 
          ? null 
          : Text(
              _effectiveInitials,
              style: TextStyle(
                fontSize: radius * 0.6,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}

