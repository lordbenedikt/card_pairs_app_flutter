import 'package:memory/flipper_customized/flippy.dart';
import 'package:flutter/material.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard(
      {super.key,
      required this.cardIndex,
      required this.imageProvider,
      required this.onTap,
      required this.flipperController});

  final int cardIndex;
  final ImageProvider imageProvider;
  final void Function(int) onTap;
  final FlipperController flipperController;

  void isFrontVisible() {
    flipperController.isFrontVisible;
  }

  @override
  Widget build(BuildContext context) {
    Color backColor = Theme.of(context).colorScheme.secondaryContainer;
    Color backColorDarker = Color.fromARGB(
      255,
      (backColor.red * 0.9).round(),
      (backColor.green * 0.9).round(),
      (backColor.blue * 0.9).round(),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onTap: () {
            print('index: $cardIndex');
            onTap(cardIndex);
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
              child: Image(
                // alignment: Alignment.topCenter,
                image: imageProvider,
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
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
