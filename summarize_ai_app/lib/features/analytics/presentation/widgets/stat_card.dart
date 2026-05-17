import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Animated stat card with counting animation.
/// Uses FittedBox to prevent overflow on narrow screens.
class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.suffix = '',
    this.delay = Duration.zero,
  });

  final String title;
  final double value;
  final IconData icon;
  final Color iconColor;
  final String suffix;
  final Duration delay;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _countAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _countAnimation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: widget.iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 16),
              ),
              const Spacer(),
              Icon(Icons.trending_up_rounded,
                  color: AppColors.success, size: 14),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedBuilder(
            animation: _countAnimation,
            builder: (context, child) {
              final val = _countAnimation.value;
              final display = widget.suffix == 's'
                  ? val.toStringAsFixed(1)
                  : val.toInt().toString();
              return FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$display${widget.suffix}',
                  style: AppTextStyles.displaySmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(widget.title, style: AppTextStyles.bodySmall),
          ),
        ],
      ),
    )
        .animate(delay: widget.delay)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }
}
