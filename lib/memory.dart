import 'package:flippy/flippy.dart';
import 'package:flutter/material.dart';

import 'package:memory/asset_path_provider.dart';
import 'package:memory/memory_card.dart';

class Memory extends StatefulWidget {
  const Memory({super.key});

  @override
  State<Memory> createState() => _MemoryState();
}

class _MemoryState extends State<Memory> {
  List<int> activeCardIndices = [];
  List<String> imagePaths = [];
  List<MemoryCard> cards = [];
  int discoveredPairs = 0;
  bool doingPairCheck = false;
  bool gameOver = false;

  static const numOfPairs = 14;

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
        activeCardIndices.clear();
        discoveredPairs++;
        // setState(() {
        //   if (discoveredPairs * 2 == imagePaths.length) {
        //     gameOver = true;
        //   }
        // });
        if (discoveredPairs * 2 == imagePaths.length) {
          Future.delayed(Duration(milliseconds: 2000), () {
            setup();
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
    setState(() {
      imagePaths = AssetsPathProvider.imagePaths;
      imagePaths.shuffle();
      imagePaths = [
        ...imagePaths.sublist(0, numOfPairs),
        ...imagePaths.sublist(0, numOfPairs),
      ];
      imagePaths.shuffle();
      activeCardIndices = [];

      cards = [
        for (var i = 0; i < imagePaths.length; i++)
          MemoryCard(
            onTap: onTapCard,
            cardIndex: i,
            width: 160,
            height: 160,
            imageProvider: AssetImage(imagePaths[i]),
            flipperController: FlipperController(dragAxis: DragAxis.vertical),
          ),
      ];
      discoveredPairs = 0;
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
        title: Text(gameOver ? 'Congratulations!' : 'Can you find all pairs?'),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 160,
          mainAxisExtent: 160,
          mainAxisSpacing: 0,
        ),
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              onTapCard(index);
            },
            child: cards[index],
          );
        },
      ),
    );
  }
}
