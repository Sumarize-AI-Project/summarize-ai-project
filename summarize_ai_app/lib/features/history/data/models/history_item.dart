import '../../../ai_chat/data/models/chat_message.dart';

/// Model for a work session — each uploaded PDF becomes a session
/// that groups the PDF, its summary, and any related chat messages.
class SessionItem {
  final String id;
  final String pdfName;
  final String pdfSize;
  final DateTime createdAt;
  final String? summaryMarkdown;
  final int? summaryWordCount;
  final List<ChatMessage> chatMessages;

  const SessionItem({
    required this.id,
    required this.pdfName,
    required this.pdfSize,
    required this.createdAt,
    this.summaryMarkdown,
    this.summaryWordCount,
    this.chatMessages = const [],
  });

  String? get summaryPreview => summaryMarkdown != null && summaryMarkdown!.length > 80
      ? '${summaryMarkdown!.substring(0, 80)}...'
      : summaryMarkdown;

  int get chatMessageCount => chatMessages.length;

  bool get hasSummary => summaryMarkdown != null && summaryMarkdown!.isNotEmpty;
  bool get hasChat => chatMessages.isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdfName': pdfName,
      'pdfSize': pdfSize,
      'createdAt': createdAt.toIso8601String(),
      'summaryMarkdown': summaryMarkdown,
      'summaryWordCount': summaryWordCount,
      'chatMessages': chatMessages.map((m) => m.toJson()).toList(),
    };
  }

  factory SessionItem.fromJson(Map<String, dynamic> json) {
    return SessionItem(
      id: json['id'] as String,
      pdfName: json['pdfName'] as String,
      pdfSize: json['pdfSize'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      summaryMarkdown: json['summaryMarkdown'] as String?,
      summaryWordCount: json['summaryWordCount'] as int?,
      chatMessages: (json['chatMessages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  SessionItem copyWith({
    String? id,
    String? pdfName,
    String? pdfSize,
    DateTime? createdAt,
    String? summaryMarkdown,
    int? summaryWordCount,
    List<ChatMessage>? chatMessages,
  }) {
    return SessionItem(
      id: id ?? this.id,
      pdfName: pdfName ?? this.pdfName,
      pdfSize: pdfSize ?? this.pdfSize,
      createdAt: createdAt ?? this.createdAt,
      summaryMarkdown: summaryMarkdown ?? this.summaryMarkdown,
      summaryWordCount: summaryWordCount ?? this.summaryWordCount,
      chatMessages: chatMessages ?? this.chatMessages,
    );
  }
}
