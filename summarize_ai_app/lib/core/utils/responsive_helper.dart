import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Responsive utilities to determine device type and adapt layout.
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Check if current screen width is mobile-sized.
  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < AppConstants.tabletBreakpoint;

  /// Check if current screen width is tablet-sized.
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.tabletBreakpoint &&
        width < AppConstants.desktopBreakpoint;
  }

  /// Check if current screen width is desktop-sized.
  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= AppConstants.desktopBreakpoint;

  /// Get the current device type as an enum.
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppConstants.tabletBreakpoint) return DeviceType.mobile;
    if (width < AppConstants.desktopBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  /// Returns a value based on the current screen size.
  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Get the sidebar width based on device type.
  static double getSidebarWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0,
      tablet: AppConstants.sidebarCollapsedWidth,
      desktop: AppConstants.sidebarWidth,
    );
  }

  /// Get the chat panel width based on device type.
  static double getChatPanelWidth(BuildContext context) {
    return responsiveValue(
      context,
      mobile: 0,
      desktop: AppConstants.chatPanelWidth,
    );
  }
}

/// Device type enum for responsive decisions.
enum DeviceType { mobile, tablet, desktop }
