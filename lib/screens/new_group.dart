import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:memory/models/group.dart';
import 'package:memory/models/user.dart';
import 'package:memory/widgets/circular_image_picker.dart';
import 'package:uuid/v4.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  late final Future<List<AppUser>> users;
  final List<AppUser> selectedUsers = [];
  String _pickedTitle = '';
  File? _pickedImage;
  String _searchString = '';
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    users = getUsers();
    super.initState();
  }

  List<AppUser> getFilteredUsers(List<AppUser> users, String searchString) {
    final res = users.where((user) => !selectedUsers.contains(user)).toList();
    if (searchString.trim().isEmpty) return res;
    return res
        .where((user) =>
            user.username.contains(searchString) ||
            user.email.contains(searchString))
        .toList();
  }

  Future<List<AppUser>> getUsers() async {
    final List<AppUser> res = [];
    final allUsers = await FirebaseFirestore.instance.collection('users').get();
    for (final user in allUsers.docs) {
      res.add(AppUser.fromJson(user.data()));
    }
    return res;
  }

  void _submit() async {
    bool imageIsValid = true;

    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a group image.')));
      imageIsValid = false;
    }

    if (!_form.currentState!.validate() || !imageIsValid) {
      return;
    }

    _form.currentState!.save();

    final admin = FirebaseAuth.instance.currentUser!.uid;
    final members = selectedUsers.map((user) => user.uid).toList();
    members.add(admin);

    final groupUid = const UuidV4().generate();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('group_images')
        .child("$groupUid.jpg");

    await storageRef.putFile(_pickedImage!);
    final imageUrl = await storageRef.getDownloadURL();

    FirebaseFirestore.instance.collection('groups').doc(groupUid).set(Group(
          uid: groupUid,
          admin: admin,
          title: _pickedTitle,
          members: members,
          availableSets: [],
          imageUrl: imageUrl,
        ).toJson());

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Create Group'),
        actions: [
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          children: [
            Form(
              key: _form,
              child: Row(
                children: [
                  CircularImagePicker(
                    onPickImage: (file) {
                      _pickedImage = file;
                    },
                    label: 'Add image',
                    radius: 45,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        TextFormField(
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          validator: (value) {
                            if (value == null || value.length < 2) {
                              return 'Must be at least 2 characters';
                            }
                          },
                          onSaved: (value) {
                            _pickedTitle = value!;
                          },
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(),
                          autofocus: true,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.all(10),
                            labelText: 'Title',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(spacing: 4, runSpacing: 4, children: [
                          for (final user in selectedUsers)
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  borderRadius: BorderRadius.circular(30)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(width: 8),
                                  Text(user.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSecondaryContainer,
                                          )),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedUsers.remove(user);
                                      });
                                    },
                                    child: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            )
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Container(
              padding:
                  const EdgeInsets.only(top: 0, bottom: 0, left: 20, right: 30),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Theme.of(context).colorScheme.secondaryContainer),
              child: TextFormField(
                onChanged: (value) {
                  setState(() {
                    _searchString = value;
                  });
                },
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  border: InputBorder.none,
                ),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder(
                  future: users,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Error: ${snapshot.error.toString()}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                            softWrap: true,
                          ),
                        ),
                      );
                    }

                    final filteredUsers =
                        getFilteredUsers(snapshot.data!, _searchString);
                    if (snapshot.hasData && filteredUsers.isNotEmpty) {
                      return ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () {
                              final user = filteredUsers[index];
                              if (!selectedUsers.contains(user)) {
                                setState(() {
                                  selectedUsers.add(user);
                                });
                              }
                            },
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10,
                            ),
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage:
                                  NetworkImage(filteredUsers[index].imageUrl),
                            ),
                            title: Column(children: [
                              Text(
                                filteredUsers[index].username,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(filteredUsers[index].email),
                            ]),
                          );
                        },
                      );
                    }

                    return const Center(child: Text('No users found'));
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
