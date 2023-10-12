import 'package:flutter/material.dart';
import 'package:memory/image_provider.dart';
import 'package:memory/memory.dart';

import 'dart:io' show Platform;

var kColorScheme =
    ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 105, 63, 42));

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 9, 0, 65),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await CompressedImageProvider.init();

  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
      ),
      home: const MemoryApp(),
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
    return Memory(
      key: _key,
      onRestart: replaceMemoryWidget,
      numOfPairs: (Platform.isAndroid || Platform.isIOS) ? 8 : 12,
    );
  }
}
