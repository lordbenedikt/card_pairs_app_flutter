import 'package:json_annotation/json_annotation.dart';

part 'card_set.g.dart';

@JsonSerializable()
class CardSet {
  CardSet({
    required this.uid,
    required this.title,
    required this.imageUrls,
    required this.coverImageUrl,
    required this.owner,
    required this.groupsThatCanView,
  });
  String uid;
  String title;
  List<String> imageUrls;
  String coverImageUrl;
  String owner;
  List<String> groupsThatCanView;

  factory CardSet.fromJson(Map<String, dynamic> json) =>
      _$CardSetFromJson(json);

  Map<String, dynamic> toJson() => _$CardSetToJson(this);
}
