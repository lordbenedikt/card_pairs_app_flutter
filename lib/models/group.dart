import 'package:memory/models/card_set.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

@JsonSerializable()
class Group {
  Group({
    required this.uid,
    required this.title,
    required this.admin,
    required this.members,
    required this.availableSets,
    required this.imageUrl,
  });
  String uid;
  String title;
  String admin;
  List<String> members;
  List<CardSet> availableSets;
  String imageUrl;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);
}
