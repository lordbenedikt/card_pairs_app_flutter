import 'dart:math';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/helpers/share.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/widgets/gallery_grid.dart';

class ViewCardSet extends ConsumerStatefulWidget {
  const ViewCardSet(this.set, {super.key});

  final CardSet set;

  @override
  ConsumerState<ViewCardSet> createState() => _ViewCardSetState();
}

class _ViewCardSetState extends ConsumerState<ViewCardSet> {
  final List<Uint8List> _imagesData = [];
  final List<int> _selectedImages = [];
  bool _isLoading = true;

  void loadImages() async {
    for (final url in widget.set.imageUrls) {
      final imageData =
          await FirebaseStorage.instance.refFromURL(url).getData();
      if (imageData != null) {
        _imagesData.add(imageData);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    loadImages();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    Widget galleryWidget = const Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: Column(
          children: [
            CircularProgressIndicator(
              strokeWidth: 10,
            ),
          ],
        ),
      ),
    );

    if (!_isLoading) {
      galleryWidget = _imagesData.isNotEmpty
          ? GalleryGrid(
              pickedImages: _imagesData,
              selectedImages: _selectedImages,
              onChangeSelection: _changeSelection,
              selectedIcon: Icons.check)
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
        title: Text(
          widget.set.title,
          textAlign: TextAlign.center,
        ),
        actions: [
          if (_selectedImages.length == _imagesData.length &&
              _imagesData.isNotEmpty)
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
              _selectedImages.length != _imagesData.length)
            IconButton(
              tooltip: 'select all',
              onPressed: () {
                setState(() {
                  _selectedImages.clear();
                  _selectedImages.addAll(
                      List.generate(_imagesData.length, (index) => index));
                });
              },
              icon: const Icon(Icons.select_all),
            ),
          if (_selectedImages.isNotEmpty)
            IconButton(
              tooltip: 'select all',
              onPressed: () {
                setState(() {
                  Share.fromUrl(_selectedImages
                      .map((index) => widget.set.imageUrls[index])
                      .toList());
                });
              },
              icon: const Icon(Icons.share),
            ),
        ],
      ),
      body: galleryWidget,
    );
  }
}
