import 'dart:math';
import '../../core/constants/app_constants.dart';

/// Mock AI chat service for UI development.
/// Will be replaced with real RAG-based chat backend later.
class MockChatService {
  final _random = Random();

  /// Simulates sending a message to the AI and receiving a response.
  Future<String> sendMessage(String userMessage) async {
    // Simulate AI processing time (1-3 seconds)
    await Future.delayed(Duration(
      milliseconds: 1000 + _random.nextInt(2000),
    ));
    return _mockResponses[_random.nextInt(_mockResponses.length)];
  }

  /// Returns mock initial chat messages.
  List<MockChatMessage> getInitialMessages() {
    return [
      MockChatMessage(
        id: 'msg_0',
        content:
            'Hello! I\'m your AI assistant. I can help you understand the content of your uploaded PDF documents. Feel free to ask me any questions about the document.',
        isUser: false,
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }

  /// Returns mock chat history list.
  Future<List<MockChatSession>> getChatHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    return List.generate(
      AppConstants.mockChatMessageCount,
      (i) => MockChatSession(
        id: 'chat_$i',
        title: 'Chat about Document ${i + 1}',
        lastMessage: 'What are the key findings?',
        messageCount: 5 + i * 2,
        lastAccessedAt: DateTime.now().subtract(Duration(hours: i * 6)),
      ),
    );
  }
}

/// Model for a chat message.
class MockChatMessage {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;

  const MockChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
  });
}

/// Model for a chat session in history.
class MockChatSession {
  final String id;
  final String title;
  final String lastMessage;
  final int messageCount;
  final DateTime lastAccessedAt;

  const MockChatSession({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.messageCount,
    required this.lastAccessedAt,
  });
}

/// Pool of mock AI responses for realistic chat simulation.
const List<String> _mockResponses = [
  '''Based on the document analysis, here are the **key findings**:

1. The study identified three major trends in the industry
2. Revenue growth averaged **15% year-over-year**
3. Customer satisfaction scores improved by 23%

Would you like me to elaborate on any of these points?''',
  '''The document discusses several important methodologies:

- **Quantitative Analysis**: Statistical methods applied to large datasets
- **Qualitative Research**: In-depth interviews and case studies
- **Mixed Methods**: Combining both approaches for comprehensive insights

The authors recommend using a mixed-methods approach for best results.''',
  '''According to the document, the main conclusions are:

> "The findings suggest that implementing AI-driven solutions can significantly improve operational efficiency while reducing costs by up to 40%."

This aligns with recent industry reports that highlight the growing importance of AI adoption.''',
  '''Here's a summary of the **methodology** section:

1. Data was collected from 500+ participants
2. Analysis was performed using state-of-the-art ML models
3. Results were validated through cross-validation techniques
4. Statistical significance was established at p < 0.05

The methodology appears robust and well-documented.''',
  '''The document provides the following **recommendations**:

- Invest in AI training and education for staff
- Implement gradual automation of routine tasks
- Monitor KPIs regularly to measure ROI
- Consider ethical implications of AI deployment

These recommendations are practical and actionable.''',
];
