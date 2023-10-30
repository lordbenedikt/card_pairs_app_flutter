import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
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

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);

  Map<String, dynamic> toJson() => _$AppUserToJson(this);
}
