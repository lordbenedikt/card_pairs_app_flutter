import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/user.dart';
import 'package:memory/providers/user_provider.dart';

class SearchUsers extends ConsumerStatefulWidget {
  const SearchUsers({
    super.key,
    this.hideUsers = const [],
    required this.selectedUsers,
    required this.onChanged,
  });

  final List<String> hideUsers;
  final List<AppUser> selectedUsers;
  final void Function() onChanged;

  @override
  ConsumerState<SearchUsers> createState() => _SearchUsersState();
}

class _SearchUsersState extends ConsumerState<SearchUsers> {
  String _searchString = '';
  late final List<AppUser> users;

  @override
  void initState() {
    users = ref.read(usersProvider);
    super.initState();
  }

  List<AppUser> getFilteredUsers(List<AppUser> users, String searchString) {
    final res = users
        .where((user) => !widget.selectedUsers.contains(user))
        .where((user) => !widget.hideUsers.contains(user.uid))
        .toList();
    if (searchString.trim().isEmpty) return res;
    return res
        .where((user) =>
            user.username.contains(searchString) ||
            user.email.contains(searchString))
        .toList();
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
    final filteredUsers = getFilteredUsers(users, _searchString);

    return Expanded(
      child: Column(
        children: [
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
          if (filteredUsers.isNotEmpty)
            Expanded(
              child: ListView.builder(
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
                    title: Column(
                      children: [
                        Text(
                          filteredUsers[index].username,
                          style:
                              Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Text(filteredUsers[index].email),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            const Center(child: Text('No search results'))
        ],
      ),
    );
  }
}
