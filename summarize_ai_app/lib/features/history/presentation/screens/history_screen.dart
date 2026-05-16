import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/history_provider.dart';
import '../../data/models/history_item.dart';

/// History screen — each PDF upload is displayed as a session card
/// showing the PDF, its summary (if any), and chat activity (if any).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final sessions = historyState.filteredSessions;
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 400
        ? AppConstants.paddingMD
        : AppConstants.paddingLG;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              Text('History', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('Your work sessions', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),

              // ── Search Bar ──────────────────────────────────
              _buildSearchBar(ref, theme),
              const SizedBox(height: 12),

              // ── Filter Tabs + Sort ──────────────────────────
              _buildFilterRow(ref, historyState, theme),
              const SizedBox(height: 12),

              // ── Session List ────────────────────────────────
              Expanded(
                child: sessions.isEmpty
                    ? _buildEmptyState(theme)
                    : ListView.separated(
                        itemCount: sessions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) =>
                            _buildSessionCard(sessions[i], i, theme),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(WidgetRef ref, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: TextField(
        onChanged: (v) => ref.read(historyProvider.notifier).setSearchQuery(v),
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: 'Search sessions...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(WidgetRef ref, HistoryState state, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: HistoryFilter.values.map((f) {
                final isActive = state.filter == f;
                final label = switch (f) {
                  HistoryFilter.all => 'All',
                  HistoryFilter.withSummary => 'Summarized',
                  HistoryFilter.withChat => 'With Chat',
                  HistoryFilter.pdfOnly => 'PDF Only',
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _FilterChip(
                    label: label,
                    isActive: isActive,
                    onTap: () =>
                        ref.read(historyProvider.notifier).setFilter(f),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        PopupMenuButton<HistorySortOrder>(
          onSelected: (v) => ref.read(historyProvider.notifier).setSortOrder(v),
          icon: Icon(
            Icons.sort_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            size: 20,
          ),
          tooltip: 'Sort',
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusSM),
            side: BorderSide(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          itemBuilder: (_) => [
            PopupMenuItem(
              value: HistorySortOrder.newest,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 16,
                    color: state.sortOrder == HistorySortOrder.newest
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Newest first',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: state.sortOrder == HistorySortOrder.newest
                          ? AppColors.primary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: HistorySortOrder.oldest,
              child: Row(
                children: [
                  Icon(
                    Icons.arrow_upward_rounded,
                    size: 16,
                    color: state.sortOrder == HistorySortOrder.oldest
                        ? AppColors.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Oldest first',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: state.sortOrder == HistorySortOrder.oldest
                          ? AppColors.primary
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Session card — shows PDF + summary preview + chat indicator.
  Widget _buildSessionCard(SessionItem session, int index, ThemeData theme) {
    return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── PDF Row ─────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf_rounded,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.pdfName,
                          style: theme.textTheme.labelLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${session.pdfSize} · ${_timeAgo(session.createdAt)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Summary Preview ─────────────────────────────────
              if (session.hasSummary) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description_rounded,
                            color: AppColors.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Summary · ${session.summaryWordCount} words',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        session.summaryPreview!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],

              // ── Chat Badge ──────────────────────────────────────
              if (session.hasChat) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_rounded,
                      color: AppColors.info,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${session.chatMessageCount} messages',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],

              // ── "PDF only" badge if neither ────────────────────
              if (!session.hasSummary && !session.hasChat) ...[
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_empty_rounded,
                      color: AppColors.warning,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Not yet summarized',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.03, end: 0, duration: 300.ms);
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            size: 48,
          ),
          const SizedBox(height: 12),
          Text('No sessions found', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'Try a different filter or search term.',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Filter tab chip widget.
class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppConstants.fastAnimation,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primary.withValues(alpha: 0.15)
                : _hovered
                ? AppColors.glassOverlay
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.primary
                  : Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: Text(
            widget.label,
            style: AppTextStyles.labelMedium.copyWith(
              color: widget.isActive
                  ? AppColors.primary
                  : AppColors.textSecondary,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}
