import 'dart:math';

import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/providers/app_settings_provider.dart';
import 'package:memory/dialogs/confirm_dialog.dart';
import 'package:memory/widgets/custom_grid.dart';
import 'package:flutter/material.dart';

import 'package:memory/widgets/memory_card.dart';
import 'package:memory/widgets/responsive_icon_button.dart';
import 'package:memory/dialogs/settings_dialog.dart';

class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({
    super.key,
    required this.cardSet,
  });

  final CardSet cardSet;

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  bool _gameOver = false;
  Key _key = UniqueKey();
  int _turnCount = 0;

  void restart() async {
    setState(() {
      _gameOver = false;
    });
    replaceMemoryWidget();
  }

  void replaceMemoryWidget() {
    // ref.read(appSettingsProvider.notifier).updateAppSettings(turnCounter: 0);
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
          LayoutBuilder(
            builder: (context, constraints) => MemoryScreenBody(
              key: _key,
              constraints: constraints,
              cardSet: widget.cardSet,
              onRestart: restart,
              onGameOver: () {
                setState(() => _gameOver = true);
              },
            ),
          ),
          Positioned(
            bottom: 10,
            left: 10,
            child: ResponsiveIconButton(
              onPressed: () async {
                bool? wasConfirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => const ConfirmDialog(
                    text: 'Do you want to leave? All progress will be lost.',
                  ),
                );
                if ((wasConfirmed ?? false) && context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              icon: const Icon(Icons.arrow_back, color: Colors.white70),
            ),
          ),
          if (ref.watch(appSettingsProvider).turnCount)
            Positioned(
              bottom: 10,
              right: 110,
              child: IgnorePointer(
                child: Container(
                  height: 40,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      '$_turnCount',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 10,
            right: 60,
            child: ResponsiveIconButton(
              onPressed: () {
                showDialog(
                    builder: (context) => SettingsDialog(
                          onRestart: restart,
                          autoSize: ref.watch(appSettingsProvider).autoSize,
                          turnCount: ref.watch(appSettingsProvider).turnCount,
                          cols: ref.watch(appSettingsProvider).cols,
                          rows: ref.watch(appSettingsProvider).rows,
                        ),
                    context: context);
              },
              icon: const Icon(Icons.settings, color: Colors.white70),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ResponsiveIconButton(
              onPressed: () async {
                bool? wasConfirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => const ConfirmDialog(
                    text: 'Do you want to restart? All progress will be lost.',
                  ),
                );
                if ((wasConfirmed ?? false) && context.mounted) {
                  restart();
                }
              },
              icon: const Icon(Icons.replay, color: Colors.white70),
            ),
          ),
        ],
      ),
      // ),
    );
  }
}

class MemoryScreenBody extends ConsumerStatefulWidget {
  const MemoryScreenBody({
    super.key,
    required this.constraints,
    required this.cardSet,
    required this.onGameOver,
    required this.onRestart,
  });

  final BoxConstraints constraints;
  final CardSet cardSet;
  final void Function() onGameOver;
  final void Function() onRestart;

  @override
  ConsumerState<MemoryScreenBody> createState() => _MemoryScreenBodyState();
}

class _MemoryScreenBodyState extends ConsumerState<MemoryScreenBody> {
  List<int> activeCardIndices = [];
  List<String> imageUrls = [];
  List<MemoryCard> cards = [];
  List<int> discoveredCards = [];
  bool doingPairCheck = false;
  bool setupDone = false;
  bool isLoading = true;
  // bool showFlipAnimation = false;
  bool showFlipAnimation = !(kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS));

  late int cols;
  late int rows;

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
    // if card is already discovered & paired do nothing
    if (cards[index].isFrontVisible()) {
      return;
    }
    // reveal card
    if (activeCardIndices.length < 2) {
      showFlipAnimation
          ? cards[index].flipperController.toggleCard()
          : cards[index].flipperController.toggleCardWithoutAnimation();
      activeCardIndices.add(index);
    }
    // check for pairs, cover cards, clear selection, restart game
    if (activeCardIndices.length == 2 && !doingPairCheck) {
      // ref.watch(appSettingsProvider.notifier).incrementTurnCount();
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
          if (!context.mounted) {
            return;
          }
          showFlipAnimation
              ? mustFlipDown[0].flipperController.toggleCard()
              : mustFlipDown[0].flipperController.toggleCardWithoutAnimation();

          Future.delayed(const Duration(milliseconds: 100), () {
            if (!context.mounted) {
              return;
            }
            showFlipAnimation
                ? mustFlipDown[1].flipperController.toggleCard()
                : mustFlipDown[1]
                    .flipperController
                    .toggleCardWithoutAnimation();
          }).ignore();
        }).ignore();
      }
    }
  }

  Future<void> setup() async {
    const minWidth = 150;
    const minHeight = 150;
    final appSettings = ref.watch(appSettingsProvider);
    cols = appSettings.autoSize
        ? (widget.constraints.maxWidth / minWidth).floor()
        : appSettings.cols;
    rows = appSettings.autoSize
        ? (widget.constraints.maxHeight / minHeight).floor()
        : appSettings.rows;
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
    // for (var card in cards) {
    //   card.flipperController.dispose();
    // }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder(
          future: setup(),
          builder: (context, snapshots) {
            if (snapshots.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshots.connectionState == ConnectionState.done) {
              return cards.isEmpty
                  ? const Center(
                      child: Text('No cards in this set.'),
                    )
                  : CustomGrid(
                      cols: cols,
                      rows: rows,
                      children: cards,
                    );
            }

            return const Center(
              child: Text('Setup failed.'),
            );
          },
        );
      },
    );
  }
}
