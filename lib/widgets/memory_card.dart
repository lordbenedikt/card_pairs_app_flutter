import 'package:memory/flipper_customized/flippy.dart';
import 'package:flutter/material.dart';
import 'package:memory/providers/sqflite_helper.dart';
import 'package:memory/widgets/view_image.dart';
import 'package:transparent_image/transparent_image.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard(
      {super.key,
      required this.cardIndex,
      required this.imageUrl,
      required this.onTap,
      required this.flipperController});

  final int cardIndex;
  final String imageUrl;
  final void Function(int) onTap;
  final FlipperController flipperController;

  void isFrontVisible() {
    flipperController.isFrontVisible;
  }

  void viewImage(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) {
          return ViewImage(imageUrl);
        });
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = Theme.of(context).colorScheme.secondaryContainer;
    Color backColorDarker = Color.fromARGB(
      255,
      (backColor.red * 0.8).round(),
      (backColor.green * 0.8).round(),
      (backColor.blue * 0.8).round(),
    );
    // final imageFuture = FutureBuilder(
    //   future: SqfliteHelper.getImage(imageUrl),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(child: CircularProgressIndicator());
    //     }
    //     if (snapshot.hasError) {
    //       return const Center(child: Text("error: failed to load image"));
    //     }
    //     return Image.memory(snapshot.data!, fit: BoxFit.cover);
    //   },
    // );

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            onTap(cardIndex);
          },
          onLongPress: () {
            if (flipperController.isFrontVisible()) {
              viewImage(context);
            }
          },
          child: Flipper(
            startFaceDown: true,
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            margin: const EdgeInsets.all(0),
            padding: const EdgeInsets.all(0),
            showShadow: false,
            backgroundColor: Colors.transparent,
            controller: flipperController,
            front: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(constraints.maxWidth / 15)),
              child: FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            back: Card(
              clipBehavior: Clip.hardEdge,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(constraints.maxWidth / 15)),
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.5, 0.5),
                    radius: 3,
                    colors: [
                      backColor,
                      backColorDarker,
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
