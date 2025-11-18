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
        showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
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
                        Text(
                          AppStrings.appName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 34,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppStrings.loginSubtitle(locale),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        TabaCard(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            children: [
                              const SizedBox(height: 4),
                              TabaTextField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                labelText: AppStrings.email(locale),
                                hintText: AppStrings.emailHint(locale),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TabaTextField(
                                controller: _passwordCtrl,
                                obscureText: true,
                                labelText: AppStrings.password(locale),
                                hintText: AppStrings.passwordHint(locale),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              TabaButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                label: AppStrings.loginWithEmail(locale),
                                isLoading: _isLoading,
                              ),
                              const SizedBox(height: AppSpacing.sm),
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
