import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:memory/firebase_options.dart';
import 'package:memory/image_provider.dart';
import 'package:memory/screens/auth.dart';
import 'package:memory/screens/memory.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:memory/screens/splash.dart';

var kColorScheme = ColorScheme.fromSeed(
  seedColor: const Color.fromARGB(255, 105, 63, 42),
);

var kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 9, 0, 65),
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ImagePathProvider.init();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MaterialApp(
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
      ),
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const MemoryApp();
          }

          return const AuthScreen();
        },
      ),
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
    return LayoutBuilder(builder: (context, constraints) {
      const minWidth = 150;
      const minHeight = 150;
      final cols = (constraints.maxWidth / minWidth).floor();
      final rows = (constraints.maxHeight / minHeight).floor();
      return Memory(
        key: _key,
        cols: cols,
        rows: rows,
        onRestart: replaceMemoryWidget,
      );
    });
  }
}
