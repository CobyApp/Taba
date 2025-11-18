import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';

/// 그라데이션 배경을 가진 공통 스캐폴드
class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.gradient = AppColors.gradientGalaxy,
    this.backgroundColor = Colors.transparent,
  });

  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final List<Color> gradient;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: appBar ?? PreferredSize(
          preferredSize: Size.zero,
          child: AppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: 0,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
        body: body,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonLocation: floatingActionButtonLocation,
      ),
    );
  }
}

