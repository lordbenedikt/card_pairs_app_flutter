import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memory/models/group.dart';

class GroupProvider {
  // static Future<Map<String, dynamic>> getAvailableGroups() async {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //   if (currentUser == null) {
  //     throw FirebaseAuthException(code: code) Error();
  //   }
  //   return FirebaseFirestore.instance
  //       .collection('groups')
  //       .where('members', arrayContains: currentUser.uid)
  //       .get();
  // }
}
