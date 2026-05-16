import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../data/models/chat_message.dart';

/// A single chat bubble — user on right (green), AI on left (dark).
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AI Avatar (left) ──────────────────────────────────
              if (!isUser) ...[_buildAvatar(isUser), const SizedBox(width: 10)],

              // ── Bubble ────────────────────────────────────────────
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.userBubble : AppColors.aiBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textOnPrimary,
                            height: 1.5,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          selectable: true,
                          styleSheet: _aiMarkdownStyle,
                        ),
                ),
              ),

              // ── User Avatar (right) ───────────────────────────────
              if (isUser) ...[const SizedBox(width: 10), _buildAvatar(isUser)],
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(
          begin: isUser ? 0.05 : -0.05,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildAvatar(bool isUser) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isUser
            ? AppColors.primary.withValues(alpha: 0.15)
            : AppColors.darkElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isUser
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Icon(
        isUser ? Icons.person_rounded : Icons.auto_awesome,
        color: isUser ? AppColors.primary : AppColors.primary,
        size: 16,
      ),
    );
  }

  static final MarkdownStyleSheet _aiMarkdownStyle = MarkdownStyleSheet(
    p: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textPrimary,
      height: 1.6,
    ),
    strong: AppTextStyles.bodyMedium.copyWith(
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    em: AppTextStyles.bodyMedium.copyWith(
      fontStyle: FontStyle.italic,
      color: AppColors.textPrimary,
    ),
    listBullet: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
    code: GoogleFonts.firaCode(
      fontSize: 12,
      color: AppColors.primary,
      backgroundColor: AppColors.darkBg,
    ),
    blockquote: AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textSecondary,
      fontStyle: FontStyle.italic,
    ),
    blockquoteDecoration: BoxDecoration(
      border: Border(
        left: BorderSide(
          color: AppColors.primary.withValues(alpha: 0.4),
          width: 3,
        ),
      ),
    ),
    h1: AppTextStyles.headlineSmall,
    h2: AppTextStyles.labelLarge.copyWith(fontSize: 16),
    h3: AppTextStyles.labelLarge,
  );
}
