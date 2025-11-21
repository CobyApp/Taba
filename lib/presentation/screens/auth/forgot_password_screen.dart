import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final locale = AppLocaleController.localeNotifier.value;
    
    if (_emailCtrl.text.isEmpty) {
      if (mounted) {
        showTabaError(context, message: AppStrings.emailRequired(locale));
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final success =
          await DataRepository.instance.forgotPassword(_emailCtrl.text.trim());

      if (mounted) {
        if (success) {
          showTabaSuccess(context, message: AppStrings.passwordResetEmailSent(locale));
          Navigator.of(context).pop();
        } else {
          showTabaError(context, message: AppStrings.emailSendFailed(locale));
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
            return Column(
              children: [
                NavHeader(
                  showBackButton: true,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppStrings.forgotPasswordSubtitle(locale)),
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
                              TabaButton(
                                onPressed: _isLoading ? null : _sendReset,
                                label: AppStrings.sendResetLink(locale),
                                isLoading: _isLoading,
                              ),
                            ],
                          ),
                        ),
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
}


