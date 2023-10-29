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

  static CardSet fromMap(Map<String, dynamic> map) {
    return CardSet(
      uid: map['uid'],
      title: map['title'],
      imageUrls: [...map['card_images']],
      owner: map['owner'],
      coverImageUrl: map['cover_image'],
      groupsThatCanView: [...map['groups_that_can_view']],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'title': title,
      'owner': owner,
      'card_images': imageUrls,
      'cover_image': coverImageUrl,
      'groups_that_can_view': groupsThatCanView,
    };
  }
}
