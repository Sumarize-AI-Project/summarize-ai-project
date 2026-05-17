import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/loading_shimmer.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/models/summary_state.dart';
import '../../providers/summary_provider.dart';
import '../widgets/upload_drop_zone.dart';
import '../widgets/file_preview_card.dart';
import '../widgets/summary_result_view.dart';
import '../widgets/word_count_slider.dart';

/// Main PDF Summary screen — upload → process → view result.
class PdfSummaryScreen extends ConsumerWidget {
  const PdfSummaryScreen({super.key});

  Future<void> _pickFile(WidgetRef ref) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      lockParentWindow: true,
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      ref.read(summaryProvider.notifier).selectFile(file);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(summaryProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth < 400
        ? AppConstants.paddingMD
        : AppConstants.paddingLG;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
            ),
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Page Header ───────────────────────────────
                      Text('PDF Summary', style: AppTextStyles.headlineLarge),
                      const SizedBox(height: 4),
                      Text(
                        'Upload a PDF document and let AI generate a comprehensive summary.',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 28),

                      // ── Content based on state ────────────────────
                      _buildContent(context, ref, state),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, SummaryState state) {
    switch (state.status) {
      // ── Idle: Show upload zone ──────────────────────────────────
      case SummaryStatus.idle:
        return UploadDropZone(
          onTap: () => _pickFile(ref),
          onFileDrop: (file) {
            ref.read(summaryProvider.notifier).selectFile(file);
          },
        );

      // ── File Selected: Show preview + word count slider + summarize button
      case SummaryStatus.selected:
        return Column(
          children: [
            FilePreviewCard(
              fileName: state.fileName!,
              fileSize: state.fileSizeFormatted,
              onRemove: () => ref.read(summaryProvider.notifier).clearFile(),
            ),
            const SizedBox(height: 16),

            // ── Word Count Slider ─────────────────────────────
            WordCountSlider(
              wordCount: state.wordCount,
              onChanged: (val) =>
                  ref.read(summaryProvider.notifier).setWordCount(val),
            ),
            const SizedBox(height: 20),

            AppButton(
              label: 'Generate Summary',
              icon: Icons.auto_awesome_rounded,
              onPressed: () =>
                  ref.read(summaryProvider.notifier).startSummarization(),
              height: 48,
              width: double.infinity,
            ),
          ],
        );

      // ── Uploading: Show preview with progress ──────────────────
      case SummaryStatus.uploading:
        return FilePreviewCard(
          fileName: state.fileName!,
          fileSize: state.fileSizeFormatted,
          onRemove: () {},
          isUploading: true,
          uploadProgress: state.uploadProgress,
        );

      // ── Processing: Shimmer loading effect ─────────────────────
      case SummaryStatus.processing:
        return Column(
          children: [
            FilePreviewCard(
              fileName: state.fileName!,
              fileSize: state.fileSizeFormatted,
              onRemove: () {},
              isProcessing: true,
            ),
            const SizedBox(height: 24),
            _buildShimmerResult(),
          ],
        );

      // ── Completed: Show markdown result + re-summarize controls ─
      case SummaryStatus.completed:
        return Column(
          children: [
            SummaryResultView(
              markdown: state.summaryMarkdown!,
              onCopy: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Summary copied to clipboard!'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusSM),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              onNewSummary: () =>
                  ref.read(summaryProvider.notifier).clearFile(),
            ),
            const SizedBox(height: 24),

            // ── Re-summarize Section ─────────────────────────
            _buildResummarizeSection(ref, state),
          ],
        );

      // ── Error ──────────────────────────────────────────────────
      case SummaryStatus.error:
        return _buildErrorView(ref, state);
    }
  }

  /// Section below the result: adjust word count + re-summarize button.
  Widget _buildResummarizeSection(WidgetRef ref, SummaryState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Re-summarize with different settings',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Word count slider
          WordCountSlider(
            wordCount: state.wordCount,
            onChanged: (val) =>
                ref.read(summaryProvider.notifier).setWordCount(val),
          ),
          const SizedBox(height: 16),

          // Re-summarize button
          AppButton(
            label: 'Re-summarize (${state.wordCount} words)',
            icon: Icons.refresh_rounded,
            onPressed: () =>
                ref.read(summaryProvider.notifier).resummarize(),
            height: 48,
            width: double.infinity,
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerResult() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title shimmer
          const LoadingShimmer(width: 200, height: 24),
          const SizedBox(height: 20),
          // Text block shimmer
          const LoadingShimmer.textBlock(
              lines: 4, lineHeight: 14, spacing: 12),
          const SizedBox(height: 24),
          const LoadingShimmer(width: 160, height: 20),
          const SizedBox(height: 16),
          const LoadingShimmer.textBlock(
              lines: 3, lineHeight: 14, spacing: 12),
          const SizedBox(height: 24),
          // Table shimmer
          const LoadingShimmer.card(height: 80),
          const SizedBox(height: 24),
          const LoadingShimmer.textBlock(
              lines: 2, lineHeight: 14, spacing: 12),
        ],
      ),
    );
  }

  Widget _buildErrorView(WidgetRef ref, SummaryState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusMD),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: 48),
          const SizedBox(height: 16),
          Text('Something went wrong',
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.error)),
          const SizedBox(height: 8),
          Text(
            state.errorMessage ?? 'An unexpected error occurred.',
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          AppButton(
            label: 'Try Again',
            icon: Icons.refresh_rounded,
            onPressed: () => ref.read(summaryProvider.notifier).clearFile(),
            isOutlined: true,
            height: 40,
          ),
        ],
      ),
    );
  }
}
