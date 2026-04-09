import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myimage/myimage.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  runApp(MyimageExampleApp());
}

class MyimageExampleApp extends StatelessWidget {
  const MyimageExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Myimage Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Profile & Multi Image Picker')),
        body: const Padding(padding: EdgeInsets.all(16), child: MyimageDemo()),
      ),
    );
  }
}

class MyimageDemo extends StatefulWidget {
  const MyimageDemo({super.key});

  @override
  State<MyimageDemo> createState() => _MyimageDemoState();
}

class _MyimageDemoState extends State<MyimageDemo> {
  // Controller for network image demo
  final MyImageController _networkImagesController = MyImageController()
    ..images = [
      MyimageResult(path: '', base64: "", link: 'https://picsum.photos/150'),
      MyimageResult(path: '', base64: "", link: 'https://picsum.photos/200'),
    ];
  // Controller for asset image demo (now using network links)
  final MyImageController _assetImagesController = MyImageController()
    ..images = [
      MyimageResult(
        path: '',
        base64: "",
        link:
            'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=400&q=80',
      ),
      MyimageResult(
        path: '',
        base64: "",
        link:
            'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=400&q=80',
      ),
    ];
  final MyImageController _profileController = MyImageController();
  final MyImageController _multiController = MyImageController();
  final MyImageController _customController = MyImageController();
  final MyImageController _customsController = MyImageController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 40, thickness: 2),
          const Text(
            'MyImage with 2 Default Network Images',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            controller: _networkImagesController,
            onImagesChanged: (results) {
              setState(() {});
            },
            maxImages: 5,
            allow: false,
            imageBuilder: (context, image, index) {
              return (image.link.trim().isNotEmpty &&
                      Uri.tryParse(image.link)?.hasAbsolutePath == true)
                  ? Image.network(
                      image.link,
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    )
                  : (image.path.trim().isNotEmpty
                        ? Image.file(
                            File(image.path),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ));
            },
          ),
          if (_networkImagesController.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Default network images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _networkImagesController.images.length,
                itemBuilder: (context, idx) {
                  final result = _networkImagesController.images[idx];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child:
                          (result.link.trim().isNotEmpty &&
                              Uri.tryParse(result.link)?.hasAbsolutePath ==
                                  true)
                          ? Image.network(
                              result.link,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : (result.path.trim().isNotEmpty
                                ? Image.file(
                                    File(result.path),
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  )),
                    ),
                  );
                },
              ),
            ),
          ],
          const Divider(height: 40, thickness: 2),
          const Text(
            'MyImage with 2 Default Asset Images',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            controller: _assetImagesController,
            onImagesChanged: (results) {
              setState(() {});
            },
            maxImages: 5,
          ),
          if (_assetImagesController.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text('Default images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _assetImagesController.images.length,
                itemBuilder: (context, idx) {
                  final result = _assetImagesController.images[idx];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (result.link).isNotEmpty
                          ? Image.network(
                              result.link,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : (result.path.isNotEmpty
                                ? Image.asset(
                                    result.path,
                                    height: 100,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  )),
                    ),
                  );
                },
              ),
            ),
          ],
          Text(
            'Single Profile Image',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            controller: _profileController,
            maxImages: 1,
            onImagesChanged: (results) {
              setState(() {});
              logger.i('Profile image changed:');
              for (var r in results) {
                logger.i(r.toString());
              }
            },
            isDoc: true,
            isDirectUpload: true,
            uploadUrl: 'https://catbox.moe/user/api.php',
          ),
          if (_profileController.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected profile image:'),
            _profileController.images[0].path.isNotEmpty
                ? Image.file(
                    File(_profileController.images[0].path),
                    height: 100,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
            Text(
              'Base64: ${_profileController.images[0].base64.substring(0, 20)}...',
            ),
            Text('Link: ${_profileController.images[0].link}...'),
          ],
          const Divider(height: 40, thickness: 2),
          Text(
            'single Image Picker (Custom Builder)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            controller: _customsController,
            onImagesChanged: (results) {
              setState(() {});
            },
            isDoc: true,
            maxImages: 1,
            plusBuilder: (context) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.yellow[100],
              ),
              child: const Center(
                child: Icon(Icons.star, color: Colors.red, size: 40),
              ),
            ),
            imageBuilder: (context, image, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    (image.link.trim().isNotEmpty &&
                        Uri.tryParse(image.link)?.hasAbsolutePath == true)
                    ? Image.network(
                        image.link,
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      )
                    : (image.path.trim().isNotEmpty
                          ? Image.file(
                              File(image.path),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            )),
              );
            },
            removeIconBuilder: (context, idx, image) {
              final isValidNetwork =
                  image.link.trim().isNotEmpty &&
                  Uri.tryParse(image.link)?.hasAbsolutePath == true;
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${idx + 1}', style: TextStyle(color: Colors.red)),
                    SizedBox(width: 4),
                    isValidNetwork
                        ? Image.network(image.link, width: 24, height: 24)
                        : Icon(Icons.close, color: Colors.red),
                  ],
                ),
              );
            },
          ),
          if (_customsController.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _customsController.images.length,
                itemBuilder: (context, idx) {
                  final result = _customsController.images[idx];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: result.path.isNotEmpty
                          ? Image.file(
                              File(result.path),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 32),
          const Divider(height: 40, thickness: 2),
          Text(
            'Multi Image Picker',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            controller: _multiController,
            onImagesChanged: (results) {
              setState(() {});
            },
            uploadUrl: 'https://catbox.moe/user/api.php',
            uploadToken: '',
          ),
          if (_multiController.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _multiController.images.length,
                itemBuilder: (context, idx) {
                  final result = _multiController.images[idx];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: result.path.trim().isNotEmpty
                          ? Image.file(
                              File(result.path),
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 32), // Extra space to prevent overflow
          const Divider(height: 40, thickness: 2),
          Text(
            'start Multi Image Picker (Custom Builder)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            controller: _customController,
            onImagesChanged: (results) {
              setState(() {});
            },
            maxImages: null, // unlimited
            plusBuilder: (context) => Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(16),
                color: Colors.yellow[100],
              ),
              child: const Center(
                child: Icon(Icons.star, color: Colors.orange, size: 40),
              ),
            ),
            removeIconBuilder: (context, idx, image) {
              final isValidNetwork =
                  image.link.trim().isNotEmpty &&
                  Uri.tryParse(image.link)?.hasAbsolutePath == true;
              return Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${idx + 1}', style: TextStyle(color: Colors.red)),
                    SizedBox(width: 4),
                    isValidNetwork
                        ? Image.network(image.link, width: 24, height: 24)
                        : Icon(Icons.close, color: Colors.red),
                  ],
                ),
              );
            },
          ),
          if (_customController.images.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _customController.images.length,
                itemBuilder: (context, idx) {
                  final result = _customController.images[idx];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(result.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // Extra space to prevent overflow
        ],
      ),
    );
  }
}
