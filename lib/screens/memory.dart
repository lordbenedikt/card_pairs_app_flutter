import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/providers/sqflite_helper.dart';
import 'package:memory/screens/new_set.dart';
import 'package:memory/widgets/custom_grid.dart';
import 'package:memory/flipper_customized/flippy.dart';
import 'package:flutter/material.dart';

import 'package:memory/providers/image_provider.dart';
import 'package:memory/widgets/memory_card.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({
    super.key,
    required this.cardSet,
  });

  final CardSet cardSet;

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
    return
        // Theme(
        //   data: Theme.of(context).copyWith(
        //     colorScheme: ColorScheme.fromSeed(
        //       brightness: Brightness.dark,
        //       seedColor: Theme.of(context).colorScheme.primaryContainer,
        //     ),
        //   ),
        //   child:
        Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Stack(
        children: [
          MemoryScreenBody(
            key: _key,
            cardSet: widget.cardSet,
            onRestart: restart,
            onGameOver: () {
              setState(() => gameOver = true);
            },
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withOpacity(0.6),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 2 - 52,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withOpacity(0.6),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: MediaQuery.of(context).size.width / 2 + 5,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withOpacity(0.6),
              ),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              decoration: ShapeDecoration(
                shape: const CircleBorder(),
                color: Colors.black.withOpacity(0.6),
              ),
              child: IconButton(
                onPressed: restart,
                icon: const Icon(Icons.replay, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      // ),
    );
  }
}

class MemoryScreenBody extends StatefulWidget {
  const MemoryScreenBody({
    super.key,
    required this.cardSet,
    required this.onGameOver,
    required this.onRestart,
  });

  final CardSet cardSet;
  final void Function() onGameOver;
  final void Function() onRestart;

  @override
  State<MemoryScreenBody> createState() => _MemoryScreenBodyState();
}

class _MemoryScreenBodyState extends State<MemoryScreenBody> {
  List<int> activeCardIndices = [];
  List<String> imageUrls = [];
  List<MemoryCard> cards = [];
  List<int> discoveredCards = [];
  bool doingPairCheck = false;
  bool setupDone = false;

  late final int cols;
  late final int rows;

  void precacheImages(BuildContext context, List<String> urls) async {
    for (var url in urls) {
      precacheImage(NetworkImage(url), context);
    }
  }

  bool foundPair() {
    if (activeCardIndices.length < 2) return false;
    return imageUrls[activeCardIndices[0]] == imageUrls[activeCardIndices[1]];
  }

  void onTapCard(int index) {
    // if card is already selected do nothing
    if (activeCardIndices.contains(index)) {
      return;
    }
    // // if card animation is already playing do nothing
    // if (!cards[index].flipperController.isAnimationCompleted()) {
    //   return;
    // }
    // // if card is already discovered & paired do nothing
    // if (cards[index].flipperController.isFrontVisible()) {
    //   return;
    // }
    // reveal card
    if (activeCardIndices.length < 2) {
      cards[index].flipperController.toggleCard();
      activeCardIndices.add(index);
    }
    // check for pairs, cover cards, clear selection, restart game
    if (activeCardIndices.length == 2 && !doingPairCheck) {
      if (foundPair()) {
        discoveredCards.addAll(activeCardIndices);
        activeCardIndices.clear();
        if (discoveredCards.length == imageUrls.length) {
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
        Future.delayed(const Duration(milliseconds: 100), () {
          activeCardIndices.clear();
          doingPairCheck = false;
        });
        Future.delayed(const Duration(milliseconds: 900), () {
          mustFlipDown[0].flipperController.toggleCard();

          Future.delayed(const Duration(milliseconds: 100), () {
            mustFlipDown[1].flipperController.toggleCard();
          }).ignore();
        }).ignore();
      }
    }
  }

  void setup(BoxConstraints constraints) {
    const minWidth = 150;
    const minHeight = 150;
    cols = (constraints.maxWidth / minWidth).floor();
    rows = (constraints.maxHeight / minHeight).floor();
    final int numOfPairs = min(
      widget.cardSet.imageUrls.length,
      cols * rows / 2,
    ).floor();
    imageUrls = widget.cardSet.imageUrls;
    imageUrls.shuffle();
    imageUrls = [
      ...imageUrls.sublist(0, numOfPairs),
      ...imageUrls.sublist(0, numOfPairs),
    ];
    imageUrls.shuffle();
    cards = [
      for (var i = 0; i < imageUrls.length; i++)
        MemoryCard(
          key: ValueKey('memory_card_$i'),
          onTap: onTapCard,
          cardIndex: i,
          imageUrl: imageUrls[i],
          flipperController: FlipCardController(),
        ),
    ];

    precacheImages(context, widget.cardSet.imageUrls);
  }

  @override
  void dispose() {
    for (var card in cards) {
      // card.flipperController.dispose();
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
