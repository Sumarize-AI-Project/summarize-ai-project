import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// A shimmer loading placeholder for content loading states.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
    this.margin,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  /// Creates a shimmer effect simulating a text block (multiple lines).
  const factory LoadingShimmer.textBlock({
    Key? key,
    int lines,
    double lineHeight,
    double spacing,
  }) = _TextBlockShimmer;

  /// Creates a shimmer effect simulating a card.
  const factory LoadingShimmer.card({
    Key? key,
    double height,
    double? width,
  }) = _CardShimmer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Shimmer.fromColors(
        baseColor: AppColors.darkElevated,
        highlightColor: AppColors.darkCard,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.darkElevated,
            borderRadius:
                borderRadius ?? BorderRadius.circular(AppConstants.radiusSM),
          ),
        ),
      ),
    );
  }
}

/// Shimmer placeholder for multi-line text.
class _TextBlockShimmer extends LoadingShimmer {
  const _TextBlockShimmer({
    super.key,
    this.lines = 3,
    this.lineHeight = 14,
    this.spacing = 10,
  });

  final int lines;
  final double lineHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.darkElevated,
      highlightColor: AppColors.darkCard,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines, (index) {
          // Last line is shorter for visual realism
          final isLast = index == lines - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: index < lines - 1 ? spacing : 0),
            child: Container(
              width: isLast ? 180 : double.infinity,
              height: lineHeight,
              decoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Shimmer placeholder for a card.
class _CardShimmer extends LoadingShimmer {
  const _CardShimmer({
    super.key,
    super.height = 120,
    super.width,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.darkElevated,
      highlightColor: AppColors.darkCard,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.darkElevated,
          borderRadius: BorderRadius.circular(AppConstants.radiusLG),
        ),
      ),
    );
  }
}
