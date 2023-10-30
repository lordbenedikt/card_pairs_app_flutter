import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memory/models/group.dart';
import 'package:memory/screens/set_list.dart';
import 'package:memory/screens/memory.dart';
import 'package:memory/screens/new_group.dart';
import 'package:memory/screens/new_set.dart';
import 'package:memory/screens/set_list.dart';

class GroupListScreen extends StatefulWidget {
  const GroupListScreen({super.key});

  @override
  State<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends State<GroupListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Groups'),
        actions: [
          IconButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
              },
              tooltip: 'sign out',
              icon: const Icon(Icons.logout)),
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const NewGroupScreen();
                }));
              },
              tooltip: 'create group',
              icon: const Icon(Icons.add)),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('groups').snapshots(),
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

            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              final groups = snapshot.data!.docs;
              return ListView.builder(
                  itemCount: groups.length,
                  itemBuilder: (context, index) {
                    final group = Group.fromJson(groups[index].data());
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SetListScreen(group)));
                      },
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(group.imageUrl),
                      ),
                      title: Column(children: [
                        Text(
                          group.title,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ]),
                    );
                  });
            } else {
              return const Center(child: Text("You're not in any group."));
            }
          },
        ),
      ),
    );
  }
}
