import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/group.dart';
import 'package:memory/models/user.dart';
import 'package:memory/providers/user_provider.dart';
import 'package:memory/widgets/search_users.dart';

class AddUsers extends ConsumerStatefulWidget {
  const AddUsers(this.group, {super.key});

  final Group group;

  @override
  ConsumerState<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends ConsumerState<AddUsers> {
  late final List<AppUser> _groupMembers;
  final List<AppUser> _addUsers = [];

  List<AppUser> getSelectedUsers() {
    return ref
        .read(usersProvider)
        .where(
          (user) => widget.group.members.contains(user.uid),
        )
        .toList();
  }

  @override
  void initState() {
    _groupMembers = getSelectedUsers();
    super.initState();
  }

  void _submit() {
    FirebaseFirestore.instance
        .collection('groups')
        .doc(widget.group.uid)
        .update({
      'members':
          FieldValue.arrayUnion(_addUsers.map((user) => user.uid).toList())
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Flex(direction: Axis.vertical, children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final user in _addUsers)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
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
                              _addUsers.remove(user);
                            });
                          },
                          child: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (_addUsers.isNotEmpty) const Divider(),
            SearchUsers(
              hideUsers: _groupMembers.map((user) => user.uid).toList(),
              selectedUsers: _addUsers,
              onChanged: () {
                setState(() {});
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _addUsers.isEmpty ? null : _submit,
                  child: const Text('Add Users'),
                ),
              ],
            ),
          ],
        ),
      ),
    ]);
  }
}
