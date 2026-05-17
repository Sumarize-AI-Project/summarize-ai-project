/// A single chat message in the AI chat.
class ChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

/// State for the entire chat feature.
class ChatState {
  final List<ChatMessage> messages;
  final bool isAiTyping;
  final String? errorMessage;

  const ChatState({
    this.messages = const [],
    this.isAiTyping = false,
    this.errorMessage,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isAiTyping,
    String? errorMessage,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isAiTyping: isAiTyping ?? this.isAiTyping,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
