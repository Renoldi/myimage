import 'package:flutter/material.dart';
import 'package:myimage/models/myimage_result.dart';

class MyImageController extends ChangeNotifier {
  List<MyimageResult> _images = [];

  List<MyimageResult> get images => _images;

  set images(List<MyimageResult> value) {
    _images = value;
    notifyListeners();
  }

  void addImage(MyimageResult image) {
    _images.add(image);
    notifyListeners();
  }

  void clear() {
    _images.clear();
    notifyListeners();
  }
}
