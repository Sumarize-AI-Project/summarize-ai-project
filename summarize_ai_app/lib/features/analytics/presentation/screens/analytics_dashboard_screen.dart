import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
// ignore: unused_import
import '../../providers/dashboard_provider.dart';
// ignore: unused_import
import '../widgets/stat_card.dart';
// ignore: unused_import
import '../widgets/dashboard_charts.dart';

/// Analytics Dashboard screen with stat cards, charts, and recent activities.
class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  // ignore: unused_element
  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLG),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Pulsing Glow Logo/Icon ───────────────────────
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.insights_rounded,
                    color: AppColors.textOnPrimary,
                    size: 48,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),

                const SizedBox(height: 36),

                // ── Gradient Coming Soon Text ─────────────────────
                ShaderMask(
                  shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                  child: Text(
                    'COMING SOON',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4.0,
                    ),
                  ),
                ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 12),

                // ── Dashboard Analytics Title ──────────────────────
                Text(
                  'Dashboard Analytics',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 150.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 16),

                // ── Premium Subtitle ──────────────────────────────
                Text(
                  'Chúng tôi đang phát triển các công cụ phân tích dữ liệu thông minh giúp thống kê chi tiết hiệu suất đọc, khối lượng tài liệu và tần suất hỏi đáp với trợ lý AI của bạn.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutCubic),

                const SizedBox(height: 40),

                // ── Status Indicator Tag ──────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.3, 1.3),
                        duration: 800.ms,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đang hoàn thiện - Phiên bản kế tiếp',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 450.ms, duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /*
  Widget _buildStatCards(
      DashboardStats stats, bool isWide, double screenWidth) {
    final cards = [
      StatCard(
        title: 'Total PDFs',
        value: stats.totalPdfs.toDouble(),
        icon: Icons.picture_as_pdf_rounded,
        iconColor: AppColors.error,
        delay: Duration.zero,
      ),
      StatCard(
        title: 'Summaries',
        value: stats.totalSummaries.toDouble(),
        icon: Icons.description_rounded,
        iconColor: AppColors.primary,
        delay: 100.ms,
      ),
      StatCard(
        title: 'Total Chats',
        value: stats.totalChats.toDouble(),
        icon: Icons.chat_bubble_rounded,
        iconColor: AppColors.info,
        delay: 200.ms,
      ),
      StatCard(
        title: 'Avg Time',
        value: stats.avgProcessingTime,
        icon: Icons.timer_rounded,
        iconColor: AppColors.warning,
        suffix: 's',
        delay: 300.ms,
      ),
    ];

    if (isWide) {
      return Row(
        children: cards
            .map((c) => Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: c,
                  ),
                ))
            .toList(),
      );
    }

    // Mobile: 2 cards per row, use Wrap for flexible sizing (no overflow)
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: cards.map((c) {
        final cardWidth = (screenWidth -
                (screenWidth < 400
                    ? AppConstants.paddingMD * 2
                    : AppConstants.paddingLG * 2) -
                8) /
            2;
        return SizedBox(
          width: cardWidth.clamp(120.0, 300.0),
          child: c,
        );
      }).toList(),
    );
  }

  Widget _buildCharts(DashboardStats stats, bool isWide) {
    final lineChart = UsageLineChart(data: stats.weeklyUsage);
    final barChart = PdfCategoryBarChart(categories: stats.pdfCategories);
    final pieChart = SummaryTypePieChart(types: stats.summaryTypes);

    if (isWide) {
      return Column(
        children: [
          lineChart,
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: barChart),
              const SizedBox(width: 16),
              Expanded(child: pieChart),
            ],
          ),
        ],
      );
    }
    return Column(
      children: [
        lineChart,
        const SizedBox(height: 16),
        barChart,
        const SizedBox(height: 16),
        pieChart,
      ],
    );
  }

  Widget _buildRecentActivities(DashboardStats stats) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Text('Recent Activity', style: AppTextStyles.labelLarge),
            ],
          ),
          const SizedBox(height: 14),
          ...stats.recentActivities.asMap().entries.map((e) {
            final item = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title,
                            style: AppTextStyles.labelMedium,
                            overflow: TextOverflow.ellipsis),
                        Text(item.action, style: AppTextStyles.bodySmall),
                      ],
                    ),
                  ),
                  Text(_timeAgo(item.time), style: AppTextStyles.labelSmall),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: e.key * 80))
                .fadeIn(duration: 300.ms);
          }),
        ],
      ),
    );
  }
  */
}
