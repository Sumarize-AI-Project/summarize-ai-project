/// State model for PDF summary feature.
class SummaryState {
  final SummaryStatus status;
  final String? fileName;
  final int? fileSizeBytes;
  final double uploadProgress;
  final String? summaryMarkdown;
  final String? errorMessage;
  final int wordCount;

  const SummaryState({
    this.status = SummaryStatus.idle,
    this.fileName,
    this.fileSizeBytes,
    this.uploadProgress = 0.0,
    this.summaryMarkdown,
    this.errorMessage,
    this.wordCount = 500,
  });

  SummaryState copyWith({
    SummaryStatus? status,
    String? fileName,
    int? fileSizeBytes,
    double? uploadProgress,
    String? summaryMarkdown,
    String? errorMessage,
    int? wordCount,
  }) {
    return SummaryState(
      status: status ?? this.status,
      fileName: fileName ?? this.fileName,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      summaryMarkdown: summaryMarkdown ?? this.summaryMarkdown,
      errorMessage: errorMessage ?? this.errorMessage,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  /// Human-readable file size.
  String get fileSizeFormatted {
    if (fileSizeBytes == null) return '';
    final kb = fileSizeBytes! / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} KB';
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}

/// All possible states for the summary pipeline.
enum SummaryStatus {
  idle,       // No file selected
  selected,   // File selected, waiting to upload
  uploading,  // Upload in progress
  processing, // AI is generating the summary
  completed,  // Summary ready
  error,      // Something went wrong
}
