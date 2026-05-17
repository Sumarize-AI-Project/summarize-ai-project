import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Dashboard analytics mock data provider.
final dashboardProvider =
    StateNotifierProvider<DashboardNotifier, DashboardStats>((ref) {
  return DashboardNotifier();
});

class DashboardStats {
  final int totalPdfs;
  final int totalSummaries;
  final int totalChats;
  final double avgProcessingTime;
  final List<double> weeklyUsage; // 7 days
  final List<PdfCategory> pdfCategories;
  final List<SummaryTypeData> summaryTypes;
  final List<ActivityItem> recentActivities;

  const DashboardStats({
    this.totalPdfs = 0,
    this.totalSummaries = 0,
    this.totalChats = 0,
    this.avgProcessingTime = 0,
    this.weeklyUsage = const [],
    this.pdfCategories = const [],
    this.summaryTypes = const [],
    this.recentActivities = const [],
  });
}

class PdfCategory {
  final String name;
  final int count;
  const PdfCategory({required this.name, required this.count});
}

class SummaryTypeData {
  final String name;
  final double percentage;
  const SummaryTypeData({required this.name, required this.percentage});
}

class ActivityItem {
  final String title;
  final String action;
  final DateTime time;
  const ActivityItem({
    required this.title,
    required this.action,
    required this.time,
  });
}

class DashboardNotifier extends StateNotifier<DashboardStats> {
  DashboardNotifier() : super(const DashboardStats()) {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    state = DashboardStats(
      totalPdfs: 47,
      totalSummaries: 38,
      totalChats: 124,
      avgProcessingTime: 2.8,
      weeklyUsage: [5, 8, 12, 7, 15, 10, 9],
      pdfCategories: const [
        PdfCategory(name: 'Research', count: 18),
        PdfCategory(name: 'Textbook', count: 12),
        PdfCategory(name: 'Report', count: 9),
        PdfCategory(name: 'Article', count: 5),
        PdfCategory(name: 'Other', count: 3),
      ],
      summaryTypes: const [
        SummaryTypeData(name: 'Brief (<300w)', percentage: 25),
        SummaryTypeData(name: 'Standard (300-800w)', percentage: 45),
        SummaryTypeData(name: 'Detailed (>800w)', percentage: 30),
      ],
      recentActivities: [
        ActivityItem(
            title: 'Machine Learning Report.pdf',
            action: 'Uploaded & summarized',
            time: now.subtract(const Duration(hours: 1))),
        ActivityItem(
            title: 'Neural Networks Paper',
            action: 'AI chat started',
            time: now.subtract(const Duration(hours: 3))),
        ActivityItem(
            title: 'Data Mining Textbook.pdf',
            action: 'Re-summarized (1200 words)',
            time: now.subtract(const Duration(hours: 5))),
        ActivityItem(
            title: 'NLP Research Paper.pdf',
            action: 'Uploaded & summarized',
            time: now.subtract(const Duration(days: 1))),
        ActivityItem(
            title: 'CV Handbook',
            action: 'AI chat - 15 messages',
            time: now.subtract(const Duration(days: 2))),
      ],
    );
  }
}
