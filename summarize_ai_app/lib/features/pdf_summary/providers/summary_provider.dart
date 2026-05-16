import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/summary_state.dart';
import '../../../shared/mock_services/mock_summary_service.dart';

/// Provider for the summary feature state.
final summaryProvider =
    StateNotifierProvider<SummaryNotifier, SummaryState>((ref) {
  return SummaryNotifier();
});

/// Manages the full upload → process → result pipeline.
class SummaryNotifier extends StateNotifier<SummaryState> {
  SummaryNotifier() : super(const SummaryState());

  final MockSummaryService _service = MockSummaryService();
  Timer? _progressTimer;

  /// User selects a file (from picker or drag-and-drop).
  void selectFile(String fileName, int fileSizeBytes) {
    state = SummaryState(
      status: SummaryStatus.selected,
      fileName: fileName,
      fileSizeBytes: fileSizeBytes,
      wordCount: state.wordCount,
    );
  }

  /// Update desired word count for the summary.
  void setWordCount(int count) {
    state = state.copyWith(wordCount: count);
  }

  /// Clears the selected file / resets to idle.
  void clearFile() {
    _progressTimer?.cancel();
    state = const SummaryState();
  }

  /// Starts the full summarization pipeline:
  /// selected → uploading → processing → completed/error
  Future<void> startSummarization() async {
    if (state.fileName == null) return;

    try {
      // ── Phase 1: Upload ──────────────────────────────────────────
      state = state.copyWith(
        status: SummaryStatus.uploading,
        uploadProgress: 0.0,
      );

      // Simulate upload progress over ~2s
      _progressTimer?.cancel();
      final completer = Completer<void>();
      double progress = 0.0;
      _progressTimer = Timer.periodic(
        const Duration(milliseconds: 80),
        (timer) {
          progress += 0.04;
          if (progress >= 1.0) {
            progress = 1.0;
            timer.cancel();
            completer.complete();
          }
          state = state.copyWith(uploadProgress: progress);
        },
      );
      await completer.future;

      final uploadId = await _service.uploadPdf(state.fileName!);

      // ── Phase 2: Processing ──────────────────────────────────────
      state = state.copyWith(status: SummaryStatus.processing);

      final markdown = await _service.summarize(uploadId);

      // ── Phase 3: Done ────────────────────────────────────────────
      state = state.copyWith(
        status: SummaryStatus.completed,
        summaryMarkdown: markdown,
      );
    } catch (e) {
      state = state.copyWith(
        status: SummaryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Re-summarize the same file (skips upload, goes straight to processing).
  Future<void> resummarize() async {
    if (state.fileName == null) return;
    try {
      state = state.copyWith(
        status: SummaryStatus.processing,
        summaryMarkdown: null,
      );
      final markdown = await _service.summarize('re_summarize');
      state = state.copyWith(
        status: SummaryStatus.completed,
        summaryMarkdown: markdown,
      );
    } catch (e) {
      state = state.copyWith(
        status: SummaryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}
