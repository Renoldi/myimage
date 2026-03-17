import 'package:flutter/material.dart';
import 'myimage.dart';

class MyimageProvider extends ChangeNotifier {
  List<MyimageResult> _images = [];

  List<MyimageResult> get images => _images;

  void setImages(List<MyimageResult> images) {
    _images = List<MyimageResult>.from(images);
    notifyListeners();
  }

  void addImage(MyimageResult image) {
    _images.add(image);
    notifyListeners();
  }

  void removeImage(int idx) {
    _images.removeAt(idx);
    notifyListeners();
  }

  void clearImages() {
    _images.clear();
    notifyListeners();
  }
}
