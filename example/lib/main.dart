import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myimage/myimage.dart';

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
          Myimage(
            images: _profileImages,
            maxImages: 1,
            onImagesChanged: (results) {
              setState(
                () => _profileImages = List<MyimageResult>.from(results),
              );
            },
            isDoc: true,
          ),
          if (_profileImages.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Selected profile image:'),
            Image.file(File(_profileImages[0].path), height: 100),
            Text('Base64: ${_profileImages[0].base64?.substring(0, 20)}...'),
          ],
          const Divider(height: 40, thickness: 2),
          Text(
            'Multi Image Picker',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Myimage(
            images: _multiImages,
            onImagesChanged: (results) {
              setState(() => _multiImages = List<MyimageResult>.from(results));
            },
            isDoc: true,
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
          Myimage(
            images: _customImages,
            onImagesChanged: (results) {
              setState(() => _customImages = List<MyimageResult>.from(results));
            },
            isDoc: true,
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
            removeIconBuilder: (context, idx, image) => Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purple,
                border: Border.all(color: Colors.white, width: 2),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(Icons.delete, color: Colors.white, size: 20),
            ),
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
        ],
      ),
    );
  }
}
