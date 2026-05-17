import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/dashboard_provider.dart';

/// Line chart showing usage over the last 7 days.
class UsageLineChart extends StatelessWidget {
  const UsageLineChart({super.key, required this.data});
  final List<double> data;

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Usage (Last 7 Days)',
      icon: Icons.show_chart_rounded,
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.border,
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: AppTextStyles.labelSmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                    if (v.toInt() >= 0 && v.toInt() < days.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(days[v.toInt()],
                            style: AppTextStyles.labelSmall),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: data
                    .asMap()
                    .entries
                    .map((e) => FlSpot(e.key.toDouble(), e.value))
                    .toList(),
                isCurved: true,
                color: AppColors.primary,
                barWidth: 2.5,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primary,
                    strokeWidth: 1.5,
                    strokeColor: AppColors.darkCard,
                  ),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ],
            minY: 0,
          ),
        ),
      ),
    );
  }
}

/// Bar chart showing PDF categories.
class PdfCategoryBarChart extends StatelessWidget {
  const PdfCategoryBarChart({super.key, required this.categories});
  final List<PdfCategory> categories;

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'PDF Categories',
      icon: Icons.bar_chart_rounded,
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (_) => FlLine(
                color: AppColors.border,
                strokeWidth: 0.5,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (v, _) => Text(
                    v.toInt().toString(),
                    style: AppTextStyles.labelSmall,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) {
                    if (v.toInt() >= 0 && v.toInt() < categories.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(categories[v.toInt()].name,
                            style: AppTextStyles.labelSmall),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            barGroups: categories.asMap().entries.map((e) {
              return BarChartGroupData(
                x: e.key,
                barRods: [
                  BarChartRodData(
                    toY: e.value.count.toDouble(),
                    color: AppColors.primary,
                    width: 24,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(4),
                    ),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: 20,
                      color: AppColors.darkElevated,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// Pie chart showing summary type distribution.
class SummaryTypePieChart extends StatelessWidget {
  const SummaryTypePieChart({super.key, required this.types});
  final List<SummaryTypeData> types;

  static const _colors = [AppColors.primary, AppColors.info, AppColors.warning];

  @override
  Widget build(BuildContext context) {
    return _ChartContainer(
      title: 'Summary Types',
      icon: Icons.pie_chart_rounded,
      child: Column(
        children: [
          SizedBox(
            height: 160,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: types.asMap().entries.map((e) {
                  return PieChartSectionData(
                    color: _colors[e.key % _colors.length],
                    value: e.value.percentage,
                    title: '${e.value.percentage.toInt()}%',
                    radius: 40,
                    titleStyle: AppTextStyles.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: types.asMap().entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: _colors[e.key % _colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(e.value.name, style: AppTextStyles.labelSmall),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// Reusable chart container with title.
class _ChartContainer extends StatelessWidget {
  const _ChartContainer({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPadding = screenWidth < 400 ? 12.0 : 18.0;

    return Container(
      padding: EdgeInsets.all(containerPadding),
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
              Icon(icon, color: AppColors.primary, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(title,
                    style: AppTextStyles.labelLarge,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
