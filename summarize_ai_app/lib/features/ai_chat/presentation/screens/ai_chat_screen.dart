import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/typing_indicator.dart';
import '../widgets/chat_input_bar.dart';

/// Full-screen AI Chat — message list with auto-scroll, typing indicator, and fixed input.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Auto-scroll when messages change
    ref.listen(chatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isAiTyping != next.isAiTyping) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // ── Header ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.darkSurface,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Text('AI Chat', style: AppTextStyles.headlineSmall),
              const Spacer(),
              if (chatState.messages.length > 1)
                _ClearChatButton(
                  onTap: () => ref.read(chatProvider.notifier).clearChat(),
                ),
            ],
          ),
        ),

        // ── Messages List ──────────────────────────────────────
        Expanded(
          child: chatState.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: chatState.messages.length +
                      (chatState.isAiTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Typing indicator at the end
                    if (index == chatState.messages.length) {
                      return const TypingIndicator();
                    }
                    return ChatBubble(message: chatState.messages[index]);
                  },
                ),
        ),

        // ── Input Bar ──────────────────────────────────────────
        ChatInputBar(
          onSend: (text) => ref.read(chatProvider.notifier).sendMessage(text),
          enabled: !chatState.isAiTyping,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.chat_bubble_rounded,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(height: 16),
          Text('Start a conversation',
              style: AppTextStyles.headlineSmall),
          const SizedBox(height: 8),
          Text('Ask questions about your uploaded documents.',
              style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}

/// Clear chat button widget.
class _ClearChatButton extends StatefulWidget {
  const _ClearChatButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ClearChatButton> createState() => _ClearChatButtonState();
}

class _ClearChatButtonState extends State<_ClearChatButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _hovered
                ? AppColors.error.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _hovered
                  ? AppColors.error.withValues(alpha: 0.3)
                  : AppColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded,
                  size: 14,
                  color: _hovered ? AppColors.error : AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                'Clear',
                style: AppTextStyles.labelSmall.copyWith(
                  color: _hovered ? AppColors.error : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
