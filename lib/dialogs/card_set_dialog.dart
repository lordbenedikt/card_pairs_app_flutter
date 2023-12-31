import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/screens/view_card_set.dart';

class CardSetDialog extends StatefulWidget {
  const CardSetDialog({super.key, required this.set});

  final CardSet set;

  @override
  State<CardSetDialog> createState() => _CardSetDialogState();
}

class _CardSetDialogState extends State<CardSetDialog> {
  bool _buttonIsEnabled = false;

  void _deleteSet(CardSet set) async {
    for (final url in set.imageUrls.followedBy([set.coverImageUrl])) {
      try {
        await FirebaseStorage.instance.refFromURL(url).delete();
      } catch (_) {}
    }
    await FirebaseFirestore.instance
        .collection('card_sets')
        .doc(set.uid)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ViewCardSet(widget.set),
                    ),
                  );
                },
                child: Text(
                  'View images',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const Divider(),
              Text('To delete this card set, type "${widget.set.title}"'),
              TextField(
                onChanged: (value) {
                  setState(() {
                    _buttonIsEnabled = value == widget.set.title;
                  });
                },
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error),
                    onPressed: _buttonIsEnabled
                        ? () {
                            _deleteSet(widget.set);
                            Navigator.of(context).pop();
                          }
                        : null,
                    child: Text(
                      'Delete',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.onError),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
