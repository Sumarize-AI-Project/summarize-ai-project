import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/dashboard_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/dashboard_charts.dart';

/// Analytics Dashboard screen with stat cards, charts, and recent activities.
class AnalyticsDashboardScreen extends ConsumerWidget {
  const AnalyticsDashboardScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(
            screenWidth < 400 ? AppConstants.paddingMD : AppConstants.paddingLG,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────
              Text('Dashboard', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Overview of your AI PDF Summarizer activity.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 24),

              // ── Stat Cards ────────────────────────────────
              _buildStatCards(stats, isWide, screenWidth),
              const SizedBox(height: 24),

              // ── Charts ────────────────────────────────────
              _buildCharts(stats, isWide),
              const SizedBox(height: 24),

              // ── Recent Activities ─────────────────────────
              _buildRecentActivities(stats),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

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
}
