import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:myimage/src/controllers/myimage_controller.dart';
import 'package:myimage/src/dio_util.dart';
import 'package:myimage/models/myimage_result.dart';
import 'package:provider/provider.dart';
import '../providers/myimage_provider.dart';

class MyImage extends StatefulWidget {
  final MyImageController? controller;

  /// Callback untuk perubahan daftar gambar (multi-image, kompatibilitas lama)
  final void Function(List<MyimageResult> results)? onImagesChanged;

  /// Callback untuk perubahan gambar pada mode single image (maxImages == 1)
  /// Dipanggil setiap kali gambar dipilih atau diganti.
  final void Function(MyimageResult image)? onImageChanged;
  final String? label;
  final bool isDoc;
  final int? maxImages;
  final Widget Function(BuildContext context, MyimageResult image, int index)?
  imageBuilder;
  final Widget Function(BuildContext context, int index, MyimageResult image)?
  removeIconBuilder;

  /// Callback saat gambar dihapus.
  /// Pada mode single image, index selalu 0.
  final void Function(int index, MyimageResult image)? onRemoveImage;
  final Widget Function(BuildContext context)? plusBuilder;
  final String? uploadUrl;
  final String? uploadToken;
  final bool isDirectUpload;
  // Customizable upload messages
  final String uploadSuccessMessage;
  final String uploadFailedMessage;
  final String uploadErrorMessage;

  final bool allow;

  MyImage({
    super.key,
    this.controller,
    this.onImagesChanged,
    this.onImageChanged,
    this.label,
    this.isDoc = false,
    this.maxImages,
    this.imageBuilder,
    this.onRemoveImage,
    this.plusBuilder,
    this.removeIconBuilder,
    this.uploadUrl,
    this.uploadToken,
    this.isDirectUpload = false,
    this.uploadSuccessMessage = 'Upload successful!',
    this.uploadFailedMessage = 'Upload failed:',
    this.uploadErrorMessage = 'Upload error:',
    this.allow = true,
  }) {
    assert(
      isDirectUpload == false || (uploadUrl != null && uploadUrl!.isNotEmpty),
      "For direct upload, uploadUrl must be provided and non-empty.",
    );
  }

  @override
  State<MyImage> createState() => _MyImageState();
}

class _MyImageState extends State<MyImage> {
  late MyimageProvider _provider;
  int? _uploadingIndex;
  MyImageController? _controller;

