import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:desktop_drop/desktop_drop.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

/// Drag-and-drop / tap-to-upload zone.
/// Uses desktop_drop for native drag-and-drop on desktop platforms.
class UploadDropZone extends StatefulWidget {
  const UploadDropZone({
    super.key,
    required this.onTap,
    required this.onFileDrop,
  });

  final VoidCallback onTap;
  final void Function(String fileName, int fileSize) onFileDrop;

  @override
  State<UploadDropZone> createState() => _UploadDropZoneState();
}

class _UploadDropZoneState extends State<UploadDropZone> {
  bool _isHovered = false;
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final isHighlight = _isHovered || _isDragOver;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragOver = true),
      onDragExited: (_) => setState(() => _isDragOver = false),
      onDragDone: (details) {
        setState(() => _isDragOver = false);
        if (details.files.isNotEmpty) {
          final xFile = details.files.first;
          final name = xFile.name;
          // Check extension
          if (!name.toLowerCase().endsWith('.pdf')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Only PDF files are supported'),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusSM),
                ),
              ),
            );
            return;
          }
          // Get file size from path
          final file = File(xFile.path);
          final fileSize = file.existsSync() ? file.lengthSync() : 0;
          widget.onFileDrop(name, fileSize);
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: AppConstants.fastAnimation,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
            decoration: BoxDecoration(
              color: _isDragOver
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : isHighlight
                      ? AppColors.primary.withValues(alpha: 0.05)
                      : AppColors.glassOverlay,
              borderRadius: BorderRadius.circular(AppConstants.radiusXL),
              border: Border.all(
                color: _isDragOver
                    ? AppColors.primary
                    : isHighlight
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.border,
                width: _isDragOver ? 2.0 : 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Upload icon
                AnimatedContainer(
                  duration: AppConstants.fastAnimation,
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isHighlight
                        ? AppColors.primary.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    _isDragOver
                        ? Icons.file_download_rounded
                        : Icons.cloud_upload_rounded,
                    color: isHighlight
                        ? AppColors.primary
                        : AppColors.textMuted,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  _isDragOver ? 'Release to upload' : 'Drop your PDF here',
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: isHighlight
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'or click to browse files',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Supported formats badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkCard,
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusRound),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'PDF files up to 500MB',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, duration: 400.ms);
  }
}
