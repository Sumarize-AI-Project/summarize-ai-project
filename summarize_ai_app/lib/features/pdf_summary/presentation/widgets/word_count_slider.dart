import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Slider for adjusting the desired word count of the AI summary (150–2000).
class WordCountSlider extends StatelessWidget {
  const WordCountSlider({
    super.key,
    required this.wordCount,
    required this.onChanged,
  });

  final int wordCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ──────────────────────────────────────
          Row(
            children: [
              Icon(Icons.short_text_rounded,
                  color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Summary Length',
                style: AppTextStyles.labelLarge,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusRound),
                ),
                child: Text(
                  '$wordCount words',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Slider ──────────────────────────────────────────
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.darkElevated,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withValues(alpha: 0.15),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: wordCount.toDouble(),
              min: 150,
              max: 2000,
              divisions: 37, // (2000-150)/50 = 37 steps of 50 words
              onChanged: (val) => onChanged(val.round()),
            ),
          ),

          // ── Labels ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('150', style: AppTextStyles.labelSmall),
              Text('Brief',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted)),
              Text('Moderate',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted)),
              Text('Detailed',
                  style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textMuted)),
              Text('2000', style: AppTextStyles.labelSmall),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.03, end: 0, duration: 300.ms);
  }
}
