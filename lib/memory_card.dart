import 'package:memory/flipper_customized/flippy.dart';
import 'package:flutter/material.dart';

class MemoryCard extends StatelessWidget {
  const MemoryCard(
      {super.key,
      this.width = 200,
      this.height = 200,
      required this.cardIndex,
      required this.imageProvider,
      required this.onTap,
      required this.flipperController});

  final double width;
  final double height;
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

    return Flipper(
      startFaceDown: true,
      width: width,
      height: height,
      margin: const EdgeInsets.all(0),
      padding: EdgeInsets.all(width / 40),
      showShadow: false,
      backgroundColor: Colors.transparent,
      controller: flipperController,
      front: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width / 15)),
        child: Image(
          image: imageProvider,
          fit: BoxFit.cover,
        ),
      ),
      back: Card(
        clipBehavior: Clip.hardEdge,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(width / 15)),
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
    );
  }
}
