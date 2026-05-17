import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message.dart';
import '../../../../core/services/api_service.dart';
import '../../pdf_summary/providers/summary_provider.dart';
import '../../history/providers/history_provider.dart';

/// Provider for the AI chat feature state.
final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(ref);
});

/// Manages chat messages, AI response simulation, typing indicator.
class ChatNotifier extends StateNotifier<ChatState> {
  final Ref _ref;
  
  ChatNotifier(this._ref) : super(const ChatState()) {
    _loadInitialMessages();
  }

  int _messageCounter = 0;

  void _loadInitialMessages() {
    final messages = [
      ChatMessage(
        id: 'init_1',
        content: 'Xin chào! Tôi có thể giúp gì cho bạn với tài liệu này?',
        isUser: false,
        timestamp: DateTime.now(),
      )
    ];
    state = state.copyWith(messages: messages);
  }

  /// Restores chat messages for a saved session.
  void restoreChat(List<ChatMessage> messages) {
    if (messages.isEmpty) {
      _loadInitialMessages();
    } else {
      state = state.copyWith(
        messages: messages,
        isAiTyping: false,
        errorMessage: null,
      );
      _messageCounter = messages.length + 1;
    }
  }

  void _updateHistoryChat() {
    final sessionId = _ref.read(summaryProvider).sessionId;
    if (sessionId == null || sessionId.isEmpty) return;

    final historyState = _ref.read(historyProvider);
    final existingSessionIndex =
        historyState.allSessions.indexWhere((s) => s.id == sessionId);
    if (existingSessionIndex != -1) {
      final existingSession = historyState.allSessions[existingSessionIndex];
      final updatedSession = existingSession.copyWith(
        chatMessages: state.messages,
      );
      _ref.read(historyProvider.notifier).saveOrUpdateSession(updatedSession);
    }
  }

  /// Sends a user message and triggers an AI response.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Lấy sessionId từ màn hình tóm tắt
    final sessionId = _ref.read(summaryProvider).sessionId;

    // Add user message
    final userMsg = ChatMessage(
      id: 'msg_${++_messageCounter}',
      content: content.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isAiTyping: true,
      errorMessage: null,
    );
    _updateHistoryChat();

    if (sessionId == null || sessionId.isEmpty) {
      // Báo lỗi ngay nếu chưa có file
      final aiMsg = ChatMessage(
        id: 'msg_${++_messageCounter}',
        content: 'Vui lòng tóm tắt một tài liệu PDF trước khi bắt đầu chat nhé!',
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isAiTyping: false,
      );
      _updateHistoryChat();
      return;
    }

    try {
      // Gọi API Chat thật
      final response = await apiService.chatWithDocument(
        sessionId: sessionId,
        message: content,
      );

      // Add AI response
      final aiMsg = ChatMessage(
        id: 'msg_${++_messageCounter}',
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isAiTyping: false,
      );
      _updateHistoryChat();
    } catch (e) {
      state = state.copyWith(
        isAiTyping: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clears all messages and reloads the initial greeting.
  void clearChat() {
    _messageCounter = 0;
    _loadInitialMessages();
  }
}
