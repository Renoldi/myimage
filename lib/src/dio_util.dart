// ===================== Dio Utility =====================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Utility class for file upload and download using Dio.
class DioUtil {
  static final Logger _logger = Logger();

  /// Downloads a file from the given URL and saves it to a temp path.
  static Future<String?> downloadFile(String url) async {
    try {
      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      if (response.statusCode == 200) {
        final tempDir = Directory.systemTemp;
        final fileName = url.split('/').last;
        final file = File('${tempDir.path}/$fileName');
        await file.writeAsBytes(response.data);
        return file.path;
      }
    } catch (e) {
      _logger.e('DioUtil download error: $e');
    }
    return null;
  }

  /// Uploads a file to the given URL with optional headers and progress callback.
  static Future<Response?> uploadFile({
    required String url,
    required String filePath,
    String? filename,
    Map<String, String>? headers,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final dio = Dio();
      final file = File(filePath);
      final formData = FormData();
      formData.fields.add(MapEntry('reqtype', 'fileupload'));
      formData.files.add(
        MapEntry(
          'fileToUpload',
          await MultipartFile.fromFile(
            filePath,
            filename: filename ?? file.path.split('/').last,
          ),
        ),
      );
      final response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: headers,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 400,
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null) {
            onProgress(total > 0 ? sent / total : 0.0);
          }
        },
      );
      return response;
    } catch (e) {
      _logger.e('DioUtil upload error: $e');
      return null;
    }
  }
}
