import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/presentation/widgets/app_logo.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0024), // 어두운 배경
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // flower.png 이미지 (더 크게)
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(100),
                    blurRadius: 20,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/flower.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // flower.png가 없을 경우를 대비한 fallback
                    return Container(
                      color: const Color(0xFF1A0016),
                      child: const Icon(
                        Icons.local_florist,
                        color: Colors.white70,
                        size: 100,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Taba 타이틀 로고 (작게)
            const AppLogo(
              fontSize: 24,
              letterSpacing: 3,
              showSubtitle: false,
            ),
          ],
        ),
      ),
    );
  }
}
