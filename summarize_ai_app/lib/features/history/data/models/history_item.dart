// ignore: unused_import
import 'package:flutter/material.dart';

/// Model for a work session — each uploaded PDF becomes a session
/// that groups the PDF, its summary, and any related chat messages.
class SessionItem {
  final String id;
  final String pdfName;
  final String pdfSize;
  final DateTime createdAt;
  final String? summaryPreview;   // First ~80 chars of summary, null if not yet summarized
  final int? summaryWordCount;
  final int chatMessageCount;     // 0 if no chat

  const SessionItem({
    required this.id,
    required this.pdfName,
    required this.pdfSize,
    required this.createdAt,
    this.summaryPreview,
    this.summaryWordCount,
    this.chatMessageCount = 0,
  });

  bool get hasSummary => summaryPreview != null;
  bool get hasChat => chatMessageCount > 0;
}
