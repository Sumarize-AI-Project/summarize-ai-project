import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // Đã cập nhật IP LAN máy tính của bạn (192.168.0.102) để điện thoại thật có thể kết nối được
  static const String baseUrl = 'http://192.168.0.102:8000/api';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(
        seconds: 150,
      ), // Tóm tắt có thể mất nhiều thời gian
      receiveTimeout: const Duration(seconds: 150),
    ),
  );

  /// Gọi API Tóm tắt PDF
  /// Trả về một Map chứa: summary, word_count, processing_time, và session_id
  Future<Map<String, dynamic>> summarizePdf({
    required PlatformFile file,
    int targetWords = 500,
    String mode = 'polished',
  }) async {
    try {
      FormData formData;

      // Xử lý file cho Web và các nền tảng khác
      if (kIsWeb) {
        formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
          'target_words': targetWords,
          'mode': mode,
        });
      } else {
        formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path!, filename: file.name),
          'target_words': targetWords,
          'mode': mode,
        });
      }

      final response = await _dio.post('/summarize', data: formData);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      debugPrint("Lỗi gọi API Summarize: \${e.message}");
      if (e.response != null) {
        throw Exception(
          e.response?.data['detail'] ??
              "Lỗi máy chủ: \${e.response?.statusCode}",
        );
      }
      throw Exception(
        "Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.",
      );
    } catch (e) {
      throw Exception("Lỗi không xác định: \$e");
    }
  }

  /// Gọi API Chat với tài liệu
  Future<String> chatWithDocument({
    required String sessionId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {'session_id': sessionId, 'message': message},
      );
      return response.data['reply'] as String;
    } on DioException catch (e) {
      debugPrint("Lỗi gọi API Chat: \${e.message}");
      if (e.response != null) {
        throw Exception(
          e.response?.data['detail'] ??
              "Lỗi máy chủ: \${e.response?.statusCode}",
        );
      }
      throw Exception("Không thể kết nối đến máy chủ.");
    } catch (e) {
      throw Exception("Lỗi không xác định: \$e");
    }
  }
}

// Khởi tạo một instance toàn cục để dùng chung
final apiService = ApiService();
