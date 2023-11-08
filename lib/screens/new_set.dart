import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/models/group.dart';
import 'package:memory/widgets/circular_image_picker.dart';
import 'package:memory/widgets/gallery_grid.dart';
import 'package:uuid/v4.dart';

class NewSetScreen extends StatefulWidget {
  const NewSetScreen({required this.group, super.key});

  final Group group;

  @override
  State<NewSetScreen> createState() => _NewSetScreenState();
}

class _NewSetScreenState extends State<NewSetScreen> {
  final List<Uint8List> _pickedImages = [];
  final List<int> _selectedImages = [];
  Uint8List? _pickedCoverImage;
  bool _isLoading = false;
  double _uploadProgress = 0;
  int _galleryZoom = 3;
  bool _scaling = false;
  String _pickedTitle = '';

  final _form = GlobalKey<FormState>();

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || _pickedCoverImage == null) {
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    _form.currentState!.save();
    final storageRefParent = FirebaseStorage.instance
        .ref()
        .child('owned_data')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('card_sets')
        .child(widget.group.uid);

    final List<String> imageUrls = [];

    for (final image in _pickedImages) {
      final storageRef =
          storageRefParent.child('${const UuidV4().generate()}.png');
      await storageRef.putData(image);
      imageUrls.add(await storageRef.getDownloadURL());
      setState(() {
        _uploadProgress += 100 / _pickedImages.length;
      });
    }

    final storageRef =
        storageRefParent.child('${const UuidV4().generate()}.png');
    await storageRef.putData(_pickedCoverImage!);
    final coverImageUrl = await storageRef.getDownloadURL();

    final uid = const UuidV4().generate();
    FirebaseFirestore.instance.collection('card_sets').doc(uid).set(CardSet(
          uid: uid,
          title: _pickedTitle,
          imageUrls: imageUrls,
          coverImageUrl: coverImageUrl,
          owner: FirebaseAuth.instance.currentUser!.uid,
          groupsThatCanView: [widget.group.uid],
        ).toJson());

    if (context.mounted) {
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
      maxWidth: 800,
    );

    List<Uint8List> images = [];
    try {
      for (final imageXFile in pickedMultiImage) {
        images.add(await imageXFile.readAsBytes());
      }
    } catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $error')));
    }

    setState(() {
      _pickedImages.addAll(images);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget galleryWidget = Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          children: [
            const CircularProgressIndicator(
              strokeWidth: 10,
            ),
            const SizedBox(height: 20),
            Text('${_uploadProgress.ceil()} %'),
          ],
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
                  if (details.scale < 1) {
                    _galleryZoom = max(0, _galleryZoom - 1);
                    _scaling = false;
                  } else if (details.scale > 1) {
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
          if (_selectedImages.length == _pickedImages.length &&
              _pickedImages.isNotEmpty)
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
                    decoration: const InputDecoration(label: Text("Title")),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircularImagePicker(
                        isEnabled: !_isLoading,
                        onStart: () => setState(() {
                              _isLoading = true;
                            }),
                        onPickImage: (image) {
                          _pickedCoverImage = image;
                          setState(() {
                            _isLoading = false;
                          });
                        },
                        label: 'Add cover image'),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton.icon(
                              onPressed: !_isLoading ? _pickImages : null,
                              icon: const Icon(Icons.add),
                              label: const Text("Add images")),
                          const SizedBox(height: 20),
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
