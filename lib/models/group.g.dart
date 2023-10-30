// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      uid: json['uid'] as String,
      title: json['title'] as String,
      admin: json['admin'] as String,
      members:
          (json['members'] as List<dynamic>).map((e) => e as String).toList(),
      availableSets: (json['availableSets'] as List<dynamic>)
          .map((e) => CardSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'admin': instance.admin,
      'members': instance.members,
      'availableSets': instance.availableSets,
      'imageUrl': instance.imageUrl,
    };
