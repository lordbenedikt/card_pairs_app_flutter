import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CircularImagePicker extends StatefulWidget {
  const CircularImagePicker({
    super.key,
    required this.onPickImage,
    this.onStart,
    this.label,
    this.radius = 60,
  });

  final void Function(File pickedImage)? onPickImage;
  final void Function()? onStart;
  final String? label;
  final double radius;

  @override
  State<CircularImagePicker> createState() => _CircularImagePickerState();
}

class _CircularImagePickerState extends State<CircularImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    if (widget.onStart != null) widget.onStart!();
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (pickedImage == null) return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage!(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onPickImage == null ? null : _pickImage,
      child: CircleAvatar(
        radius: widget.radius,
        backgroundColor: _pickedImageFile != null
            ? Colors.transparent
            : Theme.of(context).colorScheme.inverseSurface,
        foregroundImage:
            _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
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
