import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

/// A reusable gradient button with optional icon, loading state, and hover effect.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.gradient,
    this.width,
    this.height = 48,
    this.borderRadius,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final Gradient? gradient;
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final TextStyle? textStyle;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ??
        BorderRadius.circular(AppConstants.radiusMD);

    if (widget.isOutlined) {
      return _buildOutlinedButton(radius);
    }
    return _buildGradientButton(radius);
  }

  Widget _buildGradientButton(BorderRadius radius) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onPressed != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.forbidden,
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.onPressed != null
              ? (widget.gradient ?? AppColors.primaryGradient)
              : null,
          color: widget.onPressed == null ? AppColors.textMuted : null,
          borderRadius: radius,
          boxShadow: _isHovered && widget.onPressed != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: radius,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.textOnPrimary,
                      ),
                    )
                  : _buildContent(AppColors.textOnPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(BorderRadius radius) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: AppConstants.fastAnimation,
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: radius,
          border: Border.all(
            color: AppColors.primary,
            width: 1.5,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.isLoading ? null : widget.onPressed,
            borderRadius: radius,
            child: Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.primary,
                      ),
                    )
                  : _buildContent(AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color color) {
    final style = widget.textStyle ??
        TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        );

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(widget.label, style: style),
        ],
      );
    }
    return Text(widget.label, style: style);
  }
}
