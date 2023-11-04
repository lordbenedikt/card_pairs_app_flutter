import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/card_set.dart';

class CardSetsNotifier extends StateNotifier<List<CardSet>> {
  CardSetsNotifier() : super([]) {
    final firestore = FirebaseFirestore.instance;

    firestore.collection('card_sets').snapshots().listen((querySnapshot) {
      final List<CardSet> res = [];
      for (var cardSet in querySnapshot.docs) {
        res.add(CardSet.fromJson(cardSet.data()));
      }
      state = res;
    });
  }
}

final cardSetsProvider =
    StateNotifierProvider<CardSetsNotifier, List<CardSet>>((ref) {
  return CardSetsNotifier();
});
