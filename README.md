# MyImage Flutter Plugin

Customizable image picker widget for profile and multi-image selection with plus button, custom image builder, custom remove icon, asset fallback, and upload progress.

## Features

- Pick images from camera, gallery, or document scanner
- Single or multi-image mode
- Custom builder for images, plus button, and remove icon
- Asset fallback for empty state (assets/default_image.png)
- Customizable upload success/failure/error messages
- Direct upload with assert for uploadUrl
- Internal state management

## Usage Example

```dart
import 'package:myimage/myimage.dart';

MyImage(
	images: images,
	onImagesChanged: (results) {
		setState(() => images = List<MyimageResult>.from(results));
	},
	maxImages: null, // unlimited
	imageBuilder: (context, idx, image) {
		// Custom image display: add border and overlay
		return Stack(
			children: [
				Container(
					width: 100,
					height: 100,
					decoration: BoxDecoration(
						border: Border.all(color: Colors.green, width: 2),
						borderRadius: BorderRadius.circular(16),
					),
					child: image.link != null
							? Image.network(image.link!, fit: BoxFit.cover)
							: Icon(Icons.image, size: 40, color: Colors.green),
				),
				Positioned(
					bottom: 4,
					right: 4,
					child: Container(
						padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
						decoration: BoxDecoration(
							color: Colors.black54,
							borderRadius: BorderRadius.circular(8),
						),
						child: Text('Img #${idx + 1}', style: TextStyle(color: Colors.white, fontSize: 12)),
					),
				),
			],
		);
	},
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
				color: Colors.blue.shade100,
				borderRadius: BorderRadius.circular(12),
			),
			child: Row(
				mainAxisSize: MainAxisSize.min,
				children: [
					Text('Remove #${idx + 1}', style: TextStyle(color: Colors.blue)),
					SizedBox(width: 4),
					image.link != null
							? Image.network(image.link!, width: 24, height: 24)
							: Icon(Icons.close, color: Colors.blue),
				],
			),
		);
	},
	uploadSuccessMessage: 'Upload successful!',
	uploadFailedMessage: 'Upload failed:',
	uploadErrorMessage: 'Upload error:',
)
```

## Asset Fallback

If no image is selected and isDirectUpload is false, a default asset image is shown:

```
assets/default_image.png
```

Add this to your pubspec.yaml:

```
flutter:
	assets:
		- assets/default_image.png
```

## Parameters

- `images`: List of selected images
- `onImagesChanged`: Callback when images change
- `maxImages`: Maximum images allowed (null = unlimited)
- `imageBuilder`: Custom builder for each image
- `plusBuilder`: Custom builder for plus button
- `removeIconBuilder`: Custom builder for remove icon
- `uploadSuccessMessage`: Custom upload success message
- `uploadFailedMessage`: Custom upload failed message
- `uploadErrorMessage`: Custom upload error message
- `isDirectUpload`: If true, requires uploadUrl
- `uploadUrl`: Upload endpoint
- `uploadToken`: Optional upload token

## Example

See `example/lib/custom_remove_icon_example.dart` for a focused custom remove icon demo.
See `example/lib/main.dart` for a complete demo.
