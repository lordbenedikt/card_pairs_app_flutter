class AppUser {
  AppUser({
    required this.uid,
    required this.username,
    required this.email,
    required this.imageUrl,
  });
  String uid;
  String username;
  String email;
  String imageUrl;

  static AppUser fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      username: map['username'],
      imageUrl: map['image_url'],
    );
  }
}
