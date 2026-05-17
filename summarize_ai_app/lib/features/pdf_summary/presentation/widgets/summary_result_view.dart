import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Displays the generated summary as rendered Markdown with action buttons.
class SummaryResultView extends StatelessWidget {
  const SummaryResultView({
    super.key,
    required this.markdown,
    required this.onCopy,
    required this.onNewSummary,
  });

  final String markdown;
  final VoidCallback onCopy;
  final VoidCallback onNewSummary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header with actions ────────────────────────────────────
        Row(
          children: [
            Icon(Icons.check_circle_rounded,
                color: AppColors.success, size: 22),
            const SizedBox(width: 8),
            Text(
              'Summary Generated',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.success,
              ),
            ),
            const Spacer(),
            _ActionChip(
              icon: Icons.copy_rounded,
              label: 'Copy',
              onTap: () {
                Clipboard.setData(ClipboardData(text: markdown));
                onCopy();
              },
            ),
            const SizedBox(width: 8),
            _ActionChip(
              icon: Icons.refresh_rounded,
              label: 'New',
              onTap: onNewSummary,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Markdown body ──────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkCard,
            borderRadius: BorderRadius.circular(AppConstants.radiusMD),
            border: Border.all(color: AppColors.border),
          ),
          child: MarkdownBody(
            data: markdown,
            selectable: true,
            styleSheet: MarkdownStyleSheet(
              h1: AppTextStyles.headlineLarge,
              h2: AppTextStyles.headlineMedium,
              h3: AppTextStyles.headlineSmall,
              h4: AppTextStyles.labelLarge.copyWith(fontSize: 16),
              p: AppTextStyles.bodyLarge.copyWith(height: 1.7),
              listBullet: AppTextStyles.bodyLarge,
              strong: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              em: AppTextStyles.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
              ),
              code: GoogleFonts.firaCode(
                fontSize: 13,
                color: AppColors.primary,
                backgroundColor: AppColors.darkElevated,
              ),
              codeblockDecoration: BoxDecoration(
                color: AppColors.darkElevated,
                borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                border: Border.all(color: AppColors.border),
              ),
              blockquote: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
              blockquoteDecoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.5),
                    width: 3,
                  ),
                ),
              ),
              tableBorder: TableBorder.all(
                color: AppColors.border,
                width: 0.5,
              ),
              tableHead: AppTextStyles.labelLarge,
              tableBody: AppTextStyles.bodyMedium,
              tableCellsPadding: const EdgeInsets.all(8),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
            ),
          ),
        ),
      ],
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.03, end: 0, duration: 500.ms);
  }
}

/// Small chip button for actions (Copy, Download, etc.)
class _ActionChip extends StatefulWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  State<_ActionChip> createState() => _ActionChipState();
}

class _ActionChipState extends State<_ActionChip> {
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.15)
                : AppColors.darkElevated,
            borderRadius: BorderRadius.circular(AppConstants.radiusRound),
            border: Border.all(
              color: _hovered ? AppColors.primary : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon,
                  size: 14,
                  color: _hovered ? AppColors.primary : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: _hovered ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
