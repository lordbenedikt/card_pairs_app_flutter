import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker(
      {super.key, required this.onPickImage, this.initialImage});

  final void Function(Uint8List pickedImage) onPickImage;
  final Uint8List? initialImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  Uint8List? _pickedImage;

  @override
  void initState() {
    _pickedImage = widget.initialImage;
    super.initState();
  }

  void _pickImage(ImageSource source) async {
    final pickedImageXFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (pickedImageXFile == null) return;
    final pickedImage = await pickedImageXFile.readAsBytes();
    setState(() {
      _pickedImage = pickedImage;
    });
    widget.onPickImage(_pickedImage!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            foregroundImage:
                _pickedImage != null ? MemoryImage(_pickedImage!) : null),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
            onPressed: () {
              _pickImage(ImageSource.camera);
            },
            icon: Icon(
              Icons.camera,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Take photo',
          ),
          IconButton(
            onPressed: () {
              _pickImage(ImageSource.gallery);
            },
            icon: Icon(
              Icons.image,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
            tooltip: 'Choose from gallery',
          ),
        ]),
      ],
    );
  }
}
