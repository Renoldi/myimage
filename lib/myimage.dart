import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'permission_gate.dart';

/// Result returned by Myimage widget callbacks.
class MyimageResult {
  final String? link;
  final String? base64;
  final String path;

  MyimageResult({this.link, this.base64, required this.path});

  /// Create a result from a file.
  static Future<MyimageResult> fromFile(File file, {String? link}) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    return MyimageResult(link: link, base64: base64Str, path: file.path);
  }
}

/// A widget that allows picking an image from camera, gallery, or scanning a document.
///
/// ## Example: Profile Image Picker
///
/// ```dart
/// Myimage(
///   label: 'Upload your profile picture:',
///   onFilePicked: (file) {
///     // Handle the selected file (e.g., upload or display)
///   },
/// )
/// ```

class Myimage extends StatelessWidget {
  final List<MyimageResult>? images;
  final void Function(List<MyimageResult> results)? onImagesChanged;
  final String? label;
  final bool isDoc;
  final int? maxImages;
  final Widget Function(BuildContext context, MyimageResult image, int index)?
  imageBuilder;
  final Widget Function(BuildContext context, int index, MyimageResult image)?
  removeIconBuilder;
  final void Function(int index, MyimageResult image)? onRemoveImage;
  final Widget Function(BuildContext context)? plusBuilder;

  const Myimage({
    super.key,
    this.images,
    this.onImagesChanged,
    this.label,
    this.isDoc = false,
    this.maxImages,
    this.imageBuilder,
    this.onRemoveImage,
    this.plusBuilder,
    this.removeIconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return PermissionGate(
      child: _MyimageInner(
        images: images,
        onImagesChanged: onImagesChanged,
        label: label,
        isDoc: isDoc,
        maxImages: maxImages,
        imageBuilder: imageBuilder,
        onRemoveImage: onRemoveImage,
        plusBuilder: plusBuilder,
        removeIconBuilder: removeIconBuilder,
      ),
    );
  }
}

class _MyimageInner extends StatefulWidget {
  final List<MyimageResult>? images;
  final void Function(List<MyimageResult> results)? onImagesChanged;
  final String? label;
  final bool isDoc;
  final int? maxImages;
  final Widget Function(BuildContext context, MyimageResult image, int index)?
  imageBuilder;
  final Widget Function(BuildContext context, int index, MyimageResult image)?
  removeIconBuilder;
  final void Function(int index, MyimageResult image)? onRemoveImage;
  final Widget Function(BuildContext context)? plusBuilder;

  const _MyimageInner({
    this.images,
    this.onImagesChanged,
    this.label,
    this.isDoc = false,
    this.maxImages,
    this.imageBuilder,
    this.onRemoveImage,
    this.plusBuilder,
    this.removeIconBuilder,
  });

  @override
  State<_MyimageInner> createState() => _MyimageInnerState();
}

class _MyimageInnerState extends State<_MyimageInner> {
  List<MyimageResult> _images = [];
  @override
  void didUpdateWidget(covariant _MyimageInner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.images != null && widget.images != oldWidget.images) {
      _images = List<MyimageResult>.from(widget.images!);
    }
  }

  bool _loading = false;

  Future<void> _pickImage() async {
    final source = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.maxImages == 1 ? 'Select Image' : 'Add Image'),
        content: const Text('Select source'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'camera'),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'gallery'),
            child: const Text('Gallery'),
          ),
          if (widget.isDoc)
            TextButton(
              onPressed: () => Navigator.pop(context, 'doc'),
              child: const Text('Document'),
            ),
        ],
      ),
    );
    if (source == null) return;
    setState(() => _loading = true);
    File? file;
    if (source == 'camera' || source == 'gallery') {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
      );
      if (picked != null) {
        file = File(picked.path);
      }
    } else if (source == 'doc') {
      final scanned = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
        noOfPages: 1,
      );
      if (scanned != null && scanned.isNotEmpty) {
        file = File(scanned.first);
      }
    }
    setState(() => _loading = false);
    if (!mounted) return;
    if (file != null) {
      final result = await MyimageResult.fromFile(file);
      setState(() {
        if (widget.maxImages == 1) {
          _images
            ..clear()
            ..add(result);
        } else if (widget.maxImages == null) {
          _images.add(result);
        } else {
          if (_images.length < widget.maxImages!) {
            _images.add(result);
          }
        }
      });
      if (widget.onImagesChanged != null) {
        widget.onImagesChanged!(_images);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.maxImages == 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: GestureDetector(
                onTap: _pickImage,
                child: _images.isEmpty
                    ? (widget.imageBuilder != null
                          ? widget.imageBuilder!(
                              context,
                              MyimageResult(path: '', base64: null, link: null),
                              0,
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                  Icon(
                                    Icons.camera_alt,
                                    size: 24,
                                    color: Colors.black54,
                                  ),
                                ],
                              ),
                            ))
                    : (widget.imageBuilder != null
                          ? widget.imageBuilder!(context, _images[0], 0)
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey.shade300,
                              backgroundImage: FileImage(File(_images[0].path)),
                            )),
              ),
            ),
          if (widget.maxImages != 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.maxImages == null
                      ? List.generate(_images.length + 1, (idx) {
                          if (idx < _images.length) {
                            final result = _images[idx];
                            if (widget.imageBuilder != null) {
                              return widget.imageBuilder!(context, result, idx);
                            }
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(result.path),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: widget.removeIconBuilder != null
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _images.removeAt(idx);
                                              widget.onImagesChanged?.call(
                                                _images,
                                              );
                                            });
                                          },
                                          child: widget.removeIconBuilder!(
                                            context,
                                            idx,
                                            result,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _images.removeAt(idx);
                                              widget.onImagesChanged?.call(
                                                _images,
                                              );
                                            });
                                          },
                                        ),
                                ),
                              ],
                            );
                          } else {
                            // Empty slot: show plus button
                            return GestureDetector(
                              onTap: _pickImage,
                              child: widget.plusBuilder != null
                                  ? widget.plusBuilder!(context)
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[100],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                            );
                          }
                        })
                      : List.generate(widget.maxImages!, (idx) {
                          if (idx < _images.length) {
                            final result = _images[idx];
                            if (widget.imageBuilder != null) {
                              return widget.imageBuilder!(context, result, idx);
                            }
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(result.path),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: widget.removeIconBuilder != null
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _images.removeAt(idx);
                                              widget.onImagesChanged?.call(
                                                _images,
                                              );
                                            });
                                          },
                                          child: widget.removeIconBuilder!(
                                            context,
                                            idx,
                                            result,
                                          ),
                                        )
                                      : IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _images.removeAt(idx);
                                              widget.onImagesChanged?.call(
                                                _images,
                                              );
                                            });
                                          },
                                        ),
                                ),
                              ],
                            );
                          } else {
                            // Empty slot: show plus button
                            return GestureDetector(
                              onTap: _pickImage,
                              child: widget.plusBuilder != null
                                  ? widget.plusBuilder!(context)
                                  : Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.blue,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[100],
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.add,
                                          color: Colors.blue,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                            );
                          }
                        }),
                ),
              ],
            ),
          if (_loading)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
