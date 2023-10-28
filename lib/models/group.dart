import 'package:memory/models/card_set.dart';

class Group {
  Group({
    required this.title,
    required this.admin,
    required this.members,
    required this.availableSets,
    required this.imageUrl,
  });
  String title;
  String admin;
  List<String> members;
  List<CardSet> availableSets;
  String imageUrl;

  static Group fromMap(Map<String, dynamic> map) {
    return Group(
      title: map['title'],
      admin: map['admin'],
      members: map['members'],
      availableSets: map['available_sets'],
      imageUrl: map['image_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'admin': admin,
      'members': members,
      'available_sets': availableSets,
      'image_url': imageUrl,
    };
  }
}
