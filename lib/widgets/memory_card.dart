import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:memory/widgets/view_image.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flip_card/flip_card.dart';

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
  final FlipCardController flipperController;

  bool isFrontVisible() {
    return flipperController.state!.isFront;
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
        final boxShadow = [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              offset: const Offset(1, 1)),
        ];
        return GestureDetector(
          onTap: () {
            onTap(cardIndex);
          },
          onLongPress: () {
            if (isFrontVisible()) {
              viewImage(context);
            }
          },
          child: FlipCard(
            flipOnTouch: false,
            side: CardSide.BACK,
            controller: flipperController,
            front: Container(
              margin: EdgeInsets.all(constraints.maxWidth / 50),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(constraints.maxWidth / 15),
                boxShadow: boxShadow,
              ),
              child: FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            back: Container(
              margin: EdgeInsets.all(constraints.maxWidth / 50),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(constraints.maxWidth / 15),
                gradient: RadialGradient(
                  center: const Alignment(0.5, 0.5),
                  radius: 3,
                  colors: [
                    backColor,
                    backColorDarker,
                  ],
                ),
                boxShadow: boxShadow,
              ),
            ),
          ),
        );
      },
    );
  }
}
