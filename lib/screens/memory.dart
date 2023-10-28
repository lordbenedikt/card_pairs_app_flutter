import 'package:firebase_auth/firebase_auth.dart';
import 'package:memory/screens/new_set.dart';
import 'package:memory/widgets/custom_grid.dart';
import 'package:memory/flipper_customized/flippy.dart';
import 'package:flutter/material.dart';

import 'package:memory/image_provider.dart';
import 'package:memory/widgets/memory_card.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({
    super.key,
  });

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  bool gameOver = false;
  Key _key = UniqueKey();

  void restart() {
    setState(() {
      gameOver = false;
    });
    replaceMemoryWidget();
  }

  void replaceMemoryWidget() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:
            gameOver ? Colors.green : Theme.of(context).colorScheme.primary,
        centerTitle: true,
        title: Text(
          gameOver ? 'Congratulations!' : 'Can you find all pairs?',
          textAlign: TextAlign.center,
        ),
        actions: [
          IconButton(
            onPressed: restart,
            icon: const Icon(Icons.replay),
          ),
        ],
      ),
      // backgroundColor: Colors.brown[200],
      body: MemoryScreenBody(
        key: _key,
        onRestart: restart,
        onGameOver: () {
          setState(() => gameOver = true);
        },
      ),
    );
  }
}

class MemoryScreenBody extends StatefulWidget {
  const MemoryScreenBody({
    super.key,
    required this.onGameOver,
    required this.onRestart,
  });

  final void Function() onGameOver;
  final void Function() onRestart;

  @override
  State<MemoryScreenBody> createState() => _MemoryScreenBodyState();
}

class _MemoryScreenBodyState extends State<MemoryScreenBody> {
  List<int> activeCardIndices = [];
  List<String> imagePaths = [];
  List<MemoryCard> cards = [];
  List<int> discoveredCards = [];
  bool doingPairCheck = false;
  bool setupDone = false;

  late final int cols;
  late final int rows;

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
        if (discoveredCards.length == imagePaths.length) {
          widget.onGameOver();
          Future.delayed(const Duration(milliseconds: 2000), () {
            widget.onRestart();
          });
        }
      } else {
        doingPairCheck = true;
        final mustFlipDown = [
          cards[activeCardIndices[0]],
          cards[activeCardIndices[1]],
        ];
        Future.delayed(const Duration(milliseconds: 300), () {
          activeCardIndices.clear();
          doingPairCheck = false;
        });
        Future.delayed(const Duration(milliseconds: 700), () {
          mustFlipDown[0].flipperController.flipDown();
          Future.delayed(const Duration(milliseconds: 100), () {
            mustFlipDown[1].flipperController.flipDown();
          });
        });
      }
    }
  }

  void setup(BoxConstraints constraints) {
    const minWidth = 150;
    const minHeight = 150;
    cols = (constraints.maxWidth / minWidth).floor();
    rows = (constraints.maxHeight / minHeight).floor();
    final numOfPairs = (cols * rows / 2).floor();
    imagePaths = ImagePathProvider.imagePaths;
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
          imageProvider: AssetImage(imagePaths[i]),
          flipperController: FlipperController(dragAxis: DragAxis.vertical),
        ),
    ];

    Future.delayed(Duration.zero, () {
      precacheImages(context, imagePaths);
    });
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (!setupDone) {
          setup(constraints);
          setupDone = true;
        }
        return CustomGrid(
          cols: cols,
          rows: rows,
          children: cards,
        );
      },
    );
  }
}
