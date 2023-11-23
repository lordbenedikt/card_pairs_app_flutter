import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/providers/group_provider.dart';
import 'package:memory/screens/profile.dart';
import 'package:memory/screens/set_list.dart';
import 'package:memory/screens/new_group.dart';
import 'package:memory/dialogs/random_set_dialog.dart';

class GroupListScreen extends ConsumerStatefulWidget {
  const GroupListScreen({super.key});

  @override
  ConsumerState<GroupListScreen> createState() => _GroupListScreenState();
}

class _GroupListScreenState extends ConsumerState<GroupListScreen> {
  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('My Groups'),
        leading: IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            tooltip: 'sign out',
            icon: const Icon(Icons.logout)),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const NewGroupScreen();
                }));
              },
              tooltip: 'create group',
              icon: const Icon(Icons.add)),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileScreen(),
                ),
              );
            },
            icon: const Icon(Icons.person),
          ),
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

            if (groups.isNotEmpty) {
              final myGroups = groups
                  .where(
                    (group) =>
                        group.members
                            .contains(FirebaseAuth.instance.currentUser!.uid) ||
                        group.uid == '26f220a9-5ebe-467b-836e-37d389045c3f',
                  )
                  .toList();
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: ListView.builder(
                  itemCount: myGroups.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return ListTile(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) => const RandomSetDialog());
                        },
                        title: Text(
                          'Generate with Unsplash API',
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      );
                    }
                    final group = myGroups[index - 1];
                    return ListTile(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SetListScreen(group.uid)));
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
                  },
                ),
              );
            } else {
              return const Center(child: Text("You're not in any group."));
            }
          },
        ),
      ),
    );
  }
}
