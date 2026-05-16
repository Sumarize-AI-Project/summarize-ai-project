import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/chat_message.dart';
import '../../../shared/mock_services/mock_chat_service.dart';

/// Provider for the AI chat feature state.
final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});

/// Manages chat messages, AI response simulation, typing indicator.
class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier() : super(const ChatState()) {
    _loadInitialMessages();
  }

  final MockChatService _service = MockChatService();
  int _messageCounter = 0;

  void _loadInitialMessages() {
    final initial = _service.getInitialMessages();
    final messages = initial
        .map((m) => ChatMessage(
              id: m.id,
              content: m.content,
              isUser: m.isUser,
              timestamp: m.timestamp,
            ))
        .toList();
    state = state.copyWith(messages: messages);
  }

  /// Sends a user message and triggers an AI response.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

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

    try {
      // Wait for AI response
      final response = await _service.sendMessage(content);

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
    } catch (e) {
      state = state.copyWith(
        isAiTyping: false,
        errorMessage: 'Failed to get AI response. Please try again.',
      );
    }
  }

  /// Clears all messages and reloads the initial greeting.
  void clearChat() {
    _messageCounter = 0;
    _loadInitialMessages();
  }
}
