import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memory/models/user.dart';

class SearchUsers extends StatefulWidget {
  const SearchUsers({
    super.key,
    this.selectedUsers = const [],
    required this.onChanged,
  });

  final List<AppUser> selectedUsers;
  final void Function() onChanged;

  @override
  State<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends State<SearchUsers> {
  String _searchString = '';
  late final Future<List<AppUser>> users;

  @override
  void initState() {
    users = getUsers();
    super.initState();
  }

  List<AppUser> getFilteredUsers(List<AppUser> users, String searchString) {
    final res = users
        .where((user) => !widget.selectedUsers.contains(user))
        .where((user) => user.uid != FirebaseAuth.instance.currentUser!.uid)
        .toList();
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

  void selectUser(AppUser user) {
    if (!widget.selectedUsers.contains(user)) {
      setState(() {
        widget.selectedUsers.add(user);
      });
      widget.onChanged();
    }
  }

  void unselectUser(AppUser user) {
    setState(() {
      widget.selectedUsers.remove(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
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
                          selectUser(user);
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
      ]),
    );
  }
}
