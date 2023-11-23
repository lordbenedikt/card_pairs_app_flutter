import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/user.dart';
import 'package:memory/providers/user_provider.dart';
import 'package:memory/widgets/user_image_picker.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  AppUser? user;
  Uint8List? newImage;

  void loadUser() async {
    for (var i = 0; i < 20; i++) {
      try {
        setState(() {
          user = ref.read(usersProvider).firstWhere(
              (user) => user.uid == FirebaseAuth.instance.currentUser!.uid);
        });
      } catch (error) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  @override
  void initState() {
    loadUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(
          child: SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    final ImageProvider? newImageProvider =
        newImage != null ? MemoryImage(newImage!) : null;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Center(
                  child: UserImagePicker(
                    radius: constraints.maxHeight > 300 ? 120 : 0,
                    initialImage:
                        newImageProvider ?? NetworkImage(user!.imageUrl),
                    onPickImage: (pickedImage) {
                      setState(() {
                        newImage = pickedImage;
                      });
                    },
                  ),
                ),
                if (constraints.maxHeight > 500) const SizedBox(height: 30),
                Form(
                  key: _form,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Username'),
                        ),
                        initialValue: user!.username,
                        style: Theme.of(context).textTheme.titleLarge!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          label: Text('Email'),
                        ),
                        initialValue: user!.email,
                        style: Theme.of(context).textTheme.titleLarge!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
