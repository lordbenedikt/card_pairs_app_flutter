import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CoverImagePicker extends StatefulWidget {
  const CoverImagePicker({super.key, required this.onPickImage});

  final void Function(File pickedImage) onPickImage;

  @override
  State<CoverImagePicker> createState() => _CoverImagePickerState();
}

class _CoverImagePickerState extends State<CoverImagePicker> {
  File? _pickedImageFile;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedImage == null) return;
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });
    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: _pickedImageFile != null
            ? Colors.transparent
            : Theme.of(context).colorScheme.inverseSurface,
        foregroundImage:
            _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.add, color: Theme.of(context).colorScheme.surface),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: Theme.of(context).colorScheme.surface),
              textAlign: TextAlign.center,
              'Add cover image',
              softWrap: true,
            ),
          ),
        ]),
      ),
    );
  }
}
