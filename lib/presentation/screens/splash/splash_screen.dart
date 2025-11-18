import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1900FF), Color(0xFF5300FF), Color(0xFFFF2EB6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 아이콘을 더 크고 화려하게
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: const LinearGradient(
                    colors: AppColors.gradientHeroPink,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonPink.withAlpha(150),
                      blurRadius: 32,
                      spreadRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white.withAlpha(40),
                      blurRadius: 16,
                      spreadRadius: 4,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withAlpha(100),
                    width: 3,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SvgPicture.asset(
                    'assets/svg/app_icon.svg',
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              // 앱 이름 스타일 개선
              Text(
                'Taba',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black.withAlpha(100),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        Shadow(
                          color: AppColors.neonPink.withAlpha(150),
                          blurRadius: 24,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // 서브 타이틀 추가
              Text(
                '편지로 소통하는 공간',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withAlpha(200),
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
