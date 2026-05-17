import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../../pdf_summary/providers/summary_provider.dart';
import '../../../ai_chat/providers/chat_provider.dart';

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
                            authState.user?.email.isNotEmpty == true
                                ? authState.user!.email[0].toUpperCase()
                                : 'U',
                            style: AppTextStyles.displayMedium.copyWith(
                              color: AppColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Email Only ─────────────────────────────
                      Text(
                        authState.user?.email ?? 'user@example.com',
                        style: theme.textTheme.headlineMedium,
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
                      const SizedBox(height: 32),



                      // ── Logout ─────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ref.read(summaryProvider.notifier).clearFile();
                            ref.read(chatProvider.notifier).clearChat();
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
                      const SizedBox(height: 12),

                      // ── Delete Account ─────────────────────────
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _showDeleteAccountDialog(context, ref),
                          icon: const Icon(Icons.delete_forever_rounded,
                              color: AppColors.error),
                          label: Text('Delete Account',
                              style: AppTextStyles.labelLarge
                                  .copyWith(color: AppColors.error, decoration: TextDecoration.underline)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
          // ignore: use_null_aware_elements
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.error,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Xóa tài khoản?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          content: Text(
            'Hành động này không thể hoàn tác. Toàn bộ tài khoản, lịch sử tóm tắt tài liệu và đoạn chat của bạn sẽ bị xóa vĩnh viễn khỏi thiết bị.',
            style: theme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                
                // Clear active summary and chat first
                ref.read(summaryProvider.notifier).clearFile();
                ref.read(chatProvider.notifier).clearChat();
                
                // Execute delete account
                final success = await ref.read(authProvider.notifier).deleteAccount();
                if (success && context.mounted) {
                  // Navigate back to login
                  context.go('/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã xóa tài khoản và dữ liệu thành công!'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textOnPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
              ),
              child: const Text('Xóa vĩnh viễn'),
            ),
          ],
        );
      },
    );
  }
}
