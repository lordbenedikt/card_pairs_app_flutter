import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GalleryGrid extends StatelessWidget {
  const GalleryGrid(
      {super.key,
      required this.pickedImages,
      required this.selectedImages,
      required this.onChangeSelection,
      this.zoom = 2});

  final List<Uint8List> pickedImages;
  final List<int> selectedImages;
  final Function(int, bool) onChangeSelection;
  final int zoom;

  @override
  Widget build(BuildContext context) {
    final contextWidth = MediaQuery.of(context).size.width;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: max(1, ((contextWidth / 200) * (5 - zoom)).floor()),
      ),
      itemCount: pickedImages.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            if (selectedImages.isNotEmpty) {
              if (selectedImages.contains(index)) {
                onChangeSelection(index, false);
              } else {
                onChangeSelection(index, true);
              }
            }
          },
          onLongPress: () {
            if (selectedImages.isEmpty) {
              if (selectedImages.contains(index)) {
                onChangeSelection(index, false);
              } else {
                onChangeSelection(index, true);
              }
            }
          },
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: selectedImages.contains(index) ? 2 : 10,
            margin: EdgeInsets.all(4 + zoom * 2),
            clipBehavior: Clip.hardEdge,
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Image.memory(
                    pickedImages[index],
                    fit: BoxFit.cover,
                    colorBlendMode: BlendMode.multiply,
                    color: selectedImages.contains(index)
                        ? Colors.grey
                        : Colors.white,
                  ),
                ),
                if (selectedImages.contains(index))
                  const Center(
                    child: Icon(
                      FontAwesomeIcons.circleXmark,
                      color: Colors.white,
                      size: 70,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
