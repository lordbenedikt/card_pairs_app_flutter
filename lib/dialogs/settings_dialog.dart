import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:memory/providers/app_settings_provider.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({
    super.key,
    required this.onRestart,
    required this.autoSize,
    required this.turnCount,
    required this.cols,
    required this.rows,
  });

  final Function() onRestart;
  final bool autoSize;
  final bool turnCount;
  final int cols;
  final int rows;

  @override
  ConsumerState<SettingsDialog> createState() => _SetSizeDialogState();
}

class _SetSizeDialogState extends ConsumerState<SettingsDialog> {
  late bool _autoSize;
  late bool _turnCount;
  late int _cols;
  late int _rows;

  void _confirm() {
    Navigator.of(context).pop();
    ref.read(appSettingsProvider.notifier).updateAppSettings(
        autoSize: _autoSize, turnCount: _turnCount, cols: _cols, rows: _rows);
    widget.onRestart();
  }

  @override
  void initState() {
    _autoSize = widget.autoSize;
    _turnCount = widget.turnCount;
    _cols = widget.cols;
    _rows = widget.rows;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      // insetPadding: EdgeInsets.all(150),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 20,
          horizontal: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownMenu<int>(
                  width: 140,
                  label: const Text('cols'),
                  initialSelection: _cols,
                  onSelected: (value) {
                    setState(() {
                      _cols = value!;
                    });
                  },
                  dropdownMenuEntries: [
                    for (var i = 1; i <= 16; i++)
                      DropdownMenuEntry<int>(
                        value: i,
                        label: '$i',
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                DropdownMenu<int>(
                  width: 140,
                  label: const Text('rows'),
                  initialSelection: _rows,
                  onSelected: (value) {
                    setState(() {
                      _rows = value!;
                    });
                  },
                  dropdownMenuEntries: [
                    for (var i = 1; i <= 16; i++)
                      DropdownMenuEntry<int>(
                        value: i,
                        label: '$i',
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (false)
                  SizedBox(
                    width: 160,
                    child: CheckboxListTile(
                      title: const Text('turn count'),
                      value: _turnCount,
                      onChanged: (_) {
                        setState(() {
                          _turnCount = !_turnCount;
                        });
                      },
                    ),
                  ),
                SizedBox(
                  width: 140,
                  child: CheckboxListTile(
                    title: const Text('autosize'),
                    value: _autoSize,
                    onChanged: (_) {
                      setState(() {
                        _autoSize = !_autoSize;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                ),
                ElevatedButton(
                  onPressed: _confirm,
                  child: Text(
                    'Confirm',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
