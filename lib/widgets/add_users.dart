import 'package:flutter/material.dart';
import 'package:memory/models/user.dart';
import 'package:memory/widgets/search_users.dart';

class AddUsers extends StatefulWidget {
  const AddUsers({super.key});

  @override
  State<AddUsers> createState() => _AddUsersState();
}

class _AddUsersState extends State<AddUsers> {
  List<AppUser> selectedUsers = [];

  @override
  Widget build(BuildContext context) {
    return SearchUsers(onChanged: () {
      setState(() {});
    });
  }
}
