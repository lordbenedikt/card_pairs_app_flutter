import 'package:flutter/material.dart';
import 'package:memory/models/group.dart';

class GroupListItem extends StatelessWidget {
  const GroupListItem(this.group, {super.key});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (context) => PlaceDetails(places[index]),
        //   ),
        // );
      },
      leading: CircleAvatar(
        radius: 26,
        backgroundImage: NetworkImage(
          group.imageUrl,
        ),
      ),
      title: Text(
        group.title,
        style: Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: Theme.of(context).colorScheme.onBackground),
      ),
    );
    ;
  }
}
