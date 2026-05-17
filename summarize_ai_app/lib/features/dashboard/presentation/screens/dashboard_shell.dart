import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../auth/providers/auth_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/mobile_bottom_nav.dart';
import '../widgets/mobile_drawer.dart';
import '../../../ai_chat/presentation/screens/ai_chat_screen.dart';
import '../../data/navigation_items.dart';

import '../../../pdf_summary/providers/summary_provider.dart';
import '../../../ai_chat/providers/chat_provider.dart';

/// Main dashboard shell — responsive layout wrapping all dashboard content.
///
/// - Desktop (≥1200px): Sidebar (260px) | Content | AI Assistant Panel (360px)
/// - Tablet (600–1200px): Collapsed Sidebar (72px) | Content
/// - Mobile (<600px): Drawer + Content + Bottom Nav
///
/// AI Chat panel appears as a right panel on desktop, and as a FAB overlay
/// on tablet/mobile — only when on the Summary tab (index 1).
class DashboardShell extends ConsumerStatefulWidget {
  const DashboardShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends ConsumerState<DashboardShell> {
  bool _showChatOverlay = false;

  void _onNavItemTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
    // Close overlay when switching tabs
    if (_showChatOverlay) {
      setState(() => _showChatOverlay = false);
    }
  }

  void _onNewSummary() {
    widget.navigationShell.goBranch(1);
    ref.read(summaryProvider.notifier).clearFile();
    ref.read(chatProvider.notifier).clearChat();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for logout → navigate to login
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.unauthenticated &&
          prev?.status != AuthStatus.unauthenticated) {
        if (context.mounted) {
          context.go('/login');
        }
      }
    });

    final deviceType = ResponsiveHelper.getDeviceType(context);
    final isSummaryTab = widget.navigationShell.currentIndex == 1;

    return switch (deviceType) {
      DeviceType.desktop => _buildDesktopLayout(context),
      DeviceType.tablet => _buildTabletLayout(context, isSummaryTab),
      DeviceType.mobile => _buildMobileLayout(context, isSummaryTab),
    };
  }

  // ── Desktop: Sidebar | Content | AI Assistant Panel ──────────────────
  Widget _buildDesktopLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            currentIndex: widget.navigationShell.currentIndex,
            onNavItemTap: _onNavItemTap,
            onNewSummary: _onNewSummary,
            isCollapsed: false,
          ),
          Expanded(child: _buildContentArea(context)),
          // AI Chat panel always visible on desktop
          Container(
            width: 360,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
            ),
            child: const AiChatScreen(),
          ),
        ],
      ),
    );
  }

  // ── Tablet: Collapsed Sidebar | Content + optional FAB ──────────────
  Widget _buildTabletLayout(BuildContext context, bool isSummaryTab) {
    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              Sidebar(
                currentIndex: widget.navigationShell.currentIndex,
                onNavItemTap: _onNavItemTap,
                onNewSummary: _onNewSummary,
                isCollapsed: true,
              ),
              Expanded(child: _buildContentArea(context)),
            ],
          ),
          // Chat overlay
          if (_showChatOverlay) _buildChatOverlay(context),
        ],
      ),
      floatingActionButton: isSummaryTab ? _buildChatFAB() : null,
    );
  }

  // ── Mobile: Drawer + Content + Bottom Nav + optional FAB ─────────────
  Widget _buildMobileLayout(BuildContext context, bool isSummaryTab) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        titleSpacing: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: AppColors.textOnPrimary,
                size: 14,
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                mainNavItems[widget.navigationShell.currentIndex].label,
                style: Theme.of(context).textTheme.headlineSmall,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: Theme.of(ctx).colorScheme.onSurface,
            ),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
      ),
      drawer: MobileDrawer(
        currentIndex: widget.navigationShell.currentIndex,
        onNavItemTap: _onNavItemTap,
        onNewSummary: _onNewSummary,
      ),
      body: Stack(
        children: [
          widget.navigationShell,
          if (_showChatOverlay) _buildChatOverlay(context),
        ],
      ),
      bottomNavigationBar: MobileBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onNavItemTap,
      ),
      floatingActionButton: isSummaryTab ? _buildChatFAB() : null,
    );
  }

  // ── AI Chat FAB ─────────────────────────────────────────────────────
  Widget _buildChatFAB() {
    return FloatingActionButton(
      onPressed: () => setState(() => _showChatOverlay = !_showChatOverlay),
      backgroundColor: AppColors.primary,
      child: Icon(
        _showChatOverlay ? Icons.close_rounded : Icons.chat_rounded,
        color: AppColors.textOnPrimary,
      ),
    );
  }

  // ── AI Chat Overlay Panel ───────────────────────────────────────────
  Widget _buildChatOverlay(BuildContext context) {
    return Positioned(
      right: 12,
      bottom: 80,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: 340,
          height: 480,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: const AiChatScreen(),
        ),
      ),
    );
  }

  // ── Content area wrapper (non-mobile) ───────────────────────────────
  Widget _buildContentArea(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: widget.navigationShell,
    );
  }
}
