# MyImage Flutter Plugin

Customizable image picker widget for profile and multi-image selection with plus button, custom image builder, and custom remove icon.

## Features

- Pick images from camera, gallery, or document scanner
- Single or multi-image mode
- Custom builder for images and plus button
- Custom builder for remove icon
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
)
```

## Parameters

- `images`: List of selected images
- `onImagesChanged`: Callback when images change
- `maxImages`: Maximum images allowed (null = unlimited)
- `imageBuilder`: Custom builder for each image
- `plusBuilder`: Custom builder for plus button
- `removeIconBuilder`: Custom builder for remove icon

## Example

See `example/lib/main.dart` for a complete demo.
