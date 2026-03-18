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
  List<MyimageResult> _profileImages = [];
  List<MyimageResult> _multiImages = [];
  List<MyimageResult> _customImages = [];
  List<MyimageResult> _customImagess = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Single Profile Image',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            images: _profileImages,
            maxImages: 1,
            onImagesChanged: (results) {
              setState(() => _profileImages = results);
              // Debug print for troubleshooting
              logger.i('Profile image changed:');
              for (var r in results) {
                logger.i(r.toString());
              }
            },
            isDoc: true,
            isDirectUpload: true,
            uploadUrl:
                'https://catbox.moe/user/api.php', // Direct image upload endpoint
            // uploadToken: '', // catbox.moe does not require token
          ),
          if (_profileImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected profile image:'),
            Image.file(File(_profileImages[0].path), height: 100),
            Text('Base64: ${_profileImages[0].base64?.substring(0, 20)}...'),
            Text('Link: ${_profileImages[0].link}...'),
          ],
          const Divider(height: 40, thickness: 2),
          Text(
            'Multi Image Picker',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            images: _multiImages,
            onImagesChanged: (results) {
              setState(() => _multiImages = results);
            },

            uploadUrl:
                // "",
                'https://catbox.moe/user/api.php', // Direct image upload endpoint
            uploadToken: '',
          ),
          if (_multiImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _multiImages.length,
                itemBuilder: (context, idx) {
                  final result = _multiImages[idx];
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
          const SizedBox(height: 32), // Extra space to prevent overflow
          const Divider(height: 40, thickness: 2),
          Text(
            'Multi Image Picker (Custom Builder)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            images: _customImages,
            onImagesChanged: (results) {
              setState(() => _customImages = results);
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
              // Custom icon: show index and thumbnail
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
                    image.link != null
                        ? Image.network(image.link!, width: 24, height: 24)
                        : Icon(Icons.close, color: Colors.red),
                  ],
                ),
              );
            },
          ),
          if (_customImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _customImages.length,
                itemBuilder: (context, idx) {
                  final result = _customImages[idx];
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
          const SizedBox(height: 32), // Extra space to prevent overflow
          const Divider(height: 40, thickness: 2),
          Text(
            'Multi Image Picker (Custom Builder)',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          MyImage(
            images: _customImagess,
            onImagesChanged: (results) {
              setState(() => _customImagess = results);
            },
            isDoc: true,
            maxImages: 1, // unlimited
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
                child: image.path.isEmpty
                    ? Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      )
                    : Image.file(
                        File(image.path),
                        height: 100,
                        width: 100,
                        fit: BoxFit.cover,
                      ),
              );
            },
            removeIconBuilder: (context, idx, image) {
              // Custom icon: show index and thumbnail
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
                    image.link != null
                        ? Image.network(image.link!, width: 24, height: 24)
                        : Icon(Icons.close, color: Colors.red),
                  ],
                ),
              );
            },
          ),
          if (_customImagess.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected images:'),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _customImagess.length,
                itemBuilder: (context, idx) {
                  final result = _customImagess[idx];
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
          const SizedBox(height: 32), // Extra space to prevent overflow
        ],
      ),
    );
  }
}
