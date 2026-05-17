import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../constants/app_constants.dart';

/// Glassmorphism helper utilities for creating frosted glass effects.
class Glassmorphism {
  Glassmorphism._();

  /// Standard glass decoration for cards and panels.
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AppColors.glassWhite,
    borderRadius: BorderRadius.circular(AppConstants.radiusLG),
    border: Border.all(
      color: AppColors.glassBorder,
      width: 1.0,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 20,
        spreadRadius: -5,
      ),
    ],
  );

  /// Subtle glass decoration for sidebar items and smaller elements.
  static BoxDecoration get subtleDecoration => BoxDecoration(
    color: AppColors.glassOverlay,
    borderRadius: BorderRadius.circular(AppConstants.radiusMD),
    border: Border.all(
      color: AppColors.glassBorder.withValues(alpha: 0.1),
      width: 0.5,
    ),
  );

  /// Strong glass decoration for modals and prominent UI.
  static BoxDecoration get strongDecoration => BoxDecoration(
    color: AppColors.glassWhite.withValues(alpha: 0.15),
    borderRadius: BorderRadius.circular(AppConstants.radiusXL),
    border: Border.all(
      color: AppColors.glassBorder.withValues(alpha: 0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 30,
        spreadRadius: -5,
      ),
      BoxShadow(
        color: AppColors.primary.withValues(alpha: 0.05),
        blurRadius: 40,
        spreadRadius: -10,
      ),
    ],
  );

  /// Wrap a child widget with a backdrop blur filter.
  static Widget blurContainer({
    required Widget child,
    double blurSigma = AppConstants.glassBlurSigma,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return ClipRRect(
      borderRadius: (decoration?.borderRadius as BorderRadius?) ??
          BorderRadius.circular(AppConstants.radiusLG),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: decoration ?? cardDecoration,
          padding: padding,
          margin: margin,
          child: child,
        ),
      ),
    );
  }
}
