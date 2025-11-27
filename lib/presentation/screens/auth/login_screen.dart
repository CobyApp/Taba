import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/screens/auth/signup_screen.dart';
import 'package:taba_app/presentation/screens/auth/forgot_password_screen.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/app_logo.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onSuccess});

  final VoidCallback onSuccess;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final locale = AppLocaleController.localeNotifier.value;
    
    if (_emailCtrl.text.isEmpty || _passwordCtrl.text.isEmpty) {
      if (mounted) {
        showTabaError(context, message: AppStrings.emailPasswordRequired(locale));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success = await DataRepository.instance.login(
        _emailCtrl.text.trim(),
        _passwordCtrl.text,
      );

      if (mounted) {
        if (success) {
          widget.onSuccess();
        } else {
          showTabaError(context, message: AppStrings.loginFailed(locale));
        }
      }
    } catch (e) {
      if (mounted) {
        // 예외 발생 시 에러 메시지 표시 (iPad에서 발생할 수 있는 네트워크 에러 등 처리)
        final errorMessage = e.toString().toLowerCase();
        String displayMessage;
        
        if (errorMessage.contains('socketexception') || 
            errorMessage.contains('network') ||
            errorMessage.contains('timeout') ||
            errorMessage.contains('connection')) {
          displayMessage = '${AppStrings.loginFailed(locale)}\n네트워크 연결을 확인해주세요.';
        } else if (errorMessage.contains('401') || 
                   errorMessage.contains('unauthorized') ||
                   errorMessage.contains('invalid_credentials')) {
          displayMessage = '이메일 또는 비밀번호가 올바르지 않습니다.';
        } else {
          displayMessage = '${AppStrings.loginFailed(locale)}: ${e.toString()}';
        }
        
        showTabaError(context, message: displayMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: AppColors.gradientDusk,
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: MediaQuery.of(context).padding.top + AppSpacing.xl,
                    bottom: AppSpacing.xl,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 앱 로고 (메인 화면과 동일하게)
                        const AppLogo(
                          fontSize: 20,
                          letterSpacing: 2,
                          shadows: [], // 그림자 제거
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppStrings.loginSubtitle(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: AppSpacing.xl * 1.5),
                        TabaCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              TabaTextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                labelText: AppStrings.email(locale),
                                hintText: AppStrings.emailHint(locale),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TabaTextField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                labelText: AppStrings.password(locale),
                                hintText: AppStrings.passwordHint(locale),
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              TabaButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                label: AppStrings.loginWithEmail(locale),
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) => const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.findPassword(locale),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text('·', style: TextStyle(color: Colors.white54)),
                                    ),
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: const Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                SignupScreen(onSuccess: widget.onSuccess),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        AppStrings.signupWithEmail(locale),
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// Social login UI removed
