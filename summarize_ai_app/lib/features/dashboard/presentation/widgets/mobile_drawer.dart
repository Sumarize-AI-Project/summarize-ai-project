import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/navigation_items.dart';

/// Mobile drawer navigation — full sidebar content in a Drawer.
class MobileDrawer extends ConsumerWidget {
  const MobileDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavItemTap,
    required this.onNewSummary,
  });

  final int currentIndex;
  final ValueChanged<int> onNavItemTap;
  final VoidCallback onNewSummary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final email = authState.user?.email ?? '';

    return Drawer(
      backgroundColor: AppColors.darkSidebar,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // ── Logo ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.auto_awesome,
                        color: AppColors.textOnPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'AI PDF Summarizer',
                    style: AppTextStyles.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── New Summary ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AppButton(
                label: 'New Summary',
                onPressed: () {
                  Navigator.pop(context);
                  onNewSummary();
                },
                icon: Icons.add_rounded,
                height: 44,
              ),
            ),
            const SizedBox(height: 20),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider),
            ),
            const SizedBox(height: 8),

            // ── Nav Items ────────────────────────────────────
            ...List.generate(mainNavItems.length, (i) {
              final item = mainNavItems[i];
              final isActive = i == currentIndex;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                child: ListTile(
                  leading: Icon(
                    isActive ? item.activeIcon : item.icon,
                    color:
                        isActive ? AppColors.primary : AppColors.textMuted,
                    size: 22,
                  ),
                  title: Text(
                    item.label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: isActive
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  selected: isActive,
                  selectedTileColor:
                      AppColors.primary.withValues(alpha: 0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusMD),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    onNavItemTap(i);
                  },
                ),
              );
            }),

            const Spacer(),

            // ── User + Logout ────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Divider(color: AppColors.divider),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor:
                        AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      email.isNotEmpty ? email[0].toUpperCase() : 'U',
                      style: AppTextStyles.labelLarge
                          .copyWith(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(email,
                            style: AppTextStyles.labelMedium,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ref.read(authProvider.notifier).logout();
                    },
                    icon: const Icon(Icons.logout_rounded,
                        color: AppColors.textMuted, size: 20),
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
