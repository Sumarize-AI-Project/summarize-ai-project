import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
// ignore: unused_import
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/providers/auth_provider.dart';

/// Profile / Settings screen with avatar, info, and theme toggle.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 400
        ? AppConstants.paddingMD
        : AppConstants.paddingLG;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // ── Avatar ─────────────────────────────────
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 24,
                              spreadRadius: -4,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            authState.user?.name.isNotEmpty == true
                                ? authState.user!.name[0].toUpperCase()
                                : 'U',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Name & Email ───────────────────────────
                      Text(
                        authState.user?.name ?? 'User',
                        style: theme.textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.user?.email ?? 'user@example.com',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 32),

                      // ── Appearance Section ─────────────────────
                      _buildSectionTitle('Appearance', theme),
                      const SizedBox(height: 12),
                      _buildSettingsTile(
                        theme: theme,
                        icon: isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        title: 'Theme',
                        subtitle: isDark ? 'Dark Mode' : 'Light Mode',
                        trailing: Switch(
                          value: isDark,
                          onChanged: (_) =>
                              ref.read(themeProvider.notifier).toggleTheme(),
                          activeThumbColor: AppColors.primary,
                          inactiveThumbColor: AppColors.textMuted,
                          inactiveTrackColor: AppColors.darkElevated,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Account Section ────────────────────────
                      _buildSectionTitle('Account', theme),
                      const SizedBox(height: 12),
                      _buildSettingsTile(
                        theme: theme,
                        icon: Icons.person_outline_rounded,
                        title: 'Edit Profile',
                        subtitle: 'Update your name and avatar',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 8),
                      _buildSettingsTile(
                        theme: theme,
                        icon: Icons.lock_outline_rounded,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 8),
                      _buildSettingsTile(
                        theme: theme,
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Manage notification preferences',
                        trailing: Icon(Icons.chevron_right_rounded,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(height: 32),

                      // ── Logout ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(authProvider.notifier).logout();
                          },
                          icon: const Icon(Icons.logout_rounded,
                              color: AppColors.error),
                          label: Text('Logout',
                              style: AppTextStyles.labelLarge
                                  .copyWith(color: AppColors.error)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.radiusMD),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          letterSpacing: 1.5,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildSettingsTile({
    required ThemeData theme,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 1),
                Text(subtitle,
                    style: theme.textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
