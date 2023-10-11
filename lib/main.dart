import 'package:flutter/material.dart';
import 'package:memory/asset_path_provider.dart';
import 'package:memory/memory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AssetsPathProvider.init();

  runApp(
    const MaterialApp(
      home: MemoryApp(),
    ),
  );
}

class MemoryApp extends StatefulWidget {
  const MemoryApp({super.key});

  @override
  State<MemoryApp> createState() => _MemoryAppState();
}

class _MemoryAppState extends State<MemoryApp> {
  Key _key = UniqueKey();

  void replaceMemoryWidget() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Memory(key: _key, onRestart: replaceMemoryWidget);
  }
}
