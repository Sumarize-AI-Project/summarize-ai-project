import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// A reusable glassmorphism card widget with backdrop blur effect.
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blurSigma = AppConstants.glassBlurSigma,
    this.color,
    this.borderColor,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final Color? color;
  final Color? borderColor;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(AppConstants.radiusLG);

    return Container(
      margin: margin,
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              color: color ?? AppColors.glassWhite,
              borderRadius: radius,
              border: Border.all(
                color: borderColor ?? AppColors.glassBorder,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 20,
                  spreadRadius: -5,
                ),
              ],
            ),
            padding: padding ??
                const EdgeInsets.all(AppConstants.paddingLG),
            child: child,
          ),
        ),
      ),
    );
  }
}
