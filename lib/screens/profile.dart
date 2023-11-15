import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(usersProvider).firstWhere(
        (user) => user.uid == FirebaseAuth.instance.currentUser!.uid);
    return Column(children: [
      CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(user.imageUrl),
      ),
      Text(user.username),
    ]);
  }
}
