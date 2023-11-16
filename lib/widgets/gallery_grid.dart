import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memory/widgets/view_image.dart';
import 'package:transparent_image/transparent_image.dart';

class GalleryGrid extends StatefulWidget {
  const GalleryGrid(
      {super.key,
      required this.pickedImages,
      required this.selectedImages,
      required this.onChangeSelection,
      required this.selectedIcon,
      this.initialCrossAxisCount = 3});

  final List<Uint8List> pickedImages;
  final List<int> selectedImages;
  final Function(int, bool) onChangeSelection;
  final IconData selectedIcon;
  final int initialCrossAxisCount;

  @override
  State<GalleryGrid> createState() => _GalleryGridState();
}

class _GalleryGridState extends State<GalleryGrid> {
  late int _crossAxisCount;
  bool _scaling = false;

  @override
  void initState() {
    _crossAxisCount = widget.initialCrossAxisCount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contextWidth = MediaQuery.of(context).size.width;
    const minImageWidth = 100;
    final borderRadius = contextWidth / 10 / _crossAxisCount;
    final margin = borderRadius / 2;
    return GestureDetector(
      onScaleStart: (details) {
        _scaling = true;
      },
      onScaleEnd: (details) {
        _scaling = false;
      },
      onScaleUpdate: (details) => setState(() {
        if (_scaling) {
          if (details.scale < 1) {
            if (contextWidth / _crossAxisCount > minImageWidth) {
              _crossAxisCount = min(10, _crossAxisCount + 1);
            }
            _scaling = false;
          } else if (details.scale > 1) {
            if (_crossAxisCount > 1) {
              _crossAxisCount -= 1;
            }
            _scaling = false;
          }
        }
      }),
      child: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _crossAxisCount,
        ),
        itemCount: widget.pickedImages.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              if (widget.selectedImages.contains(index)) {
                widget.onChangeSelection(index, false);
              } else {
                widget.onChangeSelection(index, true);
              }
            },
            onLongPress: () {
              showDialog(
                  context: context,
                  builder: (context) {
                    return ViewImage(image: widget.pickedImages[index]);
                  });
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              elevation: widget.selectedImages.contains(index) ? 2 : 10,
              margin: EdgeInsets.all(margin),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: FadeInImage(
                        placeholder: MemoryImage(kTransparentImage),
                        fit: BoxFit.cover,
                        image: MemoryImage(
                          widget.pickedImages[index],
                        ),
                      )),
                  if (widget.selectedImages.contains(index))
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        color: Colors.black38,
                      ),
                    ),
                  if (widget.selectedImages.contains(index))
                    Center(
                      child: Icon(
                        widget.selectedIcon,
                        color: Colors.white,
                        size: (200 / _crossAxisCount).toDouble(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
