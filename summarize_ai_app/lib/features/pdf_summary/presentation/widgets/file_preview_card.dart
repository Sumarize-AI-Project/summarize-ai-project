import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Card showing selected file info with remove button + upload progress.
class FilePreviewCard extends StatelessWidget {
  const FilePreviewCard({
    super.key,
    required this.fileName,
    required this.fileSize,
    required this.onRemove,
    this.uploadProgress,
    this.isUploading = false,
    this.isProcessing = false,
  });

  final String fileName;
  final String fileSize;
  final VoidCallback onRemove;
  final double? uploadProgress;
  final bool isUploading;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(
          color: isProcessing
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // PDF icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
                child: const Icon(Icons.picture_as_pdf_rounded,
                    color: AppColors.error, size: 24),
              ),
              const SizedBox(width: 12),

              // File info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: AppTextStyles.labelLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(fileSize, style: AppTextStyles.labelSmall),
                  ],
                ),
              ),

              // Status / remove
              if (isProcessing)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                )
              else if (!isUploading)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textMuted, size: 20),
                  tooltip: 'Remove file',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),

          // Upload progress bar
          if (isUploading && uploadProgress != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: uploadProgress,
                backgroundColor: AppColors.darkElevated,
                color: AppColors.primary,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uploading...',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${(uploadProgress! * 100).toInt()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          // Processing indicator
          if (isProcessing) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: const LinearProgressIndicator(
                backgroundColor: AppColors.darkElevated,
                color: AppColors.primary,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'AI is analyzing your document...',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.03, end: 0, duration: 300.ms);
  }
}
