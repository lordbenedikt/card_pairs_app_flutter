import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CircularImagePicker extends StatefulWidget {
  const CircularImagePicker({
    super.key,
    required this.onPickImage,
    this.isEnabled = true,
    this.onStart,
    this.label,
    this.radius = 60,
  });

  final void Function(Uint8List pickedImage) onPickImage;
  final void Function()? onStart;
  final bool isEnabled;
  final String? label;
  final double radius;

  @override
  State<CircularImagePicker> createState() => _CircularImagePickerState();
}

class _CircularImagePickerState extends State<CircularImagePicker> {
  Uint8List? _pickedImage;

  void _pickImage() async {
    if (widget.onStart != null) widget.onStart!();
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (pickedImage == null) {
      return;
    }
    final imageData = await pickedImage.readAsBytes();
    setState(() {
      _pickedImage = imageData;
    });
    widget.onPickImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: _pickedImage != null
            ? Colors.transparent
            : Theme.of(context).colorScheme.inverseSurface,
        foregroundImage:
            _pickedImage != null ? MemoryImage(_pickedImage!) : null,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
          if (widget.label != null)
            Padding(
              padding: EdgeInsets.all(widget.radius / 6),
              child: Text(
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: Theme.of(context).colorScheme.surface),
                textAlign: TextAlign.center,
                widget.label!,
                softWrap: true,
              ),
            ),
        ]),
      ),
    );
  }
}
