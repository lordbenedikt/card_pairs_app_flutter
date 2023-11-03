import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memory/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersNotifier extends StateNotifier<List<AppUser>> {
  UsersNotifier() : super([]) {
    final firestore = FirebaseFirestore.instance;

    firestore.collection('users').snapshots().listen((querySnapshot) {
      final List<AppUser> res = [];
      for (var user in querySnapshot.docs) {
        res.add(AppUser.fromJson(user.data()));
      }
      state = res;
    });
  }
}

final usersProvider =
    StateNotifierProvider<UsersNotifier, List<AppUser>>((ref) {
  return UsersNotifier();
});

// class UserProvider {
//   static Future<List<AppUser>> getAll() async {
//     final List<AppUser> res = [];
//     final allUsers = await FirebaseFirestore.instance.collection('users').get();
//     for (final user in allUsers.docs) {
//       res.add(AppUser.fromJson(user.data()));
//     }
//     return res;
//   }
// }
