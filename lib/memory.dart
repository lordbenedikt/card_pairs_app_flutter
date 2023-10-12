import 'package:memory/custom_grid.dart';
import 'package:memory/flipper_customized/flippy.dart';
import 'package:flutter/material.dart';

import 'package:memory/image_provider.dart';
import 'package:memory/memory_card.dart';

class Memory extends StatefulWidget {
  const Memory({
    super.key,
    required this.onRestart,
    required this.cols,
    required this.rows,
  });

  final void Function() onRestart;
  final int cols;
  final int rows;

  @override
  State<Memory> createState() => _MemoryState();
}

class _MemoryState extends State<Memory> {
  List<int> activeCardIndices = [];
  List<String> imagePaths = [];
  List<MemoryCard> cards = [];
  List<int> discoveredCards = [];
  bool doingPairCheck = false;
  bool gameOver = false;

  void precacheImages(BuildContext context, List<String> paths) {
    for (var path in paths) {
      precacheImage(AssetImage(path), context);
    }
  }

  bool foundPair() {
    if (activeCardIndices.length < 2) return false;
    return imagePaths[activeCardIndices[0]] == imagePaths[activeCardIndices[1]];
  }

  void onTapCard(int index) {
    // if card is already selected do nothing
    if (activeCardIndices.contains(index)) {
      return;
    }
    // if card animation is already playing do nothing
    if (!cards[index].flipperController.isAnimationCompleted()) {
      return;
    }
    // if card is already discovered & paired do nothing
    if (cards[index].flipperController.isFrontVisible()) {
      return;
    }
    // reveal card
    if (activeCardIndices.length < 2) {
      cards[index].flipperController.flipUp();
      activeCardIndices.add(index);
    }
    // check for pairs, cover cards, clear selection, restart game
    if (activeCardIndices.length == 2 && !doingPairCheck) {
      if (foundPair()) {
        discoveredCards.addAll(activeCardIndices);
        activeCardIndices.clear();
        // setState(() {
        //   if (discoveredPairs * 2 == imagePaths.length) {
        //     gameOver = true;
        //   }
        // });
        if (discoveredCards.length == imagePaths.length) {
          setState(() {
            gameOver = true;
          });
          Future.delayed(const Duration(milliseconds: 2000), () {
            widget.onRestart();
          });
        }
      } else {
        doingPairCheck = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          cards[activeCardIndices[0]].flipperController.flipDown();
          Future.delayed(const Duration(milliseconds: 100), () {
            cards[activeCardIndices[1]].flipperController.flipDown();
            activeCardIndices.clear();
            doingPairCheck = false;
          });
        });
      }
    }
  }

  void setup() {
    final numOfPairs = (widget.cols * widget.rows / 2).floor();
    setState(() {
      imagePaths = CompressedImageProvider.imagePaths;
      imagePaths.shuffle();
      imagePaths = [
        ...imagePaths.sublist(0, numOfPairs),
        ...imagePaths.sublist(0, numOfPairs),
      ];
      imagePaths.shuffle();
      cards = [
        for (var i = 0; i < imagePaths.length; i++)
          MemoryCard(
            key: ValueKey('memory_card_$i'),
            onTap: onTapCard,
            cardIndex: i,
            imageProvider: MemoryImage(
              CompressedImageProvider.compressedImages[imagePaths[i]]!,
            ),
            flipperController: FlipperController(dragAxis: DragAxis.vertical),
          ),
      ];
      activeCardIndices = [];
      discoveredCards = [];
      doingPairCheck = false;
      gameOver = false;
    });

    Future.delayed(Duration.zero, () {
      precacheImages(context, imagePaths);
    });
  }

  @override
  void initState() {
    setup();
    super.initState();
  }

  @override
  void dispose() {
    for (var card in cards) {
      card.flipperController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: gameOver ? Colors.green : Colors.amber[300],
        title: Text(
          gameOver ? 'Congratulations!' : 'Can you find all pairs?',
          textAlign: TextAlign.center,
        ),
      ),
      // backgroundColor: Colors.brown[200],
      body: CustomGrid(
        cols: widget.cols,
        rows: widget.rows,
        children: cards,
      ),
    );
  }
}
