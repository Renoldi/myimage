import 'dart:convert';
import 'dart:io';

class MyimageResult {
  final String? link;
  final String? base64;
  final String path;

  MyimageResult({this.link, this.base64, required this.path});

  @override
  String toString() {
    return 'MyimageResult(path: $path, link: $link, base64: ${base64 != null ? base64!.substring(0, 20) : 'null'})';
  }

  static Future<MyimageResult> fromFile(File file, {String? link}) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    return MyimageResult(link: link, base64: base64Str, path: file.path);
  }
}
