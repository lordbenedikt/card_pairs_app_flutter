import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/models/group.dart';
import 'package:memory/providers/group_provider.dart';
import 'package:memory/providers/user_provider.dart';
import 'package:memory/screens/memory.dart';
import 'package:memory/screens/new_set.dart';
import 'package:memory/widgets/add_users.dart';

class SetListScreen extends ConsumerWidget {
  const SetListScreen(this.groupUid, {super.key});

  final String groupUid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Group group;
    if (ref.watch(groupsProvider).isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      group = ref.watch(groupsProvider).firstWhere(
            (group) => group.uid == groupUid,
          );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(group.title),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 400,
                        child: AddUsers(group),
                      ),
                    ),
                  );
                },
              );
            },
            icon: const Icon(Icons.group_add_rounded),
          ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return NewSetScreen(group: group);
              }));
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('card_sets')
              // .where('groups_that_can_view', arrayContains: group.uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No sets in this group'));
            }

            final sets = snapshot.data!.docs;
            final contextWidth = MediaQuery.of(context).size.width;
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: max(1, (contextWidth / 175).floor())),
              itemCount: sets.length,
              itemBuilder: (context, index) {
                final set = CardSet.fromJson(sets[index].data());
                return GestureDetector(
                  onTap: () {
                    // SqfliteHelper.addCardSet(set);

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) {
                        //     // SqfliteHelper.addCardSet(set);
                        //     // SqfliteHelper.getCardSets().then((cardSets) {
                        //     //   print('get sets');
                        //     //   for (final cardSet in cardSets) {
                        //     //     print(cardSet.owner);
                        //     //     print(cardSet.title);
                        //     //     print(cardSet.imageUrls);
                        //     //     print(cardSet.groupsThatCanView);
                        //     //     print(cardSet.coverImageUrl);
                        //     //     print(cardSet.uid);
                        //     //   }
                        //     // });
                        return MemoryScreen(cardSet: set);
                      },
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    clipBehavior: Clip.hardEdge,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(16)),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Image.network(
                            set.coverImageUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            color: Colors.black.withOpacity(0.7),
                            child: Column(
                              children: [
                                Text(
                                  set.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'by ${ref.read(usersProvider).firstWhere((user) => user.uid == set.owner).username}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
