import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../data/models/summary_state.dart';
import '../../../../core/services/api_service.dart';
import '../../history/providers/history_provider.dart';
import '../../history/data/models/history_item.dart';

/// Provider for the summary feature state.
final summaryProvider = StateNotifierProvider<SummaryNotifier, SummaryState>((
  ref,
) {
  return SummaryNotifier(ref);
});

/// Manages the full upload → process → result pipeline.
class SummaryNotifier extends StateNotifier<SummaryState> {
  final Ref _ref;

  SummaryNotifier(this._ref) : super(const SummaryState());

  Timer? _progressTimer;

  /// User selects a file (from picker or drag-and-drop).
  void selectFile(PlatformFile file) {
    state = SummaryState(
      status: SummaryStatus.selected,
      fileName: file.name,
      fileSizeBytes: file.size,
      wordCount: state.wordCount,
      platformFile: file,
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

  /// Restores a saved work session from local history.
  void restoreSession(SessionItem session) {
    _progressTimer?.cancel();
    state = SummaryState(
      status: SummaryStatus.completed,
      fileName: session.pdfName,
      fileSizeBytes: null,
      uploadProgress: 1.0,
      summaryMarkdown: session.summaryMarkdown,
      errorMessage: null,
      wordCount: session.summaryWordCount ?? 500,
      platformFile: null,
      sessionId: session.id,
    );
  }

  /// Starts the full summarization pipeline:
  /// selected → uploading → processing → completed/error
  Future<void> startSummarization() async {
    if (state.platformFile == null) return;

    try {
      // ── Phase 1: Upload & Process (API does both) ──────────────────────────────────────────
      state = state.copyWith(
        status: SummaryStatus.uploading,
        uploadProgress: 0.0,
      );

      // Simulate upload progress while waiting for API (since API handles both)
      _progressTimer?.cancel();
      double progress = 0.0;
      _progressTimer = Timer.periodic(const Duration(milliseconds: 300), (
        timer,
      ) {
        if (progress < 0.9) {
          progress += 0.05;
          state = state.copyWith(uploadProgress: progress);
        }
      });

      // Gọi API thực tế
      final result = await apiService.summarizePdf(
        file: state.platformFile!,
        targetWords: state.wordCount,
      );

      _progressTimer?.cancel();

      // ── Phase 3: Done ────────────────────────────────────────────
      state = state.copyWith(
        status: SummaryStatus.completed,
        summaryMarkdown: result['summary'] as String?,
        sessionId: result['session_id'] as String?,
      );

      // Save new summary to local history
      final sessionId = result['session_id'] as String?;
      if (sessionId != null) {
        final session = SessionItem(
          id: sessionId,
          pdfName: state.fileName ?? 'Unnamed PDF',
          pdfSize: state.fileSizeFormatted,
          createdAt: DateTime.now(),
          summaryMarkdown: result['summary'] as String?,
          summaryWordCount: state.wordCount,
          chatMessages: const [],
        );
        _ref.read(historyProvider.notifier).saveOrUpdateSession(session);
      }
    } catch (e) {
      _progressTimer?.cancel();
      state = state.copyWith(
        status: SummaryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Re-summarize the same file.
  Future<void> resummarize() async {
    if (state.platformFile == null) return;
    try {
      state = state.copyWith(
        status: SummaryStatus.processing,
        summaryMarkdown: null,
      );

      final result = await apiService.summarizePdf(
        file: state.platformFile!,
        targetWords: state.wordCount,
      );

      state = state.copyWith(
        status: SummaryStatus.completed,
        summaryMarkdown: result['summary'] as String?,
        sessionId: result['session_id'] as String?,
      );

      // Save updated summary to local history
      final sessionId = result['session_id'] as String?;
      if (sessionId != null) {
        final session = SessionItem(
          id: sessionId,
          pdfName: state.fileName ?? 'Unnamed PDF',
          pdfSize: state.fileSizeFormatted,
          createdAt: DateTime.now(),
          summaryMarkdown: result['summary'] as String?,
          summaryWordCount: state.wordCount,
          chatMessages: const [],
        );
        _ref.read(historyProvider.notifier).saveOrUpdateSession(session);
      }
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
