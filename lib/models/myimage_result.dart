import 'dart:convert';
import 'dart:io';

class MyimageResult {
  final String link;
  final String base64;
  final String path;

  MyimageResult({this.link = "", this.base64 = "", this.path = ""});
  @override
  String toString() {
    return 'MyimageResult(path: $path, link: $link, base64: ${base64.substring(0, 20)})';
  }

  static Future<MyimageResult> fromFile(File file, {String? link}) async {
    final bytes = await file.readAsBytes();
    final base64Raw = base64Encode(bytes);
    final mime = getMimeType(file.path);
    final base64Str = 'data:$mime;base64,$base64Raw';
    return MyimageResult(link: link ?? "", base64: base64Str, path: file.path);
  }

  /// Returns the MIME type based on file extension.
  static String getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'bmp':
        return 'image/bmp';
      case 'webp':
        return 'image/webp';
      case 'svg':
        return 'image/svg+xml';
      case 'heic':
        return 'image/heic';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}
