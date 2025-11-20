import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/taba_card.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      gradient: AppColors.gradientGalaxy,
      body: SafeArea(
        top: false,
        child: ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavHeader(
                  showBackButton: true,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                    child: TabaCard(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: SingleChildScrollView(
                        child: DefaultTextStyle(
                          style: TextStyle(
                            color: Colors.white70,
                            height: 1.5,
                            fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppStrings.tabaTerms(locale),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(AppStrings.termsContent(locale)),
                              const SizedBox(height: 16),
                              Text(
                                AppStrings.privacyPolicy(locale),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: Theme.of(context).textTheme.titleLarge?.fontFamily,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(AppStrings.privacyContent(locale)),
                            ],
                          ),
                        ),
                      ),
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

class TermsContent extends StatelessWidget {
  const TermsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return ModalSheetHeader(
              title: AppStrings.termsAndPrivacy(locale),
              onClose: () => Navigator.of(context).pop(),
            );
          },
        ),
        const SizedBox(height: 12),
        TabaCard(
          padding: const EdgeInsets.all(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white70, height: 1.5),
                child: ValueListenableBuilder<Locale>(
                  valueListenable: AppLocaleController.localeNotifier,
                  builder: (context, locale, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.tabaTerms(locale),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(AppStrings.termsContent(locale)),
                        const SizedBox(height: 16),
                        Text(
                          AppStrings.privacyPolicy(locale),
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(AppStrings.privacyContent(locale)),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TermsOnlyContent extends StatefulWidget {
  const TermsOnlyContent({super.key});

  @override
  State<TermsOnlyContent> createState() => _TermsOnlyContentState();
}

class _TermsOnlyContentState extends State<TermsOnlyContent> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return ModalSheetHeader(
              title: AppStrings.termsTitle(locale),
              onClose: () => Navigator.of(context).pop(),
            );
          },
        ),
        const SizedBox(height: 12),
        TabaCard(
          padding: const EdgeInsets.all(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white70, height: 1.5),
                child: ValueListenableBuilder<Locale>(
                  valueListenable: AppLocaleController.localeNotifier,
                  builder: (context, locale, _) {
                    return Text(AppStrings.termsContent(locale));
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agree,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                  title: Text(AppStrings.agreeToTerms(locale)),
                ),
                TabaButton(
                  onPressed: _agree ? () => Navigator.of(context).pop(true) : null,
                  label: AppStrings.agreeAndClose(locale),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class PrivacyOnlyContent extends StatefulWidget {
  const PrivacyOnlyContent({super.key});

  @override
  State<PrivacyOnlyContent> createState() => _PrivacyOnlyContentState();
}

class _PrivacyOnlyContentState extends State<PrivacyOnlyContent> {
  bool _agree = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return ModalSheetHeader(
              title: AppStrings.privacyPolicy(locale),
              onClose: () => Navigator.of(context).pop(),
            );
          },
        ),
        const SizedBox(height: 12),
        TabaCard(
          padding: const EdgeInsets.all(14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 420),
            child: SingleChildScrollView(
              child: DefaultTextStyle(
                style: const TextStyle(color: Colors.white70, height: 1.5),
                child: ValueListenableBuilder<Locale>(
                  valueListenable: AppLocaleController.localeNotifier,
                  builder: (context, locale, _) {
                    return Text(AppStrings.privacyContent(locale));
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ValueListenableBuilder<Locale>(
          valueListenable: AppLocaleController.localeNotifier,
          builder: (context, locale, _) {
            return Column(
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _agree,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                  title: Text(AppStrings.agreeToPrivacy(locale)),
                ),
                TabaButton(
                  onPressed: _agree ? () => Navigator.of(context).pop(true) : null,
                  label: AppStrings.agreeAndClose(locale),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}


