import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/history_item.dart';
import '../../auth/providers/auth_provider.dart';

/// Provider for session-based history with filtering, sorting, and local persistence.
final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
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
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState()) {
    _loadHistory();
    // Listen to changes in the active user email to automatically reload history
    _ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous?.user?.email != next.user?.email) {
        _loadHistory();
      }
    });
  }

  String get _historyKey {
    final email = _ref.read(authProvider).user?.email ?? 'anonymous';
    return 'history_sessions_v1_${email.toLowerCase().replaceAll('.', '_')}';
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_historyKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> list = json.decode(jsonStr) as List<dynamic>;
        final sessions = list
            .map((item) => SessionItem.fromJson(item as Map<String, dynamic>))
            .toList();
        state = state.copyWith(allSessions: sessions);
      } else {
        state = state.copyWith(allSessions: const []);
      }
    } catch (e) {
      state = state.copyWith(allSessions: const []);
    }
  }

  Future<void> _saveHistory(List<SessionItem> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_historyKey, jsonStr);
    } catch (e) {
      // Error handling
    }
  }

  /// Saves a session or updates it if it already exists.
  Future<void> saveOrUpdateSession(SessionItem session) async {
    final list = List<SessionItem>.from(state.allSessions);
    final index = list.indexWhere((s) => s.id == session.id);
    if (index != -1) {
      list[index] = session;
    } else {
      list.insert(0, session);
    }
    state = state.copyWith(allSessions: list);
    await _saveHistory(list);
  }

  /// Deletes a session by its ID.
  Future<void> deleteSession(String id) async {
    final list = state.allSessions.where((s) => s.id != id).toList();
    state = state.copyWith(allSessions: list);
    await _saveHistory(list);
  }

  /// Clears all stored sessions.
  Future<void> clearAllHistory() async {
    state = state.copyWith(allSessions: const []);
    await _saveHistory(const []);
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
