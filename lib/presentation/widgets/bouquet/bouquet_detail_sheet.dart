import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/data/models/bouquet.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/taba_button.dart';
import 'package:taba_app/presentation/widgets/taba_text_field.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/bouquet/flower_grid.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/loading_indicator.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/core/locale/app_locale.dart';

/// 꽃다발 상세 모달 시트
class BouquetDetailSheet extends StatelessWidget {
  const BouquetDetailSheet({
    super.key,
    required this.bouquet,
    required this.bouquetName,
    required this.loadedFlowers,
    required this.onSaveName,
    required this.onShare,
    required this.onFlowerTap,
  });

  final FriendBouquet bouquet;
  final String bouquetName;
  final List<SharedFlower>? loadedFlowers;
  final ValueChanged<String> onSaveName;
  final VoidCallback onShare;
  final ValueChanged<SharedFlower> onFlowerTap;

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: bouquetName);
    
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        return TabaModalSheet(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ModalSheetHeader(
                title: AppStrings.bouquetDetail(locale),
                subtitle: AppStrings.bouquetWithFriend(locale, bouquet.friend.user.nickname),
                onClose: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: AppSpacing.xl),
              TabaTextField(
                controller: controller,
                labelText: AppStrings.bouquetName(locale),
                onSubmitted: (value) {
                  final trimmed = value.trim();
                  if (trimmed.isEmpty) return;
                  onSaveName(trimmed);
                  Navigator.of(context).pop();
                  showTabaSuccess(
                    context,
                    title: AppStrings.bouquetNameSaved(locale),
                    message: trimmed,
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              _FlowerGridSection(
                bouquet: bouquet,
                loadedFlowers: loadedFlowers,
                onFlowerTap: onFlowerTap,
              ),
              const SizedBox(height: AppSpacing.xxl),
              TabaButton(
                onPressed: onShare,
                label: AppStrings.shareBouquet(locale),
                icon: Icons.share,
                variant: TabaButtonVariant.outline,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FlowerGridSection extends StatelessWidget {
  const _FlowerGridSection({
    required this.bouquet,
    this.loadedFlowers,
    required this.onFlowerTap,
  });

  final FriendBouquet bouquet;
  final List<SharedFlower>? loadedFlowers;
  final ValueChanged<SharedFlower> onFlowerTap;

  @override
  Widget build(BuildContext context) {
    // 캐시된 데이터가 있으면 사용
    if (loadedFlowers != null && loadedFlowers!.isNotEmpty) {
      return FlowerGrid(
        flowers: loadedFlowers!,
        onFlowerTap: onFlowerTap,
      );
    }

    // 캐시가 없으면 로드
    return FutureBuilder<List<SharedFlower>>(
      future: DataRepository.instance.getFriendLetters(
        friendId: bouquet.friend.user.id,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const TabaLoadingIndicator();
        }
        
        if (snapshot.hasError) {
          return ValueListenableBuilder<Locale>(
            valueListenable: AppLocaleController.localeNotifier,
            builder: (context, locale, _) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white70, size: 48),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      AppStrings.cannotLoadLetters(locale),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${snapshot.error}',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          );
        }
        
        if (!snapshot.hasData) {
          return ValueListenableBuilder<Locale>(
            valueListenable: AppLocaleController.localeNotifier,
            builder: (context, locale, _) {
              return Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  AppStrings.cannotLoadLetters(locale),
                  style: const TextStyle(color: Colors.white70),
                ),
              );
            },
          );
        }
        
        return FlowerGrid(
          flowers: snapshot.data!,
          onFlowerTap: onFlowerTap,
        );
      },
    );
  }
}

