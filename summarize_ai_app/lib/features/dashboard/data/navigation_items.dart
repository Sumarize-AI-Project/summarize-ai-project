import 'package:flutter/material.dart';

/// Navigation item data used by Sidebar, Drawer, and BottomNav.
class NavItemData {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const NavItemData({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

/// Main navigation items for the dashboard (no AI Chat — moved to right panel).
const List<NavItemData> mainNavItems = [
  NavItemData(
    label: 'Dashboard',
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
  ),
  NavItemData(
    label: 'Summary',
    icon: Icons.description_outlined,
    activeIcon: Icons.description,
  ),
  NavItemData(
    label: 'History',
    icon: Icons.history_outlined,
    activeIcon: Icons.history_rounded,
  ),
  NavItemData(
    label: 'Profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
  ),
];
