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
  bool _noResults = false;

  void _generate(BuildContext context) {
    try {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) {
            return FutureBuilder(
              future:
                  ref.watch(unsplashProvider.notifier).fetchImages(_searchTerm),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
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
      _noResults = true;
    }
  }

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
                  onFieldSubmitted: (value) {
                    _generate(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (_noResults) ...[
                Text(
                  'No images found. Please enter another phrase.',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
                const SizedBox(height: 20),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _generate(context);
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
