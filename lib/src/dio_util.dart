// ===================== Dio Utility =====================

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Utility class for file upload and download using Dio.
class DioUtil {
  /// Generic request wrapper to handle DioException globally.
  static Future<T?> safeRequest<T>(
    Future<T> Function() request, {
    String? url,
  }) async {
    try {
      return await request();
    } on DioException catch (e) {
      _logger.e('DioUtil DioException: $e', error: e, stackTrace: e.stackTrace);
      if (T == Response) {
        return (e.response ??
                Response(
                  requestOptions: RequestOptions(path: url ?? ''),
                  statusCode: 500,
                  statusMessage:
                      'Network/server error. Please try again later.',
                  data: {
                    'errorType': e.type.toString(),
                    'errorMessage': e.message,
                  },
                ))
            as T;
      }
      return null;
    } catch (e, stack) {
      _logger.e('DioUtil error: $e', error: e, stackTrace: stack);
      if (T == Response) {
        return Response(
              requestOptions: RequestOptions(path: url ?? ''),
              statusCode: 500,
              statusMessage: 'Network/server error. Please try again later.',
              data: {'errorType': 'Unknown', 'errorMessage': e.toString()},
            )
            as T;
      }
      return null;
    }
  }

  static final Dio _dio = Dio();

  static final Logger _logger = Logger();

  /// Downloads a file from the given URL and saves it to a temp path.
  static Future<String?> downloadFile(String url) async {
    final response = await safeRequest<Response>(
      () => _dio.get(url, options: Options(responseType: ResponseType.bytes)),
      url: url,
    );
    if (response != null && response.statusCode == 200) {
      final tempDir = Directory.systemTemp;
      final fileName = url.split('/').last;
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(response.data);
      return file.path;
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
    return await safeRequest<Response>(
      () => _dio.post(
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
      ),
      url: url,
    );
  }
}