  @override
  void initState() {
    super.initState();
    _provider = MyimageProvider();
    if (widget.controller != null) {
      _controller = widget.controller;
      _provider.setImages(_controller!.images);
      _controller!.addListener(_onControllerChanged);
    } else {
      _controller = MyImageController();
      _provider.setImages(_controller!.images);
      _controller!.addListener(_onControllerChanged);
    }
    _uploadingIndex = null;
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (_controller != null) {
      setState(() {
        _provider.setImages(_controller!.images);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<MyimageProvider>(
        builder: (context, provider, _) {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.maxImages == 1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: _buildSingleImageWidget(context, provider),
                  ),
                if (widget.maxImages != 1)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _buildMultiImageWidgets(context, provider),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleImageWidget(
    BuildContext context,
    MyimageProvider provider,
  ) {
    final hasImage = provider.images.isNotEmpty;
    return Stack(
      children: [
        GestureDetector(
          onTap: widget.allow ? () => _pickImage(context, provider) : null,
          child: Stack(
            key: ValueKey(
              provider.uploadProgress.isNotEmpty
                  ? provider.uploadProgress[0]
                  : 0.0,
            ),
            alignment: Alignment.center,
            children: [
              _buildImageDisplay(
                context,
                hasImage ? provider.images[0] : null,
                0,
                isSingle: true,
              ),
              if (hasImage &&
                  provider.uploadProgress.isNotEmpty &&
                  provider.uploadProgress[0] > 0.0 &&
                  provider.uploadProgress[0] < 1.0 &&
                  !widget.isDirectUpload)
                Positioned(
                  top: 2,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: 96,
                    height: 24,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.35),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.deepOrange, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: LinearProgressIndicator(
                      value: provider.uploadProgress[0],
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.deepOrange,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (hasImage)
          Positioned(
            top: 0,
            right: 0,
            child: _buildRemoveButton(context, 0, provider.images[0], () {
              final removed = provider.images[0];
              provider.removeImage(0);
              // Panggil onRemoveImage lebih awal
              widget.onRemoveImage?.call(0, removed);
              // Sinkronkan controller eksternal jika ada
              if (widget.controller != null) {
                widget.controller!.images = List<MyimageResult>.from(
                  provider.images,
                );
              }
              widget.onImagesChanged?.call(
                List<MyimageResult>.from(provider.images),
              );
              widget.onImageChanged?.call(MyimageResult());
            }),
          ),
      ],
    );
  }

  Widget _buildImageDisplay(
    BuildContext context,
    MyimageResult? image,
    int index, {
    bool isSingle = false,
  }) {
    if (image == null) {
      if (widget.imageBuilder != null) {
        return SizedBox(
          width: 120,
          height: 120,
          child: widget.imageBuilder!(context, MyimageResult(), index),
        );
      }
      if (!widget.isDirectUpload) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 48,
                color: Colors.grey,
              ),
            ),
          ),
        );
      }
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 60, color: Colors.grey),
            Icon(Icons.camera_alt, size: 24, color: Colors.black54),
          ],
        ),
      );
    }
    if (widget.imageBuilder != null) {
      return SizedBox(
        width: 120,
        height: 120,
        child: widget.imageBuilder!(context, image, index),
      );
    }
    if (image.link.isNotEmpty) {
      return CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade300,
        backgroundImage: NetworkImage(image.link),
      );
    }
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade300,
      backgroundImage: FileImage(File(image.path)),
    );
  }

  Widget _buildRemoveButton(
    BuildContext context,
    int index,
    MyimageResult image,
    VoidCallback onRemove,
  ) {
    if (widget.removeIconBuilder != null) {
      return GestureDetector(
        onTap: onRemove,
        child: widget.removeIconBuilder!(context, index, image),
      );
    }
    return IconButton(
      icon: const Icon(Icons.close, color: Colors.red),
      onPressed: onRemove,
    );
  }

  List<Widget> _buildMultiImageWidgets(
    BuildContext context,
    MyimageProvider provider,
  ) {
    final images = provider.images;
    final uploadProgress = provider.uploadProgress;
    final widgets = <Widget>[];
    final max = widget.maxImages ?? images.length + 1;
    for (int idx = 0; idx < max; idx++) {
      if (idx < images.length) {
        widgets.add(
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: _buildImageDisplay(context, images[idx], idx),
                ),
              ),
              if (images.isNotEmpty &&
                  uploadProgress.length > idx &&
                  uploadProgress[idx] < 1 &&
                  widget.isDirectUpload &&
                  _uploadingIndex == idx)
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.deepOrange, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black38,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: LinearProgressIndicator(
                        value: uploadProgress[idx],
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.deepOrange,
                        ),
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 0,
                right: 0,
                child: _buildRemoveButton(context, idx, images[idx], () {
                  provider.removeImage(idx);
                  if (widget.controller != null) {
                    widget.controller!.images = List<MyimageResult>.from(
                      provider.images,
                    );
                  }
                  widget.onImagesChanged?.call(
                    List<MyimageResult>.from(provider.images),
                  );
                }),
              ),
            ],
          ),
        );
      } else {
        widgets.add(
          GestureDetector(
            onTap: widget.allow ? () => _pickImage(context, provider) : null,
            child: widget.plusBuilder != null
                ? widget.plusBuilder!(context)
                : Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[100],
                    ),
                    child: const Center(
                      child: Icon(Icons.add, color: Colors.blue, size: 32),
                    ),
                  ),
          ),
        );
      }
    }
    return widgets;
  }

  Future<void> _pickImage(
    BuildContext context,
    MyimageProvider provider,
  ) async {
    final mountedBeforeDialog = mounted;
    final messenger = mountedBeforeDialog
        ? ScaffoldMessenger.of(context)
        : null;
    File? file;
    String? source;
    // If isDoc, call CunningDocumentScanner directly
    if (widget.isDoc) {
      final scanned = await CunningDocumentScanner.getPictures(
        isGalleryImportAllowed: true,
        noOfPages: 1,
        iosScannerOptions: IosScannerOptions(
          imageFormat: IosImageFormat.jpg,
          jpgCompressionQuality: 0.5,
        ),
      );
      if (!mounted) return;
      if (scanned != null && scanned.isNotEmpty) {
        file = File(scanned.first);
      }
    } else {
      source = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (dialogContext) {
          return ClipRRect(
            // borderRadius: const BorderRadius.vertical(
            //   top: Radius.circular(16),
            // ),
            child: Material(
              color: Colors.transparent,
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext, 'camera'),
                      child: Container(
                        margin: const EdgeInsets.only(right: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogContext, 'gallery'),
                      child: Container(
                        margin: const EdgeInsets.only(left: 24),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: const Icon(
                          Icons.photo_library,
                          size: 32,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
      if (!mounted) return;
      if (source == null) return;
      if (source == 'camera' || source == 'gallery') {
        final picker = ImagePicker();
        final picked = await picker.pickImage(
          source: source == 'camera' ? ImageSource.camera : ImageSource.gallery,
        );
        if (!mounted) return;
        if (picked != null) {
          file = File(picked.path);
        }
      }
    }
    if (!mounted) return;
    if (file != null) {
      final result = await MyimageResult.fromFile(file);
      if (!mounted) return;
      int? uploadIdx;
      if (widget.maxImages == 1) {
        bool isNew =
            provider.images.isEmpty || provider.images[0].path != result.path;
        provider.clearImages();
        provider.addImage(result);
        uploadIdx = 0;
        if (isNew) {
          provider.setUploadProgress(0, 0.0);
        }
        // Pastikan controller eksternal sinkron sebelum callback
        if (widget.controller != null) {
          widget.controller!.images = List<MyimageResult>.from(provider.images);
        }
        // Callback khusus single image
        widget.onImagesChanged?.call(List<MyimageResult>.from(provider.images));
        widget.onImageChanged?.call(result);
      } else if (widget.maxImages == null) {
        provider.addImage(result);
        uploadIdx = provider.images.length - 1;
        if (provider.uploadProgress.length < provider.images.length) {
          provider.setUploadProgress(provider.images.length - 1, 0.0);
        }
        if (widget.controller != null) {
          widget.controller!.images = List<MyimageResult>.from(provider.images);
        }
        widget.onImagesChanged?.call(List<MyimageResult>.from(provider.images));
      } else {
        if (provider.images.length < widget.maxImages!) {
          provider.addImage(result);
          uploadIdx = provider.images.length - 1;
          if (provider.uploadProgress.length < provider.images.length) {
            provider.setUploadProgress(provider.images.length - 1, 0.0);
          }
          if (widget.controller != null) {
            widget.controller!.images = List<MyimageResult>.from(
              provider.images,
            );
          }
          widget.onImagesChanged?.call(
            List<MyimageResult>.from(provider.images),
          );
        }
      }
      if (widget.isDirectUpload && uploadIdx != null) {
        _uploadingIndex = uploadIdx;
        provider.commit();
        await _uploadImageDio(messenger, provider, result, uploadIdx);
        if (!mounted) return;
        _uploadingIndex = null;
        provider.commit();
      }
    }
  }

  Future<void> _uploadImageDio(
    ScaffoldMessengerState? messenger,
    MyimageProvider provider,
    MyimageResult image, [
    int? idx,
  ]) async {
    if (widget.uploadUrl == null) return;
    final images = provider.images;
    final index = idx ?? images.indexOf(image);
    if (index < 0) return;
    provider.setUploadProgress(index, 0.0);
    final headers = <String, String>{};
    if (widget.uploadToken != null && widget.uploadToken!.isNotEmpty) {
      headers['Authorization'] = widget.uploadToken!;
    }
    final response = await DioUtil.uploadFile(
      url: widget.uploadUrl!,
      filePath: image.path,
      filename: File(image.path).path.split('/').last,
      headers: headers,
      onProgress: (progress) {
        provider.setUploadProgress(index, progress);
      },
    );
    if (!mounted) return;
    if (response == null) {
      messenger?.showSnackBar(
        SnackBar(content: Text(widget.uploadErrorMessage)),
      );
      return;
    }
    try {
      if (response.statusCode == 200) {
        String? uploadedLink;
        String? downloadedPath;
        final data = response.data;
        if (data is String) {
          final html = data;
          final redirectRegex = RegExp(
            r"redirect_link\s*=\s*'([^']+)'",
            multiLine: true,
          );
          final match = redirectRegex.firstMatch(html);
          if (match != null) {
            uploadedLink = match.group(1);
          } else {
            uploadedLink = html;
          }
        } else if (data is Map) {
          uploadedLink = data['url'] as String?;
        }
        if ((uploadedLink ?? '').isNotEmpty) {
          downloadedPath = await DioUtil.downloadFile(uploadedLink!);
        }
        provider.updateImage(
          index,
          MyimageResult(
            link: uploadedLink ?? images[index].link,
            base64: images[index].base64,
            path: downloadedPath ?? images[index].path,
          ),
        );
        provider.setUploadProgress(index, 1.0);
        widget.onImagesChanged?.call(List<MyimageResult>.from(provider.images));
        messenger?.showSnackBar(
          SnackBar(content: Text(widget.uploadSuccessMessage)),
        );
      } else {
        messenger?.showSnackBar(
          SnackBar(
            content: Text(
              '${widget.uploadFailedMessage} ${response.statusMessage ?? ''} ',
            ),
          ),
        );
      }
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(content: Text('${widget.uploadErrorMessage} $e')),
      );
    }
  }
}
