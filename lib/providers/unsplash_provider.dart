import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/models/unsplash_card_set.dart';
import 'package:memory/providers/keys_provider.dart';

class UnsplashNotifier extends StateNotifier<List<CardSet>> {
  UnsplashNotifier() : super(<CardSet>[]);

  Future<CardSet?> fetchImages(String searchTerm) async {
    if (state.any((cardSet) => cardSet.title == searchTerm)) {
      return state.firstWhere((cardSet) => cardSet.title == searchTerm);
    }

    final String apiKey = SecretProvider.unsplashAccessKey;
    final String searchTermAdjusted = searchTerm.replaceAll(' ', '%20');
    final String apiUrl =
        'https://api.unsplash.com/photos/random?count=20&query=$searchTermAdjusted';

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'Authorization': 'Client-ID $apiKey',
      });

      if (response.statusCode == 200) {
        // Parse the response body
        final List<dynamic> data = json.decode(response.body);

        // Extract image URLs from the response
        List<String> urls = [];
        List<String> urlsFull = [];
        List<String> urlsTriggerDownload = [];
        for (var item in data) {
          urls.add("${item['urls']['raw']}&w=500&h=500");
          urlsFull.add("${item['urls']['full']}");
          urlsTriggerDownload.add("${item['download_location']}");
        }

        final res = UnsplashCardSet(
            imageUrlsFull: urlsFull,
            triggerDownloadUrl: urlsTriggerDownload,
            uid: '',
            title: searchTerm,
            imageUrls: urls,
            coverImageUrl: '',
            owner: '',
            groupsThatCanView: []);
        state = [...state, res];
        return res;
      } else {
        // Handle error
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exceptions
      print('Exception: $e');
    }
    return UnsplashCardSet(
        imageUrlsFull: [],
        triggerDownloadUrl: [],
        uid: '',
        title: searchTerm,
        imageUrls: [],
        coverImageUrl: '',
        owner: '',
        groupsThatCanView: []);
  }
}

final unsplashProvider =
    StateNotifierProvider<UnsplashNotifier, List<CardSet>>((ref) {
  return UnsplashNotifier();
});
