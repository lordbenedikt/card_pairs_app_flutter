// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CardSet _$CardSetFromJson(Map<String, dynamic> json) => CardSet(
      uid: json['uid'] as String,
      title: json['title'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      coverImageUrl: json['coverImageUrl'] as String,
      owner: json['owner'] as String,
      groupsThatCanView: (json['groupsThatCanView'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$CardSetToJson(CardSet instance) => <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'imageUrls': instance.imageUrls,
      'coverImageUrl': instance.coverImageUrl,
      'owner': instance.owner,
      'groupsThatCanView': instance.groupsThatCanView,
    };
