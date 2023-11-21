import 'package:json_annotation/json_annotation.dart';
import 'package:memory/models/card_set.dart';

@JsonSerializable()
class UnsplashCardSet extends CardSet {
  UnsplashCardSet({
    required this.imageUrlsFull,
    required this.triggerDownloadUrl,
    required super.uid,
    required super.title,
    required super.imageUrls,
    required super.coverImageUrl,
    required super.owner,
    required super.groupsThatCanView,
  });

  List<String> imageUrlsFull;
  List<String> triggerDownloadUrl;
}
