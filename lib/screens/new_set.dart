import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memory/widgets/cover_image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:memory/widgets/gallery_grid.dart';
import 'package:uuid/v4.dart';

class NewSet extends StatefulWidget {
  const NewSet({super.key});

  @override
  State<NewSet> createState() => _NewSetState();
}

class _NewSetState extends State<NewSet> {
  final List<File> _pickedImages = [];
  final List<int> _selectedImages = [];
  File? _pickedCoverImage;
  bool _isLoading = false;
  int _galleryZoom = 3;
  bool _scaling = false;
  String _pickedTitle = '';

  final _form = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (isValid) {
      _form.currentState!.save();
      final storageRefParent = FirebaseStorage.instance
          .ref()
          .child(FirebaseAuth.instance.currentUser!.uid);

      final List<String> imageUrls = [];

      for (final image in _pickedImages) {
        final storageRef =
            storageRefParent.child('${DateTime.now().toIso8601String()}.jpg');
        await storageRef.putFile(image);
        imageUrls.add(await storageRef.getDownloadURL());
      }

      // FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(userCredentials.user!.uid)
      //     .set({
      //   'email': _enteredEmail,
      //   'username': _enteredUsername,
      //   'image_url': imageUrl,
      // });
      Navigator.of(context).pop();
    }
  }

  void _changeSelection(int index, bool addItem) {
    setState(() {
      if (addItem) {
        _selectedImages.add(index);
      } else {
        _selectedImages.remove(index);
      }
    });
  }

  void _pickImages() async {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() => _isLoading = true);
    });

    final pickedMultiImage = await ImagePicker().pickMultiImage(
      imageQuality: 50,
      maxWidth: 300,
    );

    setState(() {
      try {
        for (final imageXFile in pickedMultiImage) {
          _pickedImages.add(File(imageXFile.path));
        }
      } catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $error')));
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget galleryWidget = const Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          strokeWidth: 10,
        ),
      ),
    );

    if (!_isLoading) {
      galleryWidget = _pickedImages.isNotEmpty
          ? GestureDetector(
              onScaleStart: (details) {
                _scaling = true;
              },
              onScaleEnd: (details) {
                _scaling = false;
              },
              onScaleUpdate: (details) => setState(() {
                if (_scaling) {
                  if (details.scale < 0.95) {
                    _galleryZoom = max(0, _galleryZoom - 1);
                    _scaling = false;
                  } else if (details.scale > 1.05) {
                    _galleryZoom = min(3, _galleryZoom + 1);
                    _scaling = false;
                  }
                }
              }),
              child: GalleryGrid(
                pickedImages: _pickedImages,
                selectedImages: _selectedImages,
                onChangeSelection: _changeSelection,
                zoom: _galleryZoom,
              ),
            )
          : Center(
              child: Text('No images in this card set.',
                  softWrap: true,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onBackground)),
            );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Create new Set',
          textAlign: TextAlign.center,
        ),
        actions: [
          if (_selectedImages.length == _pickedImages.length)
            IconButton(
              tooltip: 'clear selection',
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                });
              },
              icon: const Icon(Icons.close),
            ),
          if (_selectedImages.isNotEmpty &&
              _selectedImages.length != _pickedImages.length)
            IconButton(
              tooltip: 'select all',
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _selectedImages.addAll(
                      List.generate(_pickedImages.length, (index) => index));
                });
              },
              icon: const Icon(Icons.select_all),
            ),
          if (_selectedImages.isNotEmpty)
            IconButton(
              tooltip: 'delete selected images',
              onPressed: () {
                _selectedImages.sort((a, b) => b - a);
                setState(() {
                  for (final index in _selectedImages) {
                    _pickedImages.removeAt(index);
                  }
                });
                _selectedImages.clear();
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: galleryWidget),
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Form(
                  key: _form,
                  child: TextFormField(
                    maxLength: 50,
                    onSaved: (value) {
                      _pickedTitle = value!;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Must be at least 2 characters long';
                      }
                      if (value.length < 2) {
                        return 'Must be at least 2 characters long';
                      }
                      return null;
                    },
                    decoration: InputDecoration(label: Text("Title")),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CoverImagePicker(onPickImage: (file) {
                      _pickedCoverImage = file;
                    }),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                              onPressed: !_isLoading ? _pickImages : null,
                              icon: const Icon(Icons.add),
                              label: const Text("Add images")),
                          ElevatedButton(
                              onPressed: !_isLoading ? _submit : null,
                              child: const Text("Submit")),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}