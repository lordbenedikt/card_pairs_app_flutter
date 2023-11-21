import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/models/card_set.dart';
import 'package:memory/providers/unsplash_provider.dart';
import 'package:memory/screens/memory.dart';

class RandomSetDialog extends ConsumerStatefulWidget {
  const RandomSetDialog({super.key});

  @override
  ConsumerState<RandomSetDialog> createState() => _RandomSetDialogState();
}

class _RandomSetDialogState extends ConsumerState<RandomSetDialog> {
  String _searchTerm = '';
  bool _no_results = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter a phrase, to generate a set:'),
              SizedBox(
                width: 300,
                child: TextFormField(
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_no_results) ...[
                Text(
                  'No images found. Please enter another phrase.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      try {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              return FutureBuilder(
                                future: ref
                                    .watch(unsplashProvider.notifier)
                                    .fetchImages(_searchTerm),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }

                                  return MemoryScreen(cardSet: snapshot.data!);
                                },
                              );
                            },
                          ),
                        );
                      } catch (error) {
                        _no_results = true;
                      }
                    },
                    child: const Text('Generate'),
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
