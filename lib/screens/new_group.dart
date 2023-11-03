import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:memory/models/group.dart';
import 'package:memory/models/user.dart';
import 'package:memory/widgets/circular_image_picker.dart';
import 'package:memory/widgets/search_users.dart';
import 'package:uuid/v4.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final List<AppUser> _selectedUsers = [];
  String _pickedTitle = '';
  Uint8List? _pickedImage;
  final _form = GlobalKey<FormState>();

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
    final members = _selectedUsers.map((user) => user.uid).toList();
    members.add(admin);

    final groupUid = const UuidV4().generate();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('group_images')
        .child("$groupUid.jpg");

    await storageRef.putData(_pickedImage!);
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
                    onPickImage: (image) {
                      _pickedImage = image;
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
                          for (final user in _selectedUsers)
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
                                        _selectedUsers.remove(user);
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
            SearchUsers(
              hideUsers: [FirebaseAuth.instance.currentUser!.uid],
              selectedUsers: _selectedUsers,
              onChanged: () {
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }
}
