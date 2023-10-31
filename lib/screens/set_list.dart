import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/models/group.dart';
import 'package:memory/models/user.dart';
import 'package:memory/providers/sqflite_helper.dart';
import 'package:memory/screens/memory.dart';
import 'package:memory/screens/new_set.dart';
import 'package:memory/widgets/add_users.dart';
import 'package:memory/widgets/search_users.dart';

class SetListScreen extends StatelessWidget {
  const SetListScreen(this.group, {super.key});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(group.title),
        actions: [
          // IconButton(
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (context) {
          //         return AlertDialog(
          //           content: Center(child: SizedBox(child: AddUsers())),
          //         );
          //       },
          //     );
          //   },
          //   icon: const Icon(Icons.group_add_rounded),
          // ),
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
                // print(sets[index].data());
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
                                  'by TODO',
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
