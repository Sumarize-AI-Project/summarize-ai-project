import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/history_item.dart';

/// Provider for session-based history with filtering and sorting.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier();
});

class HistoryState {
  final List<SessionItem> allSessions;
  final HistoryFilter filter;
  final HistorySortOrder sortOrder;
  final String searchQuery;

  const HistoryState({
    this.allSessions = const [],
    this.filter = HistoryFilter.all,
    this.sortOrder = HistorySortOrder.newest,
    this.searchQuery = '',
  });

  List<SessionItem> get filteredSessions {
    var items = allSessions.where((s) {
      // Filter by type
      if (filter == HistoryFilter.withSummary && !s.hasSummary) return false;
      if (filter == HistoryFilter.withChat && !s.hasChat) return false;
      if (filter == HistoryFilter.pdfOnly && (s.hasSummary || s.hasChat)) {
        return false;
      }
      // Filter by search query
      if (searchQuery.isNotEmpty) {
        return s.pdfName.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (s.summaryPreview?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false);
      }
      return true;
    }).toList();

    // Sort
    items.sort((a, b) => sortOrder == HistorySortOrder.newest
        ? b.createdAt.compareTo(a.createdAt)
        : a.createdAt.compareTo(b.createdAt));

    return items;
  }

  HistoryState copyWith({
    List<SessionItem>? allSessions,
    HistoryFilter? filter,
    HistorySortOrder? sortOrder,
    String? searchQuery,
  }) {
    return HistoryState(
      allSessions: allSessions ?? this.allSessions,
      filter: filter ?? this.filter,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

enum HistoryFilter { all, withSummary, withChat, pdfOnly }

enum HistorySortOrder { newest, oldest }

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier() : super(const HistoryState()) {
    _loadMockData();
  }

  void _loadMockData() {
    final now = DateTime.now();
    final sessions = <SessionItem>[
      SessionItem(
        id: '1',
        pdfName: 'Machine Learning Report.pdf',
        pdfSize: '2.4 MB',
        createdAt: now.subtract(const Duration(hours: 1)),
        summaryPreview: 'This document presents a comprehensive analysis of artificial intelligence applications in modern document processing...',
        summaryWordCount: 450,
        chatMessageCount: 12,
      ),
      SessionItem(
        id: '2',
        pdfName: 'Data Mining Textbook.pdf',
        pdfSize: '15.7 MB',
        createdAt: now.subtract(const Duration(hours: 5)),
        summaryPreview: 'An in-depth exploration of data mining techniques including classification, clustering, and association rules...',
        summaryWordCount: 1200,
        chatMessageCount: 5,
      ),
      SessionItem(
        id: '3',
        pdfName: 'Neural Networks Paper.pdf',
        pdfSize: '4.1 MB',
        createdAt: now.subtract(const Duration(days: 1)),
        summaryPreview: 'The paper discusses advanced neural network architectures including CNNs, RNNs, and transformer models...',
        summaryWordCount: 600,
        chatMessageCount: 8,
      ),
      SessionItem(
        id: '4',
        pdfName: 'NLP Research Paper.pdf',
        pdfSize: '3.8 MB',
        createdAt: now.subtract(const Duration(days: 2)),
        summaryPreview: 'A study on natural language processing methods for text summarization and sentiment analysis...',
        summaryWordCount: 800,
        chatMessageCount: 0,
      ),
      SessionItem(
        id: '5',
        pdfName: 'Computer Vision Handbook.pdf',
        pdfSize: '22.3 MB',
        createdAt: now.subtract(const Duration(days: 4)),
        summaryPreview: 'Comprehensive guide to computer vision techniques including image recognition, object detection, and segmentation...',
        summaryWordCount: 1500,
        chatMessageCount: 15,
      ),
      SessionItem(
        id: '6',
        pdfName: 'Reinforcement Learning Guide.pdf',
        pdfSize: '8.9 MB',
        createdAt: now.subtract(const Duration(days: 6)),
        summaryPreview: null, // Not yet summarized
        chatMessageCount: 0,
      ),
      SessionItem(
        id: '7',
        pdfName: 'Statistics Fundamentals.pdf',
        pdfSize: '5.2 MB',
        createdAt: now.subtract(const Duration(days: 7)),
        summaryPreview: 'Essential statistical concepts including probability distributions, hypothesis testing, and regression analysis...',
        summaryWordCount: 700,
        chatMessageCount: 3,
      ),
      SessionItem(
        id: '8',
        pdfName: 'Deep Learning Architectures.pdf',
        pdfSize: '11.0 MB',
        createdAt: now.subtract(const Duration(days: 10)),
        summaryPreview: null, // Not yet summarized
        chatMessageCount: 2,
      ),
      SessionItem(
        id: '9',
        pdfName: 'AI Ethics Report.pdf',
        pdfSize: '1.8 MB',
        createdAt: now.subtract(const Duration(days: 12)),
        summaryPreview: 'Discusses the ethical implications of AI including bias, transparency, and accountability in automated systems...',
        summaryWordCount: 350,
        chatMessageCount: 0,
      ),
      SessionItem(
        id: '10',
        pdfName: 'Big Data Analytics.pdf',
        pdfSize: '18.5 MB',
        createdAt: now.subtract(const Duration(days: 14)),
        summaryPreview: null,
        chatMessageCount: 0,
      ),
    ];
    state = state.copyWith(allSessions: sessions);
  }

  void setFilter(HistoryFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setSortOrder(HistorySortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}
