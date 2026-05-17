import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../data/navigation_items.dart';

/// Desktop/Tablet sidebar with logo, nav items, search, and user profile.
/// Supports collapsed mode (icon-only) for tablet.
class Sidebar extends ConsumerWidget {
  const Sidebar({
    super.key,
    required this.currentIndex,
    required this.onNavItemTap,
    required this.onNewSummary,
    this.isCollapsed = false,
  });

  final int currentIndex;
  final ValueChanged<int> onNavItemTap;
  final VoidCallback onNewSummary;
  final bool isCollapsed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final width = isCollapsed
        ? AppConstants.sidebarCollapsedWidth
        : AppConstants.sidebarWidth;

    return AnimatedContainer(
      duration: AppConstants.normalAnimation,
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        gradient: AppColors.sidebarGradient,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildLogo(),
                      const SizedBox(height: 24),
                      _buildNewSummaryButton(),
                      const SizedBox(height: 16),

                      if (!isCollapsed)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            'MENU',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),

                      ...List.generate(mainNavItems.length, (i) {
                        return _buildNavItem(mainNavItems[i], i);
                      }),

                      const Spacer(),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isCollapsed ? 12 : 20,
                        ),
                        child: const Divider(color: AppColors.divider),
                      ),
                      const SizedBox(height: 4),
                      _buildUserProfile(authState),
                      const SizedBox(height: 4),
                      _buildLogoutButton(ref),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLogo() {
    if (isCollapsed) {
      return Center(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.auto_awesome,
              color: AppColors.textOnPrimary, size: 20),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome,
                color: AppColors.textOnPrimary, size: 18),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'AI PDF\nSummarizer',
              style: AppTextStyles.labelLarge.copyWith(
                height: 1.2,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewSummaryButton() {
    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: 'New Summary',
          child: InkWell(
            onTap: onNewSummary,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.add, color: AppColors.textOnPrimary, size: 20),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AppButton(
        label: 'New Summary',
        onPressed: onNewSummary,
        icon: Icons.add_rounded,
        height: 42,
        width: double.infinity,
      ),
    );
  }

  Widget _buildNavItem(NavItemData item, int index) {
    final isActive = index == currentIndex;

    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: item.label,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: InkWell(
              onTap: () => onNavItemTap(index),
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMD),
                ),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onNavItemTap(index),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          hoverColor: AppColors.glassOverlay,
          child: AnimatedContainer(
            duration: AppConstants.fastAnimation,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.radiusMD),
              border: isActive
                  ? Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2))
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isActive ? item.activeIcon : item.icon,
                  color: isActive ? AppColors.primary : AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color:
                        isActive ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(AuthState authState) {
    final email = authState.user?.email ?? '';

    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: email,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : 'U',
              style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.primary.withValues(alpha: 0.2),
            child: Text(
              email.isNotEmpty ? email[0].toUpperCase() : 'U',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 10),
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
        ],
      ),
    );
  }

  Widget _buildLogoutButton(WidgetRef ref) {
    if (isCollapsed) {
      return Center(
        child: Tooltip(
          message: 'Logout',
          child: IconButton(
            onPressed: () => _handleLogout(ref),
            icon: const Icon(Icons.logout_rounded,
                color: AppColors.textMuted, size: 20),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleLogout(ref),
          borderRadius: BorderRadius.circular(AppConstants.radiusMD),
          hoverColor: AppColors.error.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.logout_rounded,
                    color: AppColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text('Logout', style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleLogout(WidgetRef ref) {
    ref.read(authProvider.notifier).logout();
  }
}
