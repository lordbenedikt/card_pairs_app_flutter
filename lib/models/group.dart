import 'package:memory/models/card_set.dart';

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

  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      uid: map['uid'],
      title: map['title'],
      admin: map['admin'],
      members: [...map['members']],
      availableSets: [...map['available_sets']],
      imageUrl: map['image'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'admin': admin,
      'members': members,
      'available_sets': availableSets,
      'image': imageUrl,
    };
  }
}
