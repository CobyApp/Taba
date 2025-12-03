import 'package:flutter/material.dart';
import 'package:taba_app/core/constants/app_colors.dart';
import 'package:taba_app/core/constants/app_spacing.dart';
import 'package:taba_app/core/locale/app_locale.dart';
import 'package:taba_app/core/locale/app_strings.dart';
import 'package:taba_app/data/dto/block_dto.dart';
import 'package:taba_app/data/repository/data_repository.dart';
import 'package:taba_app/presentation/widgets/empty_state.dart';
import 'package:taba_app/presentation/widgets/gradient_scaffold.dart';
import 'package:taba_app/presentation/widgets/loading_indicator.dart';
import 'package:taba_app/presentation/widgets/modal_sheet.dart';
import 'package:taba_app/presentation/widgets/nav_header.dart';
import 'package:taba_app/presentation/widgets/taba_notice.dart';
import 'package:taba_app/presentation/widgets/user_avatar.dart';

/// 차단한 사용자 목록 화면
class BlockListScreen extends StatefulWidget {
  const BlockListScreen({super.key});

  @override
  State<BlockListScreen> createState() => _BlockListScreenState();
}

class _BlockListScreenState extends State<BlockListScreen> {
  final _repository = DataRepository.instance;
  List<BlockedUserDto> _blockedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _repository.getBlockedUsers();
      print('📋 차단 목록 조회 결과: ${users.length}명');
      for (final user in users) {
        print('   - ${user.nickname} (${user.id})');
      }
      if (mounted) {
        setState(() {
          _blockedUsers = users;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ 차단 목록 조회 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        final locale = AppLocaleController.localeNotifier.value;
        showTabaError(context, message: AppStrings.errorOccurred(locale, e.toString()));
      }
    }
  }

  Future<void> _unblockUser(BlockedUserDto user) async {
    final locale = AppLocaleController.localeNotifier.value;
    
    final confirmed = await TabaModalSheet.showConfirm(
      context: context,
      title: AppStrings.unblock(locale),
      message: AppStrings.unblockConfirm(locale, user.nickname),
      confirmText: AppStrings.unblock(locale),
      cancelText: AppStrings.cancel(locale),
      confirmColor: AppColors.neonBlue,
    );

    if (confirmed != true) return;

    final result = await _repository.unblockUser(user.id);
    
    if (!mounted) return;
    
    print('🔓 차단 해제 결과: success=${result.success}, message=${result.message}');
    
    // API 명세서 기준: 성공이거나 이미 해제된 사용자인 경우 UI에서 처리
    final errorMsg = result.message ?? '';
    final shouldTreatAsUnblocked = result.success || 
                                   errorMsg.contains('차단하지 않은') ||
                                   errorMsg.contains('not blocked') ||
                                   errorMsg.contains('서버 오류');
    
    print('🔓 shouldTreatAsUnblocked=$shouldTreatAsUnblocked');
    
    if (shouldTreatAsUnblocked) {
      // 목록에서 즉시 제거
      setState(() {
        _blockedUsers.removeWhere((u) => u.id == user.id);
      });
      
      showTabaSuccess(
        context,
        title: AppStrings.userUnblocked(locale),
        message: AppStrings.userUnblockedMessage(locale),
      );
    } else {
      showTabaError(
        context,
        message: result.message ?? AppStrings.unblockFailed(locale),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLocaleController.localeNotifier,
      builder: (context, locale, _) {
        return GradientScaffold(
          body: SafeArea(
            child: Column(
              children: [
                NavHeader(
                  showBackButton: true,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(child: TabaLoadingIndicator())
                      : _blockedUsers.isEmpty
                          ? _buildEmptyState(locale)
                          : _buildBlockedUsersList(locale),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(Locale locale) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80), // 40px 위로 올리기 (bottom padding 추가)
      child: Center(
        child: EmptyState(
          icon: Icons.block_outlined,
          title: AppStrings.blockedUsersEmpty(locale),
          subtitle: AppStrings.blockedUsersEmptySubtitle(locale),
        ),
      ),
    );
  }

  Widget _buildBlockedUsersList(Locale locale) {
    return RefreshIndicator(
      onRefresh: _loadBlockedUsers,
      color: AppColors.neonPink,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _blockedUsers.length,
        itemBuilder: (context, index) {
          final user = _blockedUsers[index];
          return _buildBlockedUserCard(user, locale);
        },
      ),
    );
  }

  Widget _buildBlockedUserCard(BlockedUserDto user, Locale locale) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        leading: UserAvatar(
          avatarUrl: user.avatarUrl,
          initials: user.nickname.isNotEmpty ? user.nickname[0].toUpperCase() : '?',
          radius: 24,
        ),
        title: Text(
          user.nickname,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          AppStrings.blockedAt(locale, user.blockedAt),
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
        trailing: TextButton(
          onPressed: () => _unblockUser(user),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.neonPink,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
          ),
          child: Text(
            AppStrings.unblock(locale),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

