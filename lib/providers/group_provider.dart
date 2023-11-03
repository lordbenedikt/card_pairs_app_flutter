import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:memory/models/group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsNotifier extends StateNotifier<List<Group>> {
  GroupsNotifier() : super([]) {
    final firestore = FirebaseFirestore.instance;

    firestore.collection('groups').snapshots().listen((querySnapshot) {
      final List<Group> res = [];
      for (var group in querySnapshot.docs) {
        res.add(Group.fromJson(group.data()));
      }
      state = res;
    });
  }
}

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, List<Group>>((ref) {
  return GroupsNotifier();
});

// class GroupsProvider {
//   static Future<List<Group>> getAvailable() async {
//     final List<Group> res = [];
//     final allUsers = await FirebaseFirestore.instance.collection('groups').where('members', isEqualTo: F).get();
//     for (final user in allUsers.docs) {
//       res.add(Group.fromJson(user.data()));
//     }
//     return res;
//   }
// }
